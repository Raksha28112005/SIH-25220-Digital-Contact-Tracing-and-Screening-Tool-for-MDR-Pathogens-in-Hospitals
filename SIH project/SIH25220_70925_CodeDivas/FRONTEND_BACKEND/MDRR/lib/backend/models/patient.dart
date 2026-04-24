// lib/backend/models/patient.dart
class Patient {
  final String id;          // unique hospital ID
  final String name;
  final int age;
  final String ward;        // current ward
  final bool isMdrKnown;    // already known MDR case?
  
  
  // 👇 NEW
  final String? mdrPathogen;
  final String? mdrSyndrome;
  final String? transmissionType;


  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.ward,
    required this.isMdrKnown,
    this.mdrPathogen,
    this.mdrSyndrome,
    this.transmissionType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'ward': ward,
      'is_mdr_known': isMdrKnown ? 1 : 0,

      // 👇 NEW
      'mdr_pathogen': mdrPathogen,
      'mdr_syndrome': mdrSyndrome,
      'transmission_type': transmissionType,
    };
  }


  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      ward: map['ward'] as String,
      isMdrKnown: (map['is_mdr_known'] as int) == 1,

      // 👇 NEW
      mdrPathogen: map['mdr_pathogen'] as String?,
      mdrSyndrome: map['mdr_syndrome'] as String?,
      transmissionType: map['transmission_type'] as String?,
    );
  }
}
