import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/ui/common/app_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/presentation/ui/home/widgets/home_header.dart';
import 'package:flutter_app/presentation/ui/home/widgets/wellness_hero_card.dart';
import 'package:flutter_app/presentation/ui/home/widgets/product_card.dart';
import 'package:flutter_app/presentation/ui/home/widgets/article_card.dart';
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'RECENTLY SCANNED',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.0,
                            ),
                          ),
                          if (recentScansAsync.asData?.value.isNotEmpty ?? false)
                            TextButton(
                              onPressed: () {
                                GoRouter.of(context).push('/scan-history');
                              },
                              child: const Text('View History', style: TextStyle(color:  Color(0xFF8E2463))),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Recently Scanned Horizontal List
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 180, // Height of Product Card
                      child: recentScansAsync.when(
                        data: (scans) {
                          if (scans.isEmpty) {
                            return const Center(child: Text("Scan your first product!"));
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: scans.length,
                            itemBuilder: (context, index) {
                              final scan = scans[index];
                              final productData = scan['product'] ?? {};
                              final analysis = scan['analysis'] ?? {};
                              
                              final imgUrl = productData['imageUrl'];
                              debugPrint('HomePage Index $index: Name=${productData['name']}, ImageUrl=$imgUrl');

                              final product = Product(
                                imagePath: imgUrl ?? 'assets/app_icon.png', // API needs to return imageUrl
                                brand: productData['brand'] ?? 'Unknown Brand',
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
                                  width: 320,
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => const Center(child: Text("Failed to load history")),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Articles Title
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'ARTICLES CURATED FOR YOU',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.0,
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
