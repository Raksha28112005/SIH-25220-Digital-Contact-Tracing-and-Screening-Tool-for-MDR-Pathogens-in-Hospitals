class ClinicalObservation {
  final int? id;
  final String patientId;
  final double temperature;
  final int icuDays;
  final int ventilatorDays;
  final int antibioticDays;
  final int comorbiditiesScore;
  final bool previousMdrHistory;
  final bool labMdrPositive;
  final DateTime recordedAt;

  ClinicalObservation({
    this.id,
    required this.patientId,
    required this.temperature,
    required this.icuDays,
    required this.ventilatorDays,
    required this.antibioticDays,
    required this.comorbiditiesScore,
    required this.previousMdrHistory,
    required this.labMdrPositive,
    required this.recordedAt,
  });

  /// Convert model to SQLite-friendly map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'temperature': temperature,
      'icu_days': icuDays,
      'ventilator_days': ventilatorDays,
      'antibiotic_days': antibioticDays,
      'comorbidities_score': comorbiditiesScore,
      'previous_mdr_history': previousMdrHistory ? 1 : 0,
      'lab_mdr_positive': labMdrPositive ? 1 : 0,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  /// Construct model from SQLite map
  factory ClinicalObservation.fromMap(Map<String, dynamic> map) {
    try {
      return ClinicalObservation(
        id: map['id'] as int?,
        patientId: map['patient_id'] as String,
        temperature: (map['temperature'] as num).toDouble(),
        icuDays: map['icu_days'] as int,
        ventilatorDays: map['ventilator_days'] as int,
        antibioticDays: map['antibiotic_days'] as int,
        comorbiditiesScore: map['comorbidities_score'] as int,
        previousMdrHistory: (map['previous_mdr_history'] as int) == 1,
        labMdrPositive: (map['lab_mdr_positive'] as int) == 1,
        recordedAt: DateTime.parse(map['recorded_at'] as String),
      );
    } catch (e) {
      throw Exception("Failed to parse ClinicalObservation: $e");
    }
  }
}
