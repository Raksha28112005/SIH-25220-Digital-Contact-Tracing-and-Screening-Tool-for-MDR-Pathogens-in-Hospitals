// lib/backend/services/risk_service.dart

import 'dart:math' as math;

import '../db/app_database.dart';
import '../models/movement.dart';
import '../models/equipment_usage.dart';
import '../models/contact_event.dart';
import '../models/risk_score.dart';
import '../models/clinical_observation.dart';
import 'clinical_service.dart';
import 'exposure_risk_engine.dart';

class RiskService {
  final AppDatabase _appDatabase = AppDatabase();
  final ClinicalService _clinicalService = ClinicalService();

  /// Main function: combine exposure + clinical (ML-style) risk
  Future<RiskScore> evaluatePatientRisk(String patientId) async {
    final db = await _appDatabase.database;

    // 1) Load movement / equipment / contact data
    final movementRows = await db.query(
      'movements',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );

    final equipmentRows = await db.query(
      'equipment_usage',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );

    final contactRows = await db.query(
      'contact_events',
      where: 'contact_patient_id = ?',
      whereArgs: [patientId],
    );

    final movements =
        movementRows.map((m) => Movement.fromMap(m)).toList();
    final equipmentUsages =
        equipmentRows.map((e) => EquipmentUsage.fromMap(e)).toList();
    final contactEvents =
        contactRows.map((c) => ContactEvent.fromMap(c)).toList();

    // 2) Backend exposure risk (rule-based)
    final backendRisk = ExposureRiskEngine.calculateExposureRisk(
      movements: movements,
      equipmentUsages: equipmentUsages,
      contactEvents: contactEvents,
    );

    // 3) Load clinical data & age
    final clinicalObs =
        await _clinicalService.getLatestForPatient(patientId);

    // get age from patients table (fallback 40)
    final patientRows = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [patientId],
      limit: 1,
    );
    final int age =
        patientRows.isNotEmpty ? (patientRows.first['age'] as int) : 40;

    // compute total exposure duration in hours from contact events
    final double durationHours = _computeExposureDuration(contactEvents);

    double mlRisk;
    String explanation;

    if (clinicalObs == null) {
      mlRisk = 0.2;
      explanation =
          'Insufficient clinical data – using exposure pattern only.';
    } else {
      mlRisk = _computeMlClinicalRisk(
        age: age,
        obs: clinicalObs,
        durationHours: durationHours,
      );
      explanation = _buildExplanation(
        age: age,
        obs: clinicalObs,
        durationHours: durationHours,
      );
    }

    // 4) Combine exposure + clinical risk
    final double finalRisk = (0.7 * mlRisk) + (0.3 * backendRisk);

    final riskScore = RiskScore(
      patientId: patientId,
      backendExposureRisk: backendRisk,
      mlClinicalRisk: mlRisk,
      finalRisk: finalRisk,
      calculatedAt: DateTime.now(),
      explanation: explanation,
    );

    // 5) Save in DB
    final id = await db.insert('risk_scores', riskScore.toMap());

    // 6) Return score with DB id set
    return riskScore.copyWith(id: id);
  }

  // Sum of contact duration in hours
  double _computeExposureDuration(List<ContactEvent> events) {
    double total = 0.0;
    for (final e in events) {
      // If your ContactEvent fields are already DateTime, just use them directly
      final DateTime start = e.startTime;
      final DateTime end = e.endTime;

      final diff = end.difference(start).inMinutes / 60.0;
      if (diff > 0) {
        total += diff;
      }
    }
    return total;
  }


  /// Simple logistic‑style clinical risk model using age, temp,
  /// comorbidities, previous MDR, lab MDR result and exposure duration.
  double _computeMlClinicalRisk({
    required int age,
    required ClinicalObservation obs,
    required double durationHours,
  }) {
    const double b0 = -3.0;
    const double bAge = 0.03;
    const double bTemp = 0.5;
    const double bComorbid = 0.4;
    const double bPrevMdr = 1.2;
    const double bLabMdrPos = 1.5;
    const double bDuration = 0.15;

    final double xAge = age.toDouble();
    final double xTemp = obs.temperature;
    final double xCom = obs.comorbiditiesScore.toDouble();
    final double xPrev = obs.previousMdrHistory ? 1.0 : 0.0;
    final double xLab = obs.labMdrPositive ? 1.0 : 0.0;
    final double xDur = durationHours;

    final double z = b0 +
        bAge * xAge +
        bTemp * (xTemp - 37.0) +
        bComorbid * xCom +
        bPrevMdr * xPrev +
        bLabMdrPos * xLab +
        bDuration * xDur;

    final p = 1 / (1 + math.exp(-z));
    return p.clamp(0.0, 1.0);
  }

  String _buildExplanation({
    required int age,
    required ClinicalObservation obs,
    required double durationHours,
  }) {
    final reasons = <String>[];

    if (age >= 60) reasons.add('age ≥ 60');
    if (age <= 4) reasons.add('very young (≤ 4 yrs)');

    if (obs.comorbiditiesScore >= 2) {
      reasons.add('multiple comorbidities');
    } else if (obs.comorbiditiesScore == 1) {
      reasons.add('one comorbidity');
    }

    if (obs.temperature >= 38.0) {
      reasons.add('fever (temp ≥ 38°C)');
    }

    if (obs.previousMdrHistory) {
      reasons.add('previous MDR infection');
    }

    if (obs.labMdrPositive) {
      reasons.add('current lab MDR+');
    }

    if (durationHours >= 2) {
      reasons.add('> 2 hours exposure to MDR+');
    }

    if (reasons.isEmpty) {
      return 'Moderate risk with limited clinical factors.';
    } else {
      return 'High risk because: ${reasons.join(', ')}.';
    }
  }
}

// Helper extension to set the DB id after insert
extension _RiskScoreCopy on RiskScore {
  RiskScore copyWith({
    int? id,
    String? patientId,
    double? backendExposureRisk,
    double? mlClinicalRisk,
    double? finalRisk,
    DateTime? calculatedAt,
    String? explanation,
  }) {
    return RiskScore(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      backendExposureRisk:
          backendExposureRisk ?? this.backendExposureRisk,
      mlClinicalRisk: mlClinicalRisk ?? this.mlClinicalRisk,
      finalRisk: finalRisk ?? this.finalRisk,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      explanation: explanation ?? this.explanation,
    );
  }
}
