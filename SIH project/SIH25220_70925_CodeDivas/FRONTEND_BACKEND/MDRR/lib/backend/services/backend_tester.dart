import '../models/patient.dart';
import '../models/movement.dart';
import '../models/equipment_usage.dart';
import '../models/contact_event.dart';
import 'patient_service.dart';
import 'movement_service.dart';
import 'equipment_service.dart';
import 'contact_service.dart';
import 'risk_service.dart';

class BackendTester {
  final _patientService = PatientService();
  final _movementService = MovementService();
  final _equipmentService = EquipmentService();
  final _contactService = ContactService();
  final _riskService = RiskService();

  Future<void> runTest() async {
    const String testPatientId = 'P001';

    // 1) Create dummy patient
    final patient = Patient(
      id: testPatientId,
      name: 'Test Patient',
      age: 45,
      ward: 'ICU',
      isMdrKnown: false,
    );
    await _patientService.addPatient(patient);

    // 2) Add some movements
    final now = DateTime.now();
    await _movementService.addMovement(Movement(
      patientId: testPatientId,
      ward: 'ICU',
      timeIn: now.subtract(const Duration(minutes: 90)),
      timeOut: now.subtract(const Duration(minutes: 30)),
    ));

    await _movementService.addMovement(Movement(
      patientId: testPatientId,
      ward: 'Ward B',
      timeIn: now.subtract(const Duration(minutes: 30)),
      timeOut: now,
    ));

    // 3) Equipment usage
    await _equipmentService.addUsage(EquipmentUsage(
      patientId: testPatientId,
      equipmentName: 'Ventilator',
      timestamp: now.subtract(const Duration(minutes: 60)),
      sharedWithOthers: true,
    ));

    // 4) Contact event with another patient
    await _contactService.addContactEvent(ContactEvent(
      indexPatientId: testPatientId,
      contactPatientId: 'P002',
      startTime: now.subtract(const Duration(minutes: 50)),
      endTime: now.subtract(const Duration(minutes: 20)),
      location: 'ICU',
    ));

    // 5) Evaluate risk
    await _riskService.evaluatePatientRisk(testPatientId);


   // print('=== Backend Test Result ===');
    //print('Patient: ${patient.name} (${patient.id})');
    //print('Backend exposure risk: ${riskScore.backendExposureRisk}');
    //print('ML clinical risk (dummy): ${riskScore.mlClinicalRisk}');
    //print('Final risk: ${riskScore.finalRisk}');
    //print('Category: ${riskScore.riskCategory}');
  }
}
