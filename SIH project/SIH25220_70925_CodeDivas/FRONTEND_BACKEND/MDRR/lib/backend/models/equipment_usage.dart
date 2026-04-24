// lib/backend/models/equipment_usage.dart
class EquipmentUsage {
  final int? id;
  final String patientId;
  final String equipmentName;   // ventilator, nebulizer, etc.
  final DateTime timestamp;
  final bool sharedWithOthers;  // shared equipment?

  EquipmentUsage({
    this.id,
    required this.patientId,
    required this.equipmentName,
    required this.timestamp,
    required this.sharedWithOthers,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'equipment_name': equipmentName,
      'timestamp': timestamp.toIso8601String(),
      'shared_with_others': sharedWithOthers ? 1 : 0,
    };
  }

  factory EquipmentUsage.fromMap(Map<String, dynamic> map) {
    return EquipmentUsage(
      id: map['id'] as int?,
      patientId: map['patient_id'] as String,
      equipmentName: map['equipment_name'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      sharedWithOthers: (map['shared_with_others'] as int) == 1,
    );
  }
}
