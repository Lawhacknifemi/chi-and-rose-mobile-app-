import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  final Map<String, dynamic>? article;

  const ArticleCard({super.key, this.article});

  @override
  Widget build(BuildContext context) {
    final title = article?['title'] ?? 'Ingredient Breakdown:\nCopper Peptides';
    final description = article?['category'] ?? 'Wellness'; // We use category as sub-text for now or description if available
    final imageUrl = article?['imageUrl']; 

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Light purple background
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Row(
            children: [
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
                        style: const TextStyle(
                          color: Color(0xFF8E2463), // Dark purple/pink
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                       if (article?['readTime'] != null)
                        Text(
                          article!['readTime'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: imageUrl != null 
                    ? Image.network(imageUrl, fit: BoxFit.cover, height: double.infinity, errorBuilder: (_,__,___) => Container(color: Colors.grey[300])) 
                    : Image.asset(
                        'assets/background.png', // Placeholder
                        fit: BoxFit.cover,
                        height: double.infinity,
                      ),
                ),
              ),
            ],
          ),
          
          // Floating Robot Icon (simulated)
          Positioned(
            top: -10,
            right: 80, 
            child: Container(
               // In a real implementation this would be precisely aligned
               // This layout is a bit tricky with standard widgets, might need a Stack overlapping the container
            ),
          ),
        ],
      ),
    );
  }
}
