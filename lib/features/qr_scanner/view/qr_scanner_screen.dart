import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../visitors/viewmodels/visitor_view_model.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();

  bool _isProcessing = false;
  String? _message;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final String? code = capture.barcodes
        .firstWhere(
          (barcode) => barcode.rawValue != null,
          orElse: () => Barcode(rawValue: null),
        )
        .rawValue;

    if (code == null || code.trim().isEmpty) return;

    final viewModel = context.read<VisitorViewModel>();

    setState(() {
      _isProcessing = true;
      _message = 'Looking up visitor...';
    });

    await _scannerController.stop();

    try {
      final visitor = await viewModel.getVisitorById(code.trim());

      if (!mounted) return;

      await context.push('/visitor-details', extra: visitor);

      if (!mounted) return;

      setState(() {
        _isProcessing = false;
        _message = null;
      });

      await _scannerController.start();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _message = 'Visitor not found. Please scan a valid visitor QR code.';
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to find visitor: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await _scannerController.start();
    }
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Visitor QR'),
        actions: [
          IconButton(
            tooltip: 'Toggle camera',
            onPressed: () => _scannerController.switchCamera(),
            icon: const Icon(Icons.cameraswitch),
          ),
          IconButton(
            tooltip: 'Flashlight',
            onPressed: () => _scannerController.toggleTorch(),
            icon: const Icon(Icons.flash_on),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                  errorBuilder: (context, error) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.camera_alt_outlined,
                              size: 48,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Camera Access Required',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Please grant camera permission in your system settings to scan visitor QR codes.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.greenAccent, width: 4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                if (_isProcessing)
                  Container(
                    color: Colors.black54,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.qr_code_scanner, size: 40, color: Colors.blue),
                const SizedBox(height: 12),
                Text(
                  _message ??
                      'Place the visitor QR code inside the scanning frame.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                if (_isProcessing)
                  const LinearProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        setState(() => _message = null);
                        await _scannerController.start();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Scan Again'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
