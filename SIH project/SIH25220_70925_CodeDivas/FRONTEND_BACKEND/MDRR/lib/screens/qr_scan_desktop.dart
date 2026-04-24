import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class DesktopQrScanScreen extends StatefulWidget {
  const DesktopQrScanScreen({super.key});

  @override
  State<DesktopQrScanScreen> createState() => _DesktopQrScanScreenState();
}

class _DesktopQrScanScreenState extends State<DesktopQrScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR (Desktop)")),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  void _onQRViewCreated(QRViewController c) {
    controller = c;

    controller!.scannedDataStream.listen((scanData) {
      if (!scanned) {
        scanned = true;
        Navigator.of(context).pop(scanData.code);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
