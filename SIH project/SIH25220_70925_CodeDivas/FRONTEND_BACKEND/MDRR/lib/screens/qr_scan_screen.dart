// lib/screens/qr_scan_screen.dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart' as zx;

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool _handled = false;

  bool get _cameraSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !_cameraSupported) {
      // Web not supported by flutter_zxing; show info instead of crashing
      return Scaffold(
        appBar: AppBar(title: const Text('Scan Patient QR')),
        body: const Center(
          child: Text(
            'QR scanning is supported on Android, Windows, macOS, and Linux.\n'
            'On web, please enter patient details manually.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Patient QR'),
      ),
      body: zx.ReaderWidget(
        // Called whenever a code is detected
        onScan: (zx.Code? code) {
          if (_handled) return;
          final text = code?.text;
          if (text == null || text.isEmpty) return;

          _handled = true;
          Navigator.of(context).pop(text);
        },
        onControllerCreated: (_, Exception? error) {
          if (error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Camera error: $error')),
            );
          }
        },
        // Some sane defaults
        resolution: zx.ResolutionPreset.medium,
        lensDirection: zx.CameraLensDirection.back,
      ),
    );
  }
}
