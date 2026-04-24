import 'dart:math';

final _rand = Random();

/// Random hospital locations
const hospitalLocations = [
  'ICU',
  'Ward A',
  'Ward B',
  'Ward C',
  'ER',
  'Isolation Room',
  'MRI Room',
  'CT Scan Room',
  'Radiology',
  'Operation Theatre',
];

/// Random equipment list
const hospitalEquipments = [
  'Ventilator',
  'ECG Machine',
  'Infusion Pump',
  'IV Stand',
  'Ultrasound',
  'Oxygen Cylinder',
  'Wheelchair',
  'Hospital Bed',
  'Nebulizer',
];


String getRandomLocation() {
  return hospitalLocations[_rand.nextInt(hospitalLocations.length)];
}

String getRandomEquipment() {
  return hospitalEquipments[_rand.nextInt(hospitalEquipments.length)];
}
