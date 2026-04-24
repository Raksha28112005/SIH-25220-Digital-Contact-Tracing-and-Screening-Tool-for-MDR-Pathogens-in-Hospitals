// lib/backend/models/contact_event.dart
class ContactEvent {
  final int? id;
  final String indexPatientId;     // the patient we are evaluating
  final String contactPatientId;   // the other patient
  final DateTime startTime;
  final DateTime endTime;
  final String location;           // ward/room

  ContactEvent({
    this.id,
    required this.indexPatientId,
    required this.contactPatientId,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'index_patient_id': indexPatientId,
      'contact_patient_id': contactPatientId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
    };
  }

  factory ContactEvent.fromMap(Map<String, dynamic> map) {
    return ContactEvent(
      id: map['id'] as int?,
      indexPatientId: map['index_patient_id'] as String,
      contactPatientId: map['contact_patient_id'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
      location: map['location'] as String,
    );
  }
}
