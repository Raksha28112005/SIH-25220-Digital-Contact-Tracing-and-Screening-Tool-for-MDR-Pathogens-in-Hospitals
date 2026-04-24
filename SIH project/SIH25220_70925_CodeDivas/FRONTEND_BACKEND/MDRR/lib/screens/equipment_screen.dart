import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../backend/models/equipment_usage.dart';
import '../backend/services/equipment_service.dart';
import '../utils/random_data.dart';
import 'qr_scan_screen.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();

  final EquipmentService _equipmentService = EquipmentService();

  String _selectedEquipment = hospitalEquipments.first;
  bool _sharedWithOthers = true;

  final List<String> _equipmentOptions = List<String>.from(hospitalEquipments);

  @override
  void dispose() {
    _patientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Log Equipment Usage'),
        elevation: 1,
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // -------------------------------------------------------------
              // 🔹 PATIENT ID SECTION
              // -------------------------------------------------------------
              _buildSectionCard(
                title: "Patient Details",
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _patientIdController,
                        decoration: InputDecoration(
                          labelText: 'Patient ID',
                          labelStyle: const TextStyle(color: Color(0xFF5C6BC0)),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFF5C6BC0)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter patient ID';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildCircleButton(
                      icon: Icons.qr_code_scanner,
                      tooltip: 'Scan QR',
                      onTap: _scanQrForEquipment,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // -------------------------------------------------------------
              // 🔹 EQUIPMENT SECTION
              // -------------------------------------------------------------
              _buildSectionCard(
                title: "Equipment Selection",
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedEquipment,
                        decoration: InputDecoration(
                          labelText: 'Equipment',
                          labelStyle: const TextStyle(color: Color(0xFF5C6BC0)),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          prefixIcon: const Icon(Icons.medical_services_outlined, color: Color(0xFF5C6BC0)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 1.5),
                          ),
                        ),
                        items: _equipmentOptions
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedEquipment = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildCircleButton(
                      icon: Icons.shuffle,
                      tooltip: 'Random Equipment',
                      onTap: () {
                        setState(() {
                          _selectedEquipment = getRandomEquipment();
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // -------------------------------------------------------------
              // 🔹 SHARED OPTION SECTION
              // -------------------------------------------------------------
              _buildSectionCard(
                title: "Usage Details",
                child: SwitchListTile(
                  title: const Text('Shared with other patients?'),
                  value: _sharedWithOthers,
                  activeColor: const Color(0xFF5C6BC0),
                  onChanged: (val) {
                    setState(() {
                      _sharedWithOthers = val;
                    });
                  },
                ),
              ),

              const SizedBox(height: 30),

              // -------------------------------------------------------------
              // 🔹 SAVE BUTTON
              // -------------------------------------------------------------
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5C6BC0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _saveEquipmentUsage,
                    child: const Text('Save Equipment Usage'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 🔹 REUSABLE CARD SECTION
  // -------------------------------------------------------------------------
  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 🔹 REUSABLE CIRCLE BUTTON (for QR + Random)
  // -------------------------------------------------------------------------
  Widget _buildCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 22,
            color: const Color(0xFF5C6BC0),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // 🔹 QR Scanner
  // -------------------------------------------------------------------------
  Future<void> _scanQrForEquipment() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
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

  // -------------------------------------------------------------------------
  // 🔹 Save Logic (unchanged)
  // -------------------------------------------------------------------------
  Future<void> _saveEquipmentUsage() async {
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return;

    if (kIsWeb) {
      messenger.showSnackBar(
        const SnackBar(
          content:
              Text('Equipment logging to DB disabled on web. Use Android/Windows.'),
        ),
      );
      return;
    }

    final patientId = _patientIdController.text.trim();
    final now = DateTime.now();

    final usage = EquipmentUsage(
      patientId: patientId,
      equipmentName: _selectedEquipment,
      timestamp: now,
      sharedWithOthers: _sharedWithOthers,
    );

    await _equipmentService.addUsage(usage);

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(content: Text('Equipment $_selectedEquipment logged for $patientId.')),
    );

    Navigator.of(context).pop();
  }
}