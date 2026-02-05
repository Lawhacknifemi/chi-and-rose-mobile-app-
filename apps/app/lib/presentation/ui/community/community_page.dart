import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int _selectedTab = 0;
  final List<String> _tabs = ["Trending", "Forums", "Articles"];

  // Mock Data
  final List<Map<String, dynamic>> _posts = [
    {
      'group': 'PCOS Support Group',
      'title': 'Best snacks for PCOS management',
      'image': 'assets/images/community_1.png', // Placeholder
      'comments': 70,
      'date': 'Today at 9:52 AM',
    },
    {
      'group': 'Clean Beauty Enthusiasts',
      'title': 'Weekly wellness thread: Share your go-to tips!',
      'image': 'assets/images/community_2.png',
      'comments': 48,
      'date': 'Yesterday at 11:28 AM',
    },
    {
      'group': 'Endo Girls Forum',
      'title': 'How I reduced symptoms of endometriosis naturally!',
      'image': 'assets/images/community_3.png',
      'comments': 34,
      'date': 'Jan 12, 2024',
    },
    {
      'group': 'PCOS Support Group',
      'title': 'My experience using herbal teas for hormonal balance',
      'image': 'assets/images/community_1.png',
      'comments': 23,
      'date': 'Jan 09, 2024',
    },
  ];

  final List<Map<String, dynamic>> _articles = [
    {
      'title': 'Ingredient Breakdown: Copper Peptides',
      'description': 'Unless you’re a huge skincare fanatic, you may have never heard of copper peptides, a natural...',
      'image': 'assets/images/article_1.png',
    },
    {
      'title': 'The Ultimate Guide to Cycle Syncing',
      'description': 'Learn how to adapt your diet and exercise to your menstrual cycle phases for better energy...',
      'image': 'assets/images/article_2.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/home_gradient_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.white),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                // Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: List.generate(_tabs.length, (index) {
                      bool isSelected = _selectedTab == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTab = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFE91E63) : const Color(0xFFEEEEEE), // Using lighter grey on gradient? Or white?
                            // Let's stick to the previous logic but maybe make unselected tabs white to stand out on gradient?
                             // Actually, 0xFFEEEEEE might look a bit muddy on a gradient. Let's use White with 0.6 opacity?
                             // User says "looks similar to this but with corrent app color scheme".
                             // Let's keep existing colors for now.
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                
                // Content
                Expanded(
                  child: _selectedTab == 2 // Articles Tab
                      ? _buildArticlesTab()
                      : _buildFeed(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Community',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Row(
            children: [
              _buildCircleIcon(Icons.add),
              const SizedBox(width: 12),
              _buildCircleIcon(Icons.search),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFeed() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(_posts[index]);
      },
    );
  }

  Widget _buildArticlesTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const Padding(
             padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
             child: Text("Top 5 ingredients list", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
           ),
           const SizedBox(height: 16),
           SizedBox(
             height: 320, // Height for the horizontal cards
             child: ListView.builder(
               padding: const EdgeInsets.only(left: 24, right: 8),
               scrollDirection: Axis.horizontal,
               itemCount: _articles.length,
               itemBuilder: (context, index) => _buildArticleCard(_articles[index]),
             ),
           ),
           
           // Extra section for demo
           const Padding(
             padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
             child: Text("Latest Research", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
           ),
           SizedBox(
             height: 320, 
             child: ListView.builder(
               padding: const EdgeInsets.only(left: 24, right: 8),
               scrollDirection: Axis.horizontal,
               itemCount: _articles.length,
               itemBuilder: (context, index) => _buildArticleCard(_articles[index]),
             ),
           ),
           const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildArticleCard(Map<String, dynamic> article) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              image: const DecorationImage(
                image: NetworkImage("https://picsum.photos/400/300"), // Web placeholder
                fit: BoxFit.cover,
              )
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article['title'], 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  article['description'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Icon(icon, color: Colors.black87, size: 20),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['group'],
                      style: const TextStyle(color: Color(0xFFE91E63), fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.3),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Thumbnail Placeholder
              Container(
                width: 80, height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                     image: NetworkImage("https://picsum.photos/200"), // Web placeholder for demo
                     fit: BoxFit.cover
                  )
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 6),
              Text(
                "${post['comments']}",
                style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 16),
              Text(
                post['date'],
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const Spacer(),
              Icon(Icons.share_rounded, size: 18, color: const Color(0xFFE91E63)),
            ],
          )
        ],
      ),
    );
  }
}
