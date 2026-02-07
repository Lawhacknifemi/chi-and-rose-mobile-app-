import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_app/composition_root/repositories/scan_repository.dart';
import 'package:flutter_app/presentation/ui/details/product_details_page.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as google_mlkit;

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> with WidgetsBindingObserver {
  bool _isScanning = true;
  bool _isLoading = false;
  Map<String, dynamic>? _scanResult;
  String? _errorMessage;

  final MobileScannerController _controller = MobileScannerController();
  final ImagePicker _picker = ImagePicker();

  int _loadingMessageIndex = 0;
  Timer? _loadingTimer;
  final List<String> _loadingMessages = [
    "Analyzing image...",
    "Identifying barcode...",
    "Fetching product details...",
    "Checking ingredients...",
    "Almost there...",
  ];

  void _startLoadingTimer() {
    _stopLoadingTimer();
    setState(() {
      _loadingMessageIndex = 0;
    });
    _loadingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _loadingMessageIndex = (_loadingMessageIndex + 1) % _loadingMessages.length;
        });
      }
    });
  }

  void _stopLoadingTimer() {
    _loadingTimer?.cancel();
    _loadingTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.start();
    }
    super.didChangeAppLifecycleState(state);
  }

  final TextEditingController _manualController = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
    _stopLoadingTimer();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _isScanning = false;
        _isLoading = true;
        _errorMessage = null;
      });
      _startLoadingTimer();

      // Use Google ML Kit directly for better static image analysis
      final inputImage = google_mlkit.InputImage.fromFilePath(image.path);
      final barcodeScanner = google_mlkit.BarcodeScanner(formats: [google_mlkit.BarcodeFormat.all]);
      
      try {
        final barcodes = await barcodeScanner.processImage(inputImage);
        
        if (barcodes.isNotEmpty) {
          final barcode = barcodes.first.rawValue;
          if (barcode != null) {
            await barcodeScanner.close();
            await _processBarcode(barcode);
            return;
          }
        }
      } finally {
        await barcodeScanner.close();
      }

      // Fallback: If local scan failed, try server-side detection
      if (mounted) {
         final serverResult = await ref.read(scanRepositoryProvider).detectBarcodeFromImage(File(image.path));
         if (serverResult != null && serverResult['barcode'] != null) {
            await _processBarcode(serverResult['barcode']);
            return; // Exit here if successful
         }
      }

      _stopLoadingTimer();
      setState(() {
        _isLoading = false;
        _errorMessage = "No barcode found in the image. Please try again or enter manually.";
      });
    } catch (e) {
      _stopLoadingTimer();
      setState(() {
        _isLoading = false;
        _errorMessage = "Error picking image: $e";
      });
    }
  }


  Future<void> _onDetect(BarcodeCapture capture) async {
    if (!_isScanning || _isLoading) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first.rawValue;
    if (barcode == null) return;

    await _processBarcode(barcode);
  }

  void _resetScan() {
    setState(() {
      _isScanning = true;
      _scanResult = null;
      _errorMessage = null;
    });
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_isScanning)
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),
          
          // Overlay UI
          if (_isScanning)
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.flash_on, color: Colors.white),
                          onPressed: () => _controller.toggleTorch(),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.image, color: Colors.white),
                              onPressed: _pickImage,
                            ),
                            IconButton(
                              icon: const Icon(Icons.cameraswitch, color: Colors.white),
                              onPressed: () => _controller.switchCamera(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Point camera at a barcode",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        const Text("- OR -", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _manualController,
                          decoration: InputDecoration(
                            hintText: "Enter Barcode Manually (Debug)",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey[100],
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send, color: Color(0xFFE91E63)),
                              onPressed: () {
                                if (_manualController.text.isNotEmpty) {
                                  _controller.stop();
                                  _processBarcode(_manualController.text);
                                }
                              }, 
                            ),
                          ),
                          onSubmitted: (value) async {
                              if (value.isNotEmpty) {
                                  _controller.stop();
                                  _processBarcode(value); 
                              }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Result / Loading UI
          if (_isLoading || _scanResult != null || _errorMessage != null)
            Container(
              color: const Color(0xFFF3E6F4), // App Background Color
              width: double.infinity,
              height: double.infinity,
              child: _buildResultContent(),
            ),
        ],
      ),
    );
  }

  Future<void> _processBarcode(String barcode) async {
    setState(() {
      _isScanning = false;
      _isLoading = true;
      _errorMessage = null;
    });
    _startLoadingTimer();

    try {
      final result = await ref.read(scanRepositoryProvider).scanBarcode(barcode);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _stopLoadingTimer();
          _scanResult = result;
          if (result == null || result['found'] != true) {
             _errorMessage = "Product not found.";
          }
        });

        if (result != null && result['found'] == true) {
            Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => ProductDetailsPage(
                        product: result['product'],
                        analysis: result['analysis'],
                        scannedAt: DateTime.now(),
                        barcode: barcode,
                    ),
                ),
            ).then((_) => _resetScan());
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _stopLoadingTimer();
          _errorMessage = "Error scanning: $e";
        });
      }
    }
  }

  Widget _buildResultContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/rippleloading.json',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                _loadingMessages[_loadingMessageIndex],
                key: ValueKey<String>(_loadingMessages[_loadingMessageIndex]),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _resetScan,
                child: const Text("Scan Again"),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink(); 
  }
}

