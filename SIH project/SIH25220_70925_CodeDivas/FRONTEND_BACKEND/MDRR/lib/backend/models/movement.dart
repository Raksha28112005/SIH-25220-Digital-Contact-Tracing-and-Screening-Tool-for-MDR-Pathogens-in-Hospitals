// lib/backend/models/movement.dart
class Movement {
  final int? id;              // auto-increment DB id
  final String patientId;     // FK -> patients.id
  final String ward;          // ward or location
  final DateTime timeIn;
  final DateTime timeOut;

  Movement({
    this.id,
    required this.patientId,
    required this.ward,
    required this.timeIn,
    required this.timeOut,
  });

  Duration get duration => timeOut.difference(timeIn);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'ward': ward,
      'time_in': timeIn.toIso8601String(),
      'time_out': timeOut.toIso8601String(),
    };
  }

  factory Movement.fromMap(Map<String, dynamic> map) {
    return Movement(
      id: map['id'] as int?,
      patientId: map['patient_id'] as String,
      ward: map['ward'] as String,
      timeIn: DateTime.parse(map['time_in'] as String),
      timeOut: DateTime.parse(map['time_out'] as String),
    );
  }
}
