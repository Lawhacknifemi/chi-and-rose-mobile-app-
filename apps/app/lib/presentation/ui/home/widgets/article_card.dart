import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ArticleCard extends StatelessWidget {
  final Map<String, dynamic>? article;

  const ArticleCard({super.key, this.article});

  @override
  Widget build(BuildContext context) {
    final title = article?['title'] ?? 'The Clean Swap';
    final description = article?['category'] ?? 'Foundational toxin-free living';
    final imageUrl = article?['imageUrl']; 
    final readTime = article?['readTime'] ?? '5 MIN';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Content on the left
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lora(
                      color: const Color(0xFF333333),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF7A8D9C),
                      fontSize: 12,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text(
                        readTime,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFFB0BEC5),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Thumbnail on the right
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imageUrl != null 
                  ? Image.network(
                      imageUrl, 
                      fit: BoxFit.cover, 
                      height: double.infinity, 
                      errorBuilder: (_,__,___) => Container(color: Colors.grey.shade100)
                    ) 
                  : Image.asset(
                      'assets/background.png', // Placeholder
                      fit: BoxFit.cover,
                      height: double.infinity,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
