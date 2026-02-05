import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_app/presentation/ui/home/home_providers.dart';
import 'package:go_router/go_router.dart';

class ArticleDetailsPage extends ConsumerWidget {
  final String articleId;
  final Map<String, dynamic>? initialData;

  const ArticleDetailsPage({
    super.key,
    required this.articleId,
    this.initialData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If we have initial data (from the list), we can show it while loading the full content.
    // However, the list data usually doesn't have the 'content' field.
    // So we fetch the full details using the provider.
    final articleAsync = ref.watch(articleDetailsProvider(articleId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 250,
            leading: IconButton(
              icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: Colors.black)),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroImage(initialData?['imageUrl']),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    initialData?['title'] ?? 'Loading Article...',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Metadata
                  Row(
                    children: [
                      _buildChip(initialData?['category'] ?? 'Health', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                      const SizedBox(width: 12),
                      if (initialData?['readTime'] != null)
                        Text(
                          initialData!['readTime'],
                          style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 24),

                  // Content Body
                  articleAsync.when(
                    data: (article) {
                      debugPrint('ArticleDetailsPage: Loaded article data: $article');
                      if (article == null) {
                         return const Center(child: Text("Article not found"));
                      }
                      final content = article['content'];
                      debugPrint('ArticleDetailsPage: Content length: ${content?.length}');
                      debugPrint('ArticleDetailsPage: Content preview: ${content?.substring(0, content.length > 50 ? 50 : content.length)}');
                      
                      if (content == null || content.isEmpty) {
                          return const Text("No content available (empty string)");
                      }
                      
                      return MarkdownBody(
                        data: content,
                        styleSheet: MarkdownStyleSheet(
                          p: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF4A4A4A)),
                          h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                          h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                          h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          blockquote: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic),
                          blockquoteDecoration: BoxDecoration(
                              color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border(left: BorderSide(color: Colors.grey[400]!, width: 4))),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error loading content: $err')),
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(String? imageUrl) {
    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset('assets/home_gradient_bg.png', fit: BoxFit.cover),
      );
    }
    return Image.asset('assets/home_gradient_bg.png', fit: BoxFit.cover);
  }
  
  Widget _buildChip(String label, Color bg, Color text) {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
          child: Text(label, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w600)),
      );
  }
}
