import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'community_providers.dart';
import 'post_details_page.dart';  // Import PostDetailsPage
import '../../../../composition_root/repositories/health_repository.dart';

class GroupDetailsPage extends ConsumerStatefulWidget {
  final String groupId;
  final Map<String, dynamic>? initialGroupData;

  const GroupDetailsPage({super.key, required this.groupId, this.initialGroupData});

  @override
  ConsumerState<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends ConsumerState<GroupDetailsPage> {
  bool _isJoining = false;

  Future<void> _handleJoinLeave(bool isJoined) async {
    if (isJoined) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Leave Group?'),
          content: const Text('Are you sure you want to leave this group?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Leave', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isJoining = true);
    try {
      final repo = ref.read(healthRepositoryProvider);
      if (isJoined) {
        await repo.leaveGroup(widget.groupId);
      } else {
        await repo.joinGroup(widget.groupId);
      }
      ref.invalidate(groupDetailsProvider(widget.groupId));
      ref.invalidate(communityGroupsProvider);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(isJoined ? 'You have left the group' : 'You have joined the group')),
         );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _CreatePostSheet(groupId: widget.groupId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupDetailsProvider(widget.groupId));
    final postsAsync = ref.watch(groupPostsProvider(widget.groupId));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(groupAsync),
          SliverPadding(
             padding: const EdgeInsets.all(16),
             sliver: SliverToBoxAdapter(
               child: Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
             ),
          ),
          postsAsync.when(
            data: (posts) {
              if (posts.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text("No posts yet. Be the first!")),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildPostCard(posts[index]),
                  childCount: posts.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error loading posts: $err'))),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostSheet(context),
        backgroundColor: const Color(0xFFE91E63),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text("New Post", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSliverAppBar(AsyncValue<Map<String, dynamic>> groupAsync) {
    // Merge initial data with loaded data if available, to show something while loading
    final group = groupAsync.valueOrNull ?? widget.initialGroupData ?? {};
    final isJoined = group['isJoined'] == true;
    final name = group['name'] ?? 'Loading...';
    final description = group['description'] ?? '';
    final memberCount = group['memberCount'] ?? 0;

    return SliverAppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFFE91E63), // Fallback color
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE91E63), Color(0xFFFF80AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.groups, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
               if (description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    description,
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
               const SizedBox(height: 8),
               Text(
                "$memberCount members",
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (groupAsync.hasValue) // Only show button when data is loaded (to know isJoined status)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _isJoining
            ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
            : TextButton(
              onPressed: () => _handleJoinLeave(isJoined),
              style: TextButton.styleFrom(
                backgroundColor: isJoined ? Colors.red.withOpacity(0.1) : Colors.white,
                foregroundColor: isJoined ? Colors.red : const Color(0xFFE91E63),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: isJoined ? const BorderSide(color: Colors.red) : BorderSide.none),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(isJoined ? "Leave" : "Join"),
            ),
          )
      ],
    );
  }

  Widget _buildPostCard(dynamic post) {
    final title = post['title'] ?? 'No Title';
    final authorName = post['author']?['name'] ?? 'Unknown Member';
    final commentsCount = post['commentsCount'] ?? 0;
    
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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey[200],
                  child: Text(authorName[0].toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ),
                const SizedBox(width: 8),
                Text(authorName, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                Text("Just now", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.3),
            ),
            const SizedBox(height: 8),
            Text(
              post['content'] ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(
               children: [
                 Icon(Icons.chat_bubble_outline, size: 16, color: Colors.grey[500]),
                 const SizedBox(width: 6),
                 Text("$commentsCount comments", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
               ],
            )
          ],
        ),
      ),
    );
  }
}

class _CreatePostSheet extends ConsumerStatefulWidget {
  final String groupId;
  const _CreatePostSheet({required this.groupId});

  @override
  ConsumerState<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<_CreatePostSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      try {
        final repo = ref.read(healthRepositoryProvider);
        await repo.createPost(
          groupId: widget.groupId,
          title: _titleController.text,
          content: _contentController.text,
        );
        
        if (mounted) {
          Navigator.pop(context);
          ref.invalidate(groupPostsProvider(widget.groupId));
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
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder(), alignLabelWithHint: true),
              maxLines: 4,
              validator: (val) => val == null || val.isEmpty ? 'Please enter content' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E63)),
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
