
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app/presentation/ui/discover/discover_providers.dart';
import 'package:flutter_app/presentation/ui/discover/widgets/vertical_product_card.dart';
import 'package:go_router/go_router.dart';

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discoverAsync = ref.watch(discoverFeedProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient (Matched to Home)
          Positioned.fill(
            child: Image.asset(
              'assets/home_gradient_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.white),
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header Row: Back Button (if possible) + "Discover" + Search Icon
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 24, 0),
                    child: Row(
                      children: [
                        if (Navigator.canPop(context))
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
                            onPressed: () => context.pop(),
                          ),
                        const Expanded(
                          child: Text(
                            'Discover',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.black, size: 28),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search product or brand',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                ),

                // Sections
                discoverAsync.when(
                  data: (recs) {
                    if (recs.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Text("Scan products to get recommendations!", style: TextStyle(color: Colors.grey)),
                        ),
                      );
                    }
                    
                    // Split recommendations into groups for the 3 sections shown in UI
                    final topPicks = recs.take(3).toList();
                    final related = recs.skip(3).take(3).toList();
                    final community = recs.skip(6).toList();

                    return SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSection(
                          context, 
                          'Top picks for you', 
                          'Personalized AI recommendations tailored to your health needs and preferences.',
                          topPicks,
                        ),
                        const SizedBox(height: 32),
                        _buildSection(
                          context, 
                          'Related to your scans', 
                          'Recommendations powered by AI, based on your previously scanned products.',
                          related.isEmpty ? topPicks : related, // Fallback if list is short
                        ),
                        const SizedBox(height: 32),
                        _buildSection(
                          context, 
                          'Popular in your community', 
                          'Products trending among other users with similar conditions or preferences.',
                          community.isEmpty ? topPicks : community, // Fallback
                        ),
                        const SizedBox(height: 120), // Bottom padding for nav
                      ]),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => SliverFillRemaining(
                    child: Center(child: Text("Error: $err")),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String subtitle, List<dynamic> products) {
    if (products.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300, // Adjusted for VerticalProductCard height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final p = products[index];
              return GestureDetector(
                onTap: () {
                   // Navigate to details if barcode exists in data or just show info
                   if (p['barcode'] != null) {
                      context.push('/product-details', extra: {
                        'product': p,
                        'analysis': {'score': 90, 'safetyLevel': 'Safe'},
                        'barcode': p['barcode'],
                      });
                   }
                },
                child: VerticalProductCard(
                  imagePath: p['imageUrl'] ?? 'assets/app_icon.png',
                  brand: p['brand'] ?? 'Unknown',
                  name: p['productName'] ?? 'Unknown Product',
                  score: 90,
                  isSafe: true,
                  safetyLevel: 'Safe',
                  width: 180,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
