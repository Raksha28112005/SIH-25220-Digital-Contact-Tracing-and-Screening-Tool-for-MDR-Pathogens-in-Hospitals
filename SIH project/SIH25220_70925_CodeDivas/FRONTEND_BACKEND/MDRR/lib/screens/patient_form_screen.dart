// lib/screens/patient_form_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../backend/models/patient.dart';
import '../backend/services/patient_service.dart';
import '../utils/random_data.dart';
import 'qr_scan_screen.dart';
import '../utils/pathogen_data.dart';

class PatientFormScreen extends StatefulWidget {
  const PatientFormScreen({super.key});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _wardController = TextEditingController();

  final TextEditingController _mdrPathogenController = TextEditingController();
  final TextEditingController _mdrSyndromeController = TextEditingController();
  final TextEditingController _transmissionController = TextEditingController();

  bool _isMdrKnown = false;

  String? _selectedPathogen;
  String? _selectedSyndrome;

  final _patientService = PatientService();

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _wardController.dispose();
    _mdrPathogenController.dispose();
    _mdrSyndromeController.dispose();
    _transmissionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Add New Patient',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(Icons.person, "Patient Details"),

              _glassCard(
                child: Column(
                  children: [
                    _label("Patient ID"),
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            controller: _idController,
                            hint: "Enter Patient ID",
                            validator: (v) =>
                                v!.isEmpty ? "Enter patient ID" : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _iconCircleButton(
                          Icons.qr_code_scanner,
                          onTap: _scanQrForPatient,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _label("Name"),
                    _textField(
                      controller: _nameController,
                      hint: "Enter full name",
                      validator: (v) =>
                          v!.isEmpty ? "Enter name" : null,
                    ),
                    const SizedBox(height: 12),

                    _label("Age"),
                    _textField(
                      controller: _ageController,
                      hint: "Enter age",
                      keyboard: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Enter age";
                        final n = int.tryParse(v);
                        return (n == null || n <= 0)
                            ? "Enter valid age"
                            : null;
                      },
                    ),
                    const SizedBox(height: 12),

                    _label("Ward / Location"),
                    Row(
                      children: [
                        Expanded(
                          child: _textField(
                            controller: _wardController,
                            hint: "ICU / Ward B / etc.",
                            validator: (v) =>
                                v!.isEmpty ? "Enter ward" : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _iconCircleButton(
                          Icons.shuffle,
                          onTap: () => setState(
                              () => _wardController.text = getRandomLocation()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _sectionTitle(Icons.health_and_safety, "MDR Information"),

              _glassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('Is this a known MDR case?'),
                      value: _isMdrKnown,
                      activeColor: const Color(0xFF5C6BC0),
                      onChanged: (v) {
                        setState(() {
                          _isMdrKnown = v;
                          if (!v) {
                            _selectedPathogen = null;
                            _selectedSyndrome = null;
                            _mdrPathogenController.clear();
                            _mdrSyndromeController.clear();
                            _transmissionController.clear();
                          }
                        });
                      },
                    ),

                    if (_isMdrKnown) ...[
                      const SizedBox(height: 8),

                      _label("Pathogen"),
                      DropdownButtonFormField<String>(
                        value: _selectedPathogen,
                        decoration: _dropdownDecoration(),
                        items: [
                          for (final p in pathogenInfos)
                            DropdownMenuItem(
                              value: p.name,
                              child: Text(p.name),
                            ),
                          const DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other (manual entry)'),
                          ),
                        ],
                        onChanged: _onPathogenChanged,
                      ),

                      const SizedBox(height: 12),

                      _label("Syndrome"),
                      DropdownButtonFormField<String>(
                        value: _selectedSyndrome,
                        decoration: _dropdownDecoration(),
                        items: [
                          for (final s in syndromeOptions)
                            DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ),
                          const DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other (manual entry)'),
                          ),
                        ],
                        onChanged: _onSyndromeChanged,
                      ),

                      const SizedBox(height: 12),

                      _label("Transmission"),
                      _textField(
                        controller: _transmissionController,
                        readOnly: true,
                        hint: "Auto filled",
                        maxLines: 3,
                      ),
                    ]
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Center(
                child: SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C6BC0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _savePatient,
                    child: const Text(
                      "Save Patient",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI HELPERS
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(IconData icon, String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF5C6BC0)),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF37474F),
              ),
            ),
          ],
        ),
      );

  Widget _glassCard({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF37474F),
          ),
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboard,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboard,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 1.5),
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  Widget _iconCircleButton(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFF5C6BC0),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOGIC (unchanged)
  // ---------------------------------------------------------------------------

  void _onPathogenChanged(String? value) {
    if (value == null) return;

    setState(() {
      _selectedPathogen = value;

      if (value == 'Other') {
        _mdrPathogenController.clear();
        _mdrSyndromeController.clear();
        _selectedSyndrome = null;
        _transmissionController.clear();
        return;
      }

      final info = findPathogenByName(value);
      if (info != null) {
        _mdrPathogenController.text = info.name;
        _mdrSyndromeController.text = info.syndrome;
        _selectedSyndrome = info.syndrome;
        _transmissionController.text = info.transmission;
      }
    });
  }

  void _onSyndromeChanged(String? value) {
    if (value == null) return;

    setState(() {
      if (value == 'Other') {
        _selectedSyndrome = null;
        _mdrSyndromeController.clear();
        return;
      }

      _selectedSyndrome = value;
      _mdrSyndromeController.text = value;

      if (_selectedPathogen != null) {
        final info = pathogenInfos.firstWhere(
          (p) => p.name == _selectedPathogen && p.syndrome == value,
          orElse: () => PathogenInfo(
            name: _selectedPathogen!,
            syndrome: value,
            transmission: _transmissionController.text,
          ),
        );
        _transmissionController.text = info.transmission;
      }
    });
  }

  Future<void> _scanQrForPatient() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );

    if (result == null) return;

    final parts = result.split('|');
    if (parts.length >= 3) {
      _idController.text = parts[0];
      _nameController.text = parts[1];
      _ageController.text = parts[2];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid QR format: $result')),
      );
    }
  }

  Future<void> _savePatient() async {
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return;

    if (kIsWeb) {
      messenger.showSnackBar(const SnackBar(
        content: Text('DB write disabled on web. Use Android/Windows instead.'),
      ));
      return;
    }

    final patient = Patient(
      id: _idController.text.trim(),
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text.trim()),
      ward: _wardController.text.trim(),
      isMdrKnown: _isMdrKnown,
      mdrPathogen: _isMdrKnown
          ? _mdrPathogenController.text.trim().takeIfNotEmpty()
          : null,
      mdrSyndrome: _isMdrKnown
          ? _mdrSyndromeController.text.trim().takeIfNotEmpty()
          : null,
      transmissionType: _isMdrKnown
          ? _transmissionController.text.trim().takeIfNotEmpty()
          : null,
    );

    await _patientService.addPatient(patient);

    messenger.showSnackBar(
      const SnackBar(content: Text('Patient saved successfully.')),
    );

    Navigator.pop(context);
  }
}

extension _StringNullHelper on String {
  String? takeIfNotEmpty() => trim().isEmpty ? null : trim();
}