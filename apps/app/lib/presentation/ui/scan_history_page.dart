
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/presentation/ui/history/scan_history_provider.dart';
import 'package:flutter_app/presentation/ui/home/widgets/product_card.dart';

import 'package:go_router/go_router.dart';

class ScanHistoryPage extends ConsumerWidget {
  const ScanHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(scanHistoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true, // Key for transparent/blur effect
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),

        title: const Text(
          'Scan History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17, // iOS standard size usually ~17
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),

      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
             child: Image.asset(
               'assets/home_gradient_bg.png', // Consistent with Home
               fit: BoxFit.cover,
               errorBuilder: (_, __, ___) => Container(color: Colors.white),
             ),
          ),
          
          // List Content
          SafeArea(
            top: false, // We handle top padding manually for the list
            child: RefreshIndicator(
              onRefresh: () async {
                return ref.refresh(scanHistoryProvider.future);
              },
              edgeOffset: 100, // Show spinner below the app bar
              child: historyAsync.when(
                data: (scans) {
                  if (scans.isEmpty) {
                     // Empty state needs to be scrollable for Pull-to-Refresh to work always
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 150),
                        Center(child: Text("No scans yet.")),
                      ],
                    );
                  }
                  return ListView.separated(
                    // Add top padding equal to Toolbar Height + Status Bar to avoid overlap
                    padding: const EdgeInsets.fromLTRB(16, 120, 16, 32),
                    itemCount: scans.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final scan = scans[index];
                      final productData = scan['product'] ?? {};
                      final analysis = scan['analysis'] ?? {};
                      final imgUrl = productData['imageUrl'];

                      final product = Product(
                        imagePath: imgUrl ?? 'assets/app_icon.png',
                        brand: productData['brand'] ?? 'Unknown',
                        hostName: productData['name'] ?? 'Unknown Product',
                        score: (analysis['score'] as num?)?.toInt() ?? 0,
                        date: _formatDate(scan['scannedAt']),
                        isSafe: (analysis['safetyLevel'] ?? 'Caution') == 'Good',
                      );

                      return GestureDetector(
                        onTap: () {
                          context.push('/product-details', extra: {
                            'product': productData,
                            'analysis': analysis,
                            'barcode': scan['barcode'],
                            'scannedAt': DateTime.tryParse(scan['scannedAt'].toString()),
                          });
                        },
                        child: ProductCard(
                          product: product,
                          height: 180,
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.tryParse(dateStr.toString()) ?? DateTime.now();
      return "${date.month}/${date.day}/${date.year}";
    } catch (e) {
      return '';
    }
  }
}
