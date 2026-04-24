// lib/backend/models/risk_score.dart

/// Represents the combined infection risk score for a patient.
///
/// Includes:
/// - Backend exposure risk (from contact-tracing logic)
/// - ML clinical risk (from local ML model)
/// - Final combined risk (weighted result)
/// - A human-readable explanation for UI
class RiskScore {
  final int? id;
  final String patientId;

  /// Probability (0.0 - 1.0) based on exposure / proximity analysis.
  final double backendExposureRisk;

  /// Probability (0.0 - 1.0) from ML model using clinical observations.
  final double mlClinicalRisk;

  /// Final combined risk score calculated by backend logic.
  final double finalRisk;

  /// When the score was generated.
  final DateTime calculatedAt;

  /// Explanation for UI and audit logs.
  final String explanation;

  RiskScore({
    this.id,
    required this.patientId,
    required this.backendExposureRisk,
    required this.mlClinicalRisk,
    required this.finalRisk,
    required this.calculatedAt,
    required this.explanation,
  });

  /// Returns the category used in UI: LOW / MEDIUM / HIGH.
  String get riskCategory {
    if (finalRisk >= 0.7) return 'HIGH';
    if (finalRisk >= 0.4) return 'MEDIUM';
    return 'LOW';
  }

  /// Create a RiskScore object from database map.
  factory RiskScore.fromMap(Map<String, dynamic> map) {
    return RiskScore(
      id: map['id'] as int?,
      patientId: map['patient_id'] as String,
      backendExposureRisk:
          (map['backend_exposure_risk'] as num).toDouble(),
      mlClinicalRisk: (map['ml_clinical_risk'] as num).toDouble(),
      finalRisk: (map['final_risk'] as num).toDouble(),
      calculatedAt: DateTime.parse(map['calculated_at'] as String),
      explanation: (map['explanation'] as String?) ?? '',
    );
  }

  /// Convert RiskScore to a map for database operations.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'backend_exposure_risk': backendExposureRisk,
      'ml_clinical_risk': mlClinicalRisk,
      'final_risk': finalRisk,
      'calculated_at': calculatedAt.toIso8601String(),
      'explanation': explanation,
    };
  }
}
