import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/movement_screen.dart';
import 'screens/equipment_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/patient_overview_screen.dart';
import 'screens/patient_form_screen.dart';
import 'screens/outbreak_alerts_screen.dart';
import 'screens/clinical_data_screen.dart';

import 'backend/services/backend_tester.dart';
import 'backend/services/patient_service.dart';
import 'backend/services/risk_service.dart';
import 'backend/models/patient.dart';
import 'backend/services/sync_service.dart';

enum UserRole { doctor, nurse }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
  }

  if (!kIsWeb) {
    final tester = BackendTester();
    await tester.runTest();
  }

  runApp(const MDRApp());
}

class MDRApp extends StatelessWidget {
  const MDRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB3E5FC),
          brightness: Brightness.light,
        ),
      ),
      home: const RoleLoginScreen(),
    );
  }
}

// =======================
// Role Login Screen
// =======================
class RoleLoginScreen extends StatefulWidget {
  const RoleLoginScreen({super.key});

  @override
  State<RoleLoginScreen> createState() => _RoleLoginScreenState();
}

class _RoleLoginScreenState extends State<RoleLoginScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _login(UserRole role) {
    final rawName = _nameController.text.trim();
    final name = rawName.isEmpty
        ? (role == UserRole.doctor ? 'Doctor' : 'Nurse')
        : rawName;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(role: role, userName: name),
      ),
    );
  }

  Widget _roleBox(String title, IconData icon, UserRole role, Color color) {
    return GestureDetector(
      onTap: () => _login(role),
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 36, color: const Color(0xFF37474F)),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF37474F),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Color(0xFF37474F)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 6,
              margin: const EdgeInsets.all(24),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'MDR Screening App',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF37474F),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Your name (optional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        prefixIcon: const Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Login as',
                      style: TextStyle(fontSize: 16, color: Color(0xFF37474F)),
                    ),
                    const SizedBox(height: 12),
                    _roleBox('Doctor', Icons.medical_services, UserRole.doctor, const Color(0xFFFFF3E0)),
                    _roleBox('Nurse', Icons.local_hospital, UserRole.nurse, const Color(0xFFE8F5E9)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =======================
// Home Screen
// =======================
class HomeScreen extends StatefulWidget {
  final UserRole role;
  final String userName;

  const HomeScreen({super.key, required this.role, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PatientService _patientService = PatientService();
  final RiskService _riskService = RiskService();
  final SyncService _syncService = SyncService();

  bool get isDoctor => widget.role == UserRole.doctor;
  bool get isNurse => widget.role == UserRole.nurse;

  Widget _buildBox(String title, IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: color,
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40, color: const Color(0xFF37474F)),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF37474F),
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 20, color: Color(0xFF37474F)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _doctorBoxes() => [
        _buildBox('Add Test Patient (Backend)', Icons.add, _addTestPatient, const Color(0xFFFFF3E0)),
        _buildBox('Patient Overview', Icons.people, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PatientOverviewScreen()));
        }, const Color(0xFFE8F5E9)),
        _buildBox('Outbreak Alerts', Icons.warning, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OutbreakAlertsScreen()));
        }, const Color(0xFFFFF3E0)),
        _buildBox('Evaluate Risk (Test)', Icons.assessment, _evaluateRisk, const Color(0xFFE8F5E9)),
      ];

  List<Widget> _nurseBoxes() => [
        _buildBox('Add Patient', Icons.person_add, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PatientFormScreen()));
        }, const Color(0xFFE8F5E9)),
        _buildBox('Log Movement', Icons.directions_walk, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MovementScreen()));
        }, const Color(0xFFFFF3E0)),
        _buildBox('Log Equipment Usage', Icons.medical_services, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EquipmentScreen()));
        }, const Color(0xFFE8F5E9)),
        _buildBox('Log Contact Event', Icons.contact_page, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactScreen()));
        }, const Color(0xFFFFF3E0)),
        _buildBox('Add Clinical Data', Icons.data_usage, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClinicalDataScreen()));
        }, const Color(0xFFE8F5E9)),
        _buildBox('Sync to Cloud', Icons.cloud_upload, () async {
          try {
            await _syncService.syncToCloud();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Synced pending data to cloud')),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sync failed: $e')),
            );
          }
        }, const Color(0xFFFFF3E0)),
      ];

  @override
  Widget build(BuildContext context) {
    final roleLabel = isDoctor ? 'Doctor' : 'Nurse';

    return Scaffold(
      appBar: AppBar(
        title: Text('MDR Contact Tracing – $roleLabel (${widget.userName})'),
        centerTitle: true,
        backgroundColor: const Color(0xFF90CAF9),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'MDR Contact Tracing – Backend Connected',
                    style: const TextStyle(fontSize: 18, color: Color(0xFF37474F)),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              if (isDoctor) ..._doctorBoxes(),
              if (isNurse) ..._nurseBoxes(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addTestPatient() async {
    final messenger = ScaffoldMessenger.of(context);
    if (kIsWeb) {
      messenger.showSnackBar(const SnackBar(
          content: Text('DB write disabled on web. Use Android/Windows to really test backend.')));
      return;
    }

    final patient = Patient(
      id: 'PTEST1',
      name: 'Backend Test Patient',
      age: 40,
      ward: 'ICU',
      isMdrKnown: false,
    );

    await _patientService.addPatient(patient);

    if (!mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('Test patient saved to local DB.')));
  }

  Future<void> _evaluateRisk() async {
    final messenger = ScaffoldMessenger.of(context);
    if (kIsWeb) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Risk evaluation uses local DB. Run on Android/Windows for full test.')));
      return;
    }

    final TextEditingController idController = TextEditingController();

    final String? patientId = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Evaluate Risk'),
          content: TextField(
            controller: idController,
            decoration: const InputDecoration(
              labelText: 'Patient ID',
              hintText: 'e.g. PTEST1',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Cancel')),
            TextButton(
                onPressed: () {
                  final id = idController.text.trim();
                  Navigator.of(ctx).pop(id.isEmpty ? null : id);
                },
                child: const Text('OK')),
          ],
        );
      },
    );

    if (patientId == null) return;

    try {
      final patient = await _patientService.getPatientById(patientId);
      if (patient == null) {
        messenger.showSnackBar(SnackBar(content: Text('No patient found with ID: $patientId')));
        return;
      }

      final riskScore = await _riskService.evaluatePatientRisk(patientId);
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('MDR Risk Evaluation'),
            content: Text(
              'Patient: ${patient.name} ($patientId)\n'
              'Ward: ${patient.ward}\n'
              'Category: ${riskScore.riskCategory}\n'
              'Final Score: ${(riskScore.finalRisk * 100).toStringAsFixed(1)}%\n\n'
              'Explanation:\n${riskScore.explanation}',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('Error evaluating risk: $e')));
    }
  }
}
