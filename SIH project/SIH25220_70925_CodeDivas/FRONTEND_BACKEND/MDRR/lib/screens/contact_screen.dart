import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../backend/models/contact_event.dart';
import '../backend/services/contact_service.dart';
import '../utils/random_data.dart';
import 'qr_scan_screen.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _indexPatientController = TextEditingController();
  final _contactPatientController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationMinutesController = TextEditingController(text: '30');

  final ContactService _contactService = ContactService();

  @override
  void dispose() {
    _indexPatientController.dispose();
    _contactPatientController.dispose();
    _locationController.dispose();
    _durationMinutesController.dispose();
    super.dispose();
  }

  Widget _sectionCard({required String title, required Widget child}) {
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
        title: const Text('Log Contact Event'),
        centerTitle: true,
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        elevation: 1,
      ),

      body: Container(
        color: const Color(0xFFF5F7FA),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,

            child: Column(
              children: [
                // ====================== INDEX PATIENT SECTION ======================
                _sectionCard(
                  title: "Index Patient (Evaluated Patient)",
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _indexPatientController,
                          decoration: const InputDecoration(
                            labelText: 'Index Patient ID',
                            labelStyle: TextStyle(color: Color(0xFF5C6BC0)),
                            prefixIcon: Icon(Icons.person, color: Color(0xFF5C6BC0)),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF5C6BC0)),
                            ),
                          ),
                          validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? 'Enter index patient ID'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _scanQrForIndex,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text("Scan"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C6BC0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                        ),
                      )
                    ],
                  ),
                ),

                // ====================== CONTACT PATIENT SECTION ======================
                _sectionCard(
                  title: "Contact Patient",
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _contactPatientController,
                          decoration: const InputDecoration(
                            labelText: 'Contact Patient ID',
                            labelStyle: TextStyle(color: Color(0xFF5C6BC0)),
                            prefixIcon: Icon(Icons.group, color: Color(0xFF5C6BC0)),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF5C6BC0)),
                            ),
                          ),
                          validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? 'Enter contact patient ID'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _scanQrForContact,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text("Scan"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5C6BC0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                        ),
                      )
                    ],
                  ),
                ),

                // ====================== LOCATION SECTION ======================
                _sectionCard(
                  title: "Location (Ward / Room)",
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            labelStyle: TextStyle(color: Color(0xFF5C6BC0)),
                            prefixIcon: Icon(Icons.location_on_outlined, color: Color(0xFF5C6BC0)),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF5C6BC0)),
                            ),
                          ),
                          validator: (value) =>
                              (value == null || value.isEmpty)
                                  ? 'Enter location'
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.shuffle, color: Color(0xFF5C6BC0)),
                        iconSize: 32,
                        tooltip: 'Random Location',
                        onPressed: () {
                          setState(() {
                            _locationController.text = getRandomLocation();
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // ====================== DURATION SECTION ======================
                _sectionCard(
                  title: "Contact Duration",
                  child: TextFormField(
                    controller: _durationMinutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (minutes)',
                      labelStyle: TextStyle(color: Color(0xFF5C6BC0)),
                      prefixIcon: Icon(Icons.timer, color: Color(0xFF5C6BC0)),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF5C6BC0)),
                      ),
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
                ),

                const SizedBox(height: 22),

                // ====================== SAVE BUTTON ======================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveContact,
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'Save Contact Event',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF5C6BC0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================== QR SCANNERS ======================
  Future<void> _scanQrForIndex() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );

    if (result == null) return;

    final parts = result.split('|');
    if (parts.isNotEmpty) {
      setState(() => _indexPatientController.text = parts[0]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid QR format: $result')),
      );
    }
  }

  Future<void> _scanQrForContact() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );

    if (result == null) return;

    final parts = result.split('|');
    if (parts.isNotEmpty) {
      setState(() => _contactPatientController.text = parts[0]);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid QR format: $result')),
      );
    }
  }

  // ====================== SAVE CONTACT ======================
  Future<void> _saveContact() async {
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate()) return;

    if (kIsWeb) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Contact logging disabled on web. Use Android/Windows.',
          ),
        ),
      );
      return;
    }

    final indexId = _indexPatientController.text.trim();
    final contactId = _contactPatientController.text.trim();
    final location = _locationController.text.trim();
    final minutes = int.parse(_durationMinutesController.text.trim());

    final now = DateTime.now();
    final event = ContactEvent(
      indexPatientId: indexId,
      contactPatientId: contactId,
      startTime: now.subtract(Duration(minutes: minutes)),
      endTime: now,
      location: location,
    );

    await _contactService.addContactEvent(event);

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Contact logged: $indexId ↔ $contactId ($minutes min).',
        ),
      ),
    );

    Navigator.of(context).pop();
  }
}