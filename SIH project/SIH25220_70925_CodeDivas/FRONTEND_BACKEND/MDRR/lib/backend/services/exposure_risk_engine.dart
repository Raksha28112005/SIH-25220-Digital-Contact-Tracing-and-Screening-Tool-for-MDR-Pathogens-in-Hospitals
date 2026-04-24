// lib/backend/services/exposure_risk_engine.dart
import '../models/movement.dart';
import '../models/equipment_usage.dart';
import '../models/contact_event.dart';

class ExposureRiskEngine {
  /// Returns a value between 0 and 1 based on rules
  static double calculateExposureRisk({
    required List<Movement> movements,
    required List<EquipmentUsage> equipmentUsages,
    required List<ContactEvent> contactEvents,
  }) {
    double score = 0;
    double maxScore = 30; // adjust as needed

    // 1) Movement-related risk
    final icuTimeMinutes = movements
        .where((m) => m.ward.toLowerCase().contains('icu'))
        .fold<Duration>(Duration.zero, (prev, m) => prev + m.duration)
        .inMinutes;

    if (icuTimeMinutes > 0) {
      score += 5;
      if (icuTimeMinutes > 60) score += 3;
    }

    final uniqueWards =
        movements.map((m) => m.ward).toSet().length;
    if (uniqueWards >= 3) {
      score += 4; // visited many wards
    } else if (uniqueWards == 2) {
      score += 2;
    }

    // 2) Equipment-related risk
    for (final usage in equipmentUsages) {
      final eq = usage.equipmentName.toLowerCase();
      if (eq.contains('ventilator')) {
        score += 5;
        if (usage.sharedWithOthers) score += 2;
      } else if (eq.contains('nebulizer')) {
        score += 4;
        if (usage.sharedWithOthers) score += 2;
      } else if (eq.contains('catheter') || eq.contains('line')) {
        score += 3;
      }
    }

    // 3) Contact-related risk
    for (final contact in contactEvents) {
      final minutes = contact.duration.inMinutes;
      if (minutes >= 15) score += 3;   // prolonged contact
      if (minutes >= 60) score += 2;   // very prolonged
    }

    if (contactEvents.length >= 5) {
      score += 4; // many contacts
    }

    // Normalize to 0–1
    if (score <= 0) return 0;
    if (score >= maxScore) return 1;
    return score / maxScore;
  }
}
