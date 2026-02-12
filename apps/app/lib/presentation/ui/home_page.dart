import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/ui/common/app_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/presentation/ui/home/widgets/home_header.dart';
import 'package:flutter_app/presentation/ui/home/widgets/wellness_hero_card.dart';
import 'package:flutter_app/presentation/ui/home/widgets/product_card.dart';
import 'package:flutter_app/presentation/ui/home/widgets/article_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_app/presentation/ui/home/widgets/ai_chat_bottom_sheet.dart';

import 'package:flutter_app/presentation/ui/home/home_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyInsightAsync = ref.watch(dailyInsightProvider);
    final recentScansAsync = ref.watch(recentScansProvider);
    final feedAsync = ref.watch(wellnessFeedProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // New Background Image provided by user
          Positioned.fill(
            child: Image.asset(
              'assets/home_gradient_bg.png', // Assuming user asset name
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.white), // Fallback
            ),
          ),

          // Main Scrollable Content
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                // Trigger refreshes and wait for them to complete so spinner disappears only when done
                await Future.wait([
                  ref.refresh(dailyInsightProvider.future),
                  ref.refresh(recentScansProvider.future),
                  ref.refresh(wellnessFeedProvider.future),
                ]);
              },
              child: CustomScrollView(
                slivers: [
                  // Header with Search
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                  const SliverToBoxAdapter(
                    child: HomeHeader(),
                  ),
                  
                  // Daily Insight / Hero Card
                  SliverToBoxAdapter(
                    child: dailyInsightAsync.when(
                      data: (data) => WellnessHeroCard(
                        title: data['title'],
                        message: data['message'],
                        tip: data['actionableTip'],
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16.0),
                         child: Center(child: CircularProgressIndicator()), // Or Skeleton
                      ),
                      error: (err, stack) => const WellnessHeroCard(
                         title: "Welcome Back",
                         message: "Connect to the internet to see your insights.",
                      )
                    ),
                  ),

                  // Recently Scanned Section Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'RECENTLY SCANNED',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFB0BEC5),
                              letterSpacing: 1.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push('/scan-history'),
                            child: Text(
                              'HISTORY',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF333333),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Recently Scanned Single Item
                  SliverToBoxAdapter(
                    child: recentScansAsync.when(
                      data: (scans) {
                        if (scans.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text("Scan your first product!"),
                            ),
                          );
                        }
                        
                        // Show only the single latest scan
                        final scan = scans.first;
                        final productData = scan['product'] ?? {};
                        final analysis = scan['analysis'] ?? {};
                        
                        final product = Product(
                          imagePath: productData['imageUrl'] ?? 'assets/app_icon.png',
                          brand: productData['brand'] ?? 'Unknown',
                          hostName: productData['name'] ?? 'Unknown Product',
                          score: (analysis['score'] as num?)?.toInt() ?? 0,
                          date: _formatDate(scan['scannedAt']),
                          isSafe: (analysis['safetyLevel'] ?? 'Caution') == 'Good',
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: GestureDetector(
                            onTap: () {
                              context.push('/product-details', extra: {
                                'product': productData,
                                'analysis': analysis,
                                'barcode': scan['barcode'],
                                'scannedAt': DateTime.tryParse(scan['scannedAt'].toString()),
                              });
                            },
                            child: ProductCard(product: product),
                          ),
                        );
                      },
                      loading: () => const Center(child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: CircularProgressIndicator(),
                      )),
                      error: (err, stack) => const Center(child: Text("Failed to load history")),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Tips & Insights Section Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: Text(
                        'CURATED FOR YOU',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB0BEC5),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  
                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // Article Card List
                  SliverToBoxAdapter(
                    child: feedAsync.when(
                      data: (articles) {
                         // Build vertical list of articles (just take first few or use Column)
                         if (articles.isEmpty) {
                           return const Padding(
                             padding: EdgeInsets.all(16.0),
                             child: Center(
                               child: Text(
                                 "No articles found. Check back later!",
                                 style: TextStyle(color: Colors.grey),
                               ),
                             ),
                           );
                         }
                         return Column(
                           children: articles.map<Widget>((article) {
                             return GestureDetector(
                               onTap: () {
                                 final id = article['id'];
                                 context.push('/article-details/$id', extra: article);
                               },
                               child: ArticleCard(article: article),
                             );
                           }).toList(),
                         );
                      },
                      loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
                      error: (_, __) => const ArticleCard(), // Fallback
                    ),
                  ),
                  
                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
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
