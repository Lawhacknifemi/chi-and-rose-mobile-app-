import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'community_providers.dart';
import 'group_details_page.dart';  // Import new page
import 'post_details_page.dart';   // Import new page
import '../../../../composition_root/repositories/health_repository.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  int _selectedTab = 0;
  final List<String> _tabs = ["Trending", "Forums", "Articles"];

  // Mock Articles for now (as endpoint returns empty for now/not focus)
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
                            color: isSelected ? const Color(0xFFE91E63) : const Color(0xFFEEEEEE), 
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
                  child: _selectedTab == 0
                      ? _buildFeed()
                      : _selectedTab == 1
                          ? _buildGroupsTab()
                          : _buildArticlesTab(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: () => _showCreateOptions(context),
          backgroundColor: const Color(0xFFE91E63),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const _CreatePostSheet(),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.post_add, color: Color(0xFFE91E63)),
              title: const Text('Create Post'),
              onTap: () {
                Navigator.pop(context);
                _showCreatePostSheet(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add, color: Color(0xFFE91E63)),
              title: const Text('Create Community'),
              onTap: () {
                Navigator.pop(context);
                _showCreateGroupSheet(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const _CreateGroupSheet(),
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
              _buildCircleIcon(Icons.search),
            ],
          )
        ],
      ),
    );
  }
  // ... existing methods ...


// ... _CreatePostSheet ...



  Widget _buildFeed() {
    final feedAsync = ref.watch(communityFeedProvider);

    return feedAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text("No posts yet. Be the first to share!"));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return _buildPostCard(posts[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildGroupsTab() {
    final groupsAsync = ref.watch(communityGroupsProvider);

    return groupsAsync.when(
      data: (groups) {
        if (groups.isEmpty) {
          return const Center(child: Text("No communities yet. Create one!"));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            return _buildGroupCard(groups[index]);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildGroupCard(dynamic group) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupDetailsPage(
              groupId: group['id'],
              initialGroupData: group,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
               child: const Icon(Icons.groups, color: Color(0xFFE91E63)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group['name'] ?? 'Unnamed Group',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  if (group['description'] != null)
                    Text(
                      group['description'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                   Text(
                    "${group['memberCount'] ?? 0} members",
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
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

  Widget _buildPostCard(dynamic post) {
    final title = post['title'] ?? 'No Title';
    final groupName = post['group']?['name'] ?? 'Unknown Group'; // Accessing nested group object from API
    final commentsCount = post['commentsCount'] ?? 0;
    // Format date properly in real app
    final date = "Just now"; 

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsPage(
              postId: post['id'],
              initialPostData: post,
            ),
          ),
        );
      },
      child: Container(
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
                        GestureDetector(
                          onTap: () {
                             if (post['group']?['id'] != null) {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => GroupDetailsPage(
                                     groupId: post['group']['id'],
                                     initialGroupData: post['group'],
                                   ),
                                 ),
                               );
                             }
                          },
                          child: Text(
                            groupName,
                            style: const TextStyle(color: Color(0xFFE91E63), fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        title,
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
                       image: NetworkImage("https://picsum.photos/200"),
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
                  "$commentsCount",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Text(
                  date,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const Spacer(),
                Icon(Icons.share_rounded, size: 18, color: const Color(0xFFE91E63)),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _CreatePostSheet extends ConsumerStatefulWidget {
  const _CreatePostSheet();

  @override
  ConsumerState<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<_CreatePostSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _selectedGroupId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedGroupId != null) {
      setState(() => _isSubmitting = true);
      try {
        final repo = ref.read(healthRepositoryProvider);
        await repo.createPost(
          groupId: _selectedGroupId!,
          title: _titleController.text,
          content: _contentController.text,
        );
        
        if (mounted) {
          Navigator.pop(context);
          // Refresh feed
          ref.invalidate(communityFeedProvider);
          // Refresh specific group posts
          if (_selectedGroupId != null) {
            ref.invalidate(groupPostsProvider(_selectedGroupId!));
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post created successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating post: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(communityGroupsProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create New Post", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            // Group Selector
            groupsAsync.when(
              data: (groups) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Group',
                  border: OutlineInputBorder(),
                ),
                value: _selectedGroupId,
                items: groups.map((g) => DropdownMenuItem<String>(
                  value: g['id'] as String,
                  child: Text(g['name'] as String),
                )).toList(),
                onChanged: (val) => setState(() => _selectedGroupId = val),
                 validator: (val) => val == null ? 'Please select a group' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Error loading groups: $err'),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (val) => val == null || val.isEmpty ? 'Please enter content' : null,
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Post', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CreateGroupSheet extends ConsumerStatefulWidget {
  const _CreateGroupSheet();

  @override
  ConsumerState<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<_CreateGroupSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final repo = ref.read(healthRepositoryProvider);
        await repo.createCommunityGroup(
          name: _nameController.text,
          description: _descriptionController.text,
        );
        
        if (mounted) {
          Navigator.pop(context);
          // Refresh groups list logic would go here if we were watching it directly, 
          // or we can invalidate providers if we had a groups list provider
           ref.invalidate(communityGroupsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Community created successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating community: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Create New Community", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE91E63),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Create Community', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
