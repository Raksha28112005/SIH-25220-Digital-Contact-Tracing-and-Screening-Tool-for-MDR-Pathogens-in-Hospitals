import 'package:flutter/material.dart';

import '../backend/services/clinical_service.dart';
import '../backend/models/clinical_observation.dart';
import 'qr_scan_screen.dart';

class ClinicalDataScreen extends StatefulWidget {
  const ClinicalDataScreen({Key? key}) : super(key: key);

  @override
  State<ClinicalDataScreen> createState() => _ClinicalDataScreenState();
}

class _ClinicalDataScreenState extends State<ClinicalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _tempController = TextEditingController();

  bool _hasDiabetes = false;
  bool _hasHypertension = false;
  bool _hasOtherComorbidity = false;
  bool _previousMdr = false;
  String _labResult = 'pending';

  bool _saving = false;
  final ClinicalService _clinicalService = ClinicalService();

  @override
  void dispose() {
    _patientIdController.dispose();
    _tempController.dispose();
    super.dispose();
  }

  Future<void> _scanQrForClinical() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const QrScanScreen(),
      ),
    );

    if (result == null) return;

    final parts = result.split('|');
    if (parts.isNotEmpty) {
      setState(() {
        _patientIdController.text = parts[0];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid QR format: $result')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final temp = double.tryParse(_tempController.text.trim()) ?? 37.0;

    // Show alert if temperature > 38°C
    if (temp > 38) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFFE8E8),
            title: Row(
              children: const [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('High Temperature Alert'),
              ],
            ),
            content: const Text(
              'Patient has a high temperature (>38°C).\n'
              'Consider sanitation and isolated consultation',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    setState(() => _saving = true);

    final comorbidityScore = [
      _hasDiabetes,
      _hasHypertension,
      _hasOtherComorbidity,
    ].where((b) => b).length;

    final observation = ClinicalObservation(
      patientId: _patientIdController.text.trim(),
      temperature: temp,
      icuDays: 0,
      ventilatorDays: 0,
      antibioticDays: 0,
      comorbiditiesScore: comorbidityScore,
      previousMdrHistory: _previousMdr,
      labMdrPositive: _labResult == 'positive',
      recordedAt: DateTime.now(),
    );

    await _clinicalService.insertObservation(observation);

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clinical Data Saved')),
    );

    Navigator.of(context).pop();
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF37474F))),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Clinical Data'),
        centerTitle: true,
        elevation: 1,
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFFF5F7FA),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // ========================= PATIENT SECTION =========================
                _buildSectionCard(
                  title: "Patient Details",
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _patientIdController,
                          decoration: const InputDecoration(
                            labelText: 'Patient ID',
                            labelStyle: TextStyle(color: Color(0xFF5C6BC0)),
                            prefixIcon: Icon(Icons.person_search, color: Color(0xFF5C6BC0)),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF5C6BC0)),
                            ),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? 'Enter patient ID'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _scanQrForClinical,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text("Scan"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C6BC0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                // ========================= VITALS SECTION =========================
                _buildSectionCard(
                  title: "Vital Observations",
                  child: TextFormField(
                    controller: _tempController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Temperature (°C)',
                      labelStyle: TextStyle(color: Color(0xFF5C6BC0)),
                      prefixIcon: Icon(Icons.thermostat, color: Color(0xFF5C6BC0)),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF5C6BC0)),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Enter temperature'
                            : null,
                  ),
                ),

                // ========================= COMORBIDITIES SECTION =========================
                _buildSectionCard(
                  title: "Comorbidities",
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: const Text('Diabetes'),
                        value: _hasDiabetes,
                        activeColor: const Color(0xFF5C6BC0),
                        onChanged: (v) =>
                            setState(() => _hasDiabetes = v ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Hypertension'),
                        value: _hasHypertension,
                        activeColor: const Color(0xFF5C6BC0),
                        onChanged: (v) =>
                            setState(() => _hasHypertension = v ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Other Comorbidity'),
                        value: _hasOtherComorbidity,
                        activeColor: const Color(0xFF5C6BC0),
                        onChanged: (v) =>
                            setState(() => _hasOtherComorbidity = v ?? false),
                      ),
                    ],
                  ),
                ),

                // ========================= MDR HISTORY SECTION =========================
                _buildSectionCard(
                  title: "MDR Details",
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text("Previous MDR infection"),
                        value: _previousMdr,
                        activeColor: const Color(0xFF5C6BC0),
                        onChanged: (v) => setState(() => _previousMdr = v),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _labResult,
                        items: const [
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Lab MDR Result: Pending'),
                          ),
                          DropdownMenuItem(
                            value: 'positive',
                            child: Text('Lab MDR Result: Positive'),
                          ),
                          DropdownMenuItem(
                            value: 'negative',
                            child: Text('Lab MDR Result: Negative'),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _labResult = v ?? 'pending'),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF5C6BC0)),
                          ),
                          prefixIcon: Icon(Icons.biotech, color: Color(0xFF5C6BC0)),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ========================= SAVE BUTTON =========================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _saving ? "Saving..." : "Save Clinical Observation",
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF5C6BC0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}