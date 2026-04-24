import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../backend/services/movement_service.dart';
import '../backend/services/equipment_service.dart';
import '../backend/services/contact_service.dart';
import '../backend/services/risk_service.dart';
import '../backend/models/movement.dart';
import '../backend/models/equipment_usage.dart';
import '../backend/models/contact_event.dart';
import '../backend/models/risk_score.dart';

class PatientOverviewScreen extends StatefulWidget {
  const PatientOverviewScreen({super.key});

  @override
  State<PatientOverviewScreen> createState() => _PatientOverviewScreenState();
}

class _PatientOverviewScreenState extends State<PatientOverviewScreen> {
  final _patientIdController = TextEditingController();

  final _movementService = MovementService();
  final _equipmentService = EquipmentService();
  final _contactService = ContactService();
  final _riskService = RiskService();

  List<Movement> _movements = [];
  List<EquipmentUsage> _equipment = [];
  List<ContactEvent> _contacts = [];
  RiskScore? _riskScore;

  bool _loading = false;

  @override
  void dispose() {
    _patientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Patient Overview',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
      ),

      // ------------------------------ BODY ------------------------------
      body: Column(
        children: [
          // 🔹 Header with input & load button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAF6),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(22)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _patientIdController,
                  decoration: InputDecoration(
                    labelText: 'Patient ID',
                    labelStyle: const TextStyle(color: Color(0xFF5C6BC0)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF5C6BC0), width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loading ? null : _loadData,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.search),
                  label: const Text("Load Overview"),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5C6BC0),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(child: _riskScore == null ? _emptyBody(theme) : _overview(theme)),
        ],
      ),
    );
  }

  // ------------------------------------------
  // EMPTY STATE
  // ------------------------------------------
  Widget _emptyBody(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded,
              size: 70, color: const Color(0xFF5C6BC0)),
          const SizedBox(height: 10),
          const Text(
            'Enter a patient ID and tap "Load Overview".',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF37474F)),
          )
        ],
      ),
    );
  }

  // ------------------------------------------
  // MAIN OVERVIEW BODY
  // ------------------------------------------
  Widget _overview(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ------------------ RISK SUMMARY CARD ------------------
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor:
                        _riskColor(_riskScore!.riskCategory).withOpacity(0.15),
                    child: Text(
                      _riskScore!.riskCategory.substring(0, 1),
                      style: TextStyle(
                        color: _riskColor(_riskScore!.riskCategory),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "MDR Risk Summary",
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),

                        // 🔹 Risk chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 10),
                          decoration: BoxDecoration(
                            color: _riskColor(_riskScore!.riskCategory)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${_riskScore!.riskCategory} • ${(_riskScore!.finalRisk * 100).toStringAsFixed(1)}%",
                            style: TextStyle(
                              color: _riskColor(_riskScore!.riskCategory),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ------------------ MOVEMENTS ------------------
          _sectionTitle("Movements (${_movements.length})"),
          const SizedBox(height: 8),

          if (_movements.isEmpty)
            _emptySection("No movements logged.")
          else
            ..._movements.map((m) => _movementCard(m)),

          const SizedBox(height: 18),

          // ------------------ EQUIPMENT ------------------
          _sectionTitle("Equipment Usage (${_equipment.length})"),
          const SizedBox(height: 8),

          if (_equipment.isEmpty)
            _emptySection("No equipment usage logged.")
          else
            ..._equipment.map((e) => _equipmentCard(e)),

          const SizedBox(height: 18),

          // ------------------ CONTACT EVENTS ------------------
          _sectionTitle("Contact Events (${_contacts.length})"),
          const SizedBox(height: 8),

          if (_contacts.isEmpty)
            _emptySection("No contacts logged.")
          else
            ..._contacts.map((c) => _contactCard(c)),
        ],
      ),
    );
  }

  // ------------------------------------------
  // REUSABLE SECTION TITLE
  // ------------------------------------------
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF37474F)),
    );
  }

  // ------------------------------------------
  // EMPTY SECTION MESSAGE
  // ------------------------------------------
  Widget _emptySection(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(text, style: const TextStyle(color: Color(0xFF546E7A))),
    );
  }

  // ------------------------------------------
  // MOVEMENT CARD
  // ------------------------------------------
  Widget _movementCard(Movement m) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(m.ward, style: const TextStyle(color: Color(0xFF37474F))),
        subtitle: Text(
          "From: ${m.timeIn}\nTo:     ${m.timeOut}",
          style: const TextStyle(color: Color(0xFF546E7A)),
        ),
      ),
    );
  }

  // ------------------------------------------
  // EQUIPMENT CARD
  // ------------------------------------------
  Widget _equipmentCard(EquipmentUsage e) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text(e.equipmentName, style: const TextStyle(color: Color(0xFF37474F))),
        subtitle: Text(
          "Time: ${e.timestamp}\nShared: ${e.sharedWithOthers ? "Yes" : "No"}",
          style: const TextStyle(color: Color(0xFF546E7A)),
        ),
      ),
    );
  }

  // ------------------------------------------
  // CONTACT CARD
  // ------------------------------------------
  Widget _contactCard(ContactEvent c) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: Text("With: ${c.contactPatientId}", style: const TextStyle(color: Color(0xFF37474F))),
        subtitle: Text(
          "Location: ${c.location}\n"
          "From: ${c.startTime}\nTo:     ${c.endTime}",
          style: const TextStyle(color: Color(0xFF546E7A)),
        ),
      ),
    );
  }

  // ------------------------------------------
  // LOAD DATA
  // ------------------------------------------
  Future<void> _loadData() async {
    final messenger = ScaffoldMessenger.of(context);
    final patientId = _patientIdController.text.trim();

    if (patientId.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter a patient ID')),
      );
      return;
    }

    if (kIsWeb) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Overview uses local DB. Run on Android/Windows for real data.',
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final moves = await _movementService.getMovementsForPatient(patientId);
      final equip = await _equipmentService.getUsage(patientId);
      final contacts = await _contactService.getContacts(patientId);
      final risk = await _riskService.evaluatePatientRisk(patientId);

      setState(() {
        _movements = moves;
        _equipment = equip;
        _contacts = contacts;
        _riskScore = risk;
      });
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ------------------------------------------
  // COLOR MAPPING FOR RISK
  // ------------------------------------------
  Color _riskColor(String category) {
    switch (category.toUpperCase()) {
      case 'HIGH':
        return const Color(0xFFEF5350);
      case 'MEDIUM':
        return const Color(0xFFFFA726);
      default:
        return const Color(0xFF66BB6A);
    }
  }
}