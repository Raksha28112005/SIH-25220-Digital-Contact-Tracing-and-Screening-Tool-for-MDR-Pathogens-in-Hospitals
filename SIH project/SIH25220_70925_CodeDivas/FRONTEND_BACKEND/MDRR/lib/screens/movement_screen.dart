import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../backend/models/movement.dart';
import '../backend/services/movement_service.dart';
import '../utils/random_data.dart';
import 'qr_scan_screen.dart';

class MovementScreen extends StatefulWidget {
  const MovementScreen({super.key});

  @override
  State<MovementScreen> createState() => _MovementScreenState();
}

class _MovementScreenState extends State<MovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _wardController = TextEditingController();
  final _durationMinutesController = TextEditingController(text: '30');

  final MovementService _movementService = MovementService();

  @override
  void dispose() {
    _patientIdController.dispose();
    _wardController.dispose();
    _durationMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Log Movement',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildCard(
                title: "Patient Details",
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _patientIdController,
                            decoration: _fieldDeco(
                              label: 'Patient ID',
                              icon: Icons.badge_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter patient ID';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        _iconBtn(
                          icon: Icons.qr_code_scanner,
                          tooltip: 'Scan QR',
                          onTap: _scanQrForMovement,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildCard(
                title: "Movement Details",
                child: Column(
                  children: [
                    // Ward + random button
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _wardController,
                            decoration: _fieldDeco(
                              label: 'Ward / Location',
                              icon: Icons.location_on_outlined,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter ward or location';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        _iconBtn(
                          icon: Icons.shuffle,
                          tooltip: 'Random Ward',
                          onTap: () {
                            setState(() {
                              _wardController.text = getRandomLocation();
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Duration
                    TextFormField(
                      controller: _durationMinutesController,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDeco(
                        label: 'Duration in ward (minutes)',
                        icon: Icons.timer_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter duration';
                        }
                        final minutes = int.tryParse(value);
                        if (minutes == null || minutes <= 0) {
                          return 'Enter a valid number of minutes';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C6BC0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _saveMovement,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    "Save Movement",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card Wrapper
  // ---------------------------------------------------------------------------
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
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
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Field Decoration
  // ---------------------------------------------------------------------------
  InputDecoration _fieldDeco({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF5C6BC0)),
      prefixIcon: Icon(icon, color: const Color(0xFF5C6BC0)),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 1.5),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Rounded Icon Button
  // ---------------------------------------------------------------------------
  Widget _iconBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 26, color: const Color(0xFF5C6BC0)),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // QR Scan
  // ---------------------------------------------------------------------------
  Future<void> _scanQrForMovement() async {
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

  // ---------------------------------------------------------------------------
  // Save Movement
  // ---------------------------------------------------------------------------
  Future<void> _saveMovement() async {
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return;

    if (kIsWeb) {
      messenger.showSnackBar(
        const SnackBar(
          content:
              Text('Movement logging to DB disabled on web. Use Android/Windows.'),
        ),
      );
      return;
    }

    final patientId = _patientIdController.text.trim();
    final ward = _wardController.text.trim();
    final minutes = int.parse(_durationMinutesController.text.trim());

    final now = DateTime.now();
    final timeIn = now.subtract(Duration(minutes: minutes));
    final timeOut = now;

    final movement = Movement(
      patientId: patientId,
      ward: ward,
      timeIn: timeIn,
      timeOut: timeOut,
    );

    await _movementService.addMovement(movement);

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content:
            Text('Movement saved for $patientId in $ward ($minutes min).'),
      ),
    );

    Navigator.of(context).pop();
  }
}