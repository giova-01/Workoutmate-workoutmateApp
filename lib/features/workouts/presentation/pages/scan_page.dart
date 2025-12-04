import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../config/providers/app_providers.dart';
import '../../../auth/presentation/auth_state.dart';
import '../widgets/scanned_workout_dialog.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || _hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    // Extraer el share_link del código
    String shareLink = code;

    // Si es una URL completa, extraer solo el código
    if (code.contains('/share/')) {
      shareLink = code.split('/share/').last;
    }

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
    });

    _controller?.stop();
    _fetchAndShowWorkout(shareLink);
  }

  Future<void> _fetchAndShowWorkout(String shareLink) async {
    final authState = ref.read(authNotifierProvider);
    if (authState is! AuthAuthenticated) {
      _showError('Debes iniciar sesión');
      return;
    }

    try {
      final result = await ref
          .read(qrScannerProvider.notifier)
          .getWorkoutByShareLink(shareLink);

      if (!mounted) return;

      if (result != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ScannedWorkoutDialog(
            workout: result,
            shareLink: shareLink,
            userId: authState.user.id,
            onClose: () {
              Navigator.of(context).pop();
              _resetScanner();
            },
            onSaved: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Rutina guardada exitosamente!'),
                  backgroundColor: Colors.green,
                ),
              );
              _resetScanner();
            },
          ),
        );
      } else {
        _showError('No se encontró la rutina');
      }
    } catch (e) {
      _showError('Error al obtener la rutina');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    _resetScanner();
  }

  void _resetScanner() {
    setState(() {
      _isProcessing = false;
      _hasScanned = false;
    });
    _controller?.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Escanear Rutina'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          // Instrucciones
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _isProcessing
                      ? 'Procesando...'
                      : 'Apunta al código QR de la rutina',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}