import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'community_providers.dart';
import '../../../../composition_root/repositories/health_repository.dart';
import 'group_details_page.dart';

class PostDetailsPage extends ConsumerStatefulWidget {
  final String postId;
  final Map<String, dynamic>? initialPostData;

  const PostDetailsPage({super.key, required this.postId, this.initialPostData});

  @override
  ConsumerState<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends ConsumerState<PostDetailsPage> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isPostingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isPostingComment = true);
    try {
      final repo = ref.read(healthRepositoryProvider);
      await repo.createComment(postId: widget.postId, content: content);
      
      _commentController.clear();
      // Refresh post details to show new comment
      ref.invalidate(postDetailsProvider(widget.postId));
      
      if (mounted) {
         // Scroll to top or just show success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error parsing comment: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPostingComment = false);
    }
  }

  Future<void> _handleUpdatePost(String title, String content) async {
    try {
      final repo = ref.read(healthRepositoryProvider);
      await repo.updatePost(postId: widget.postId, title: title, content: content);
      
      ref.invalidate(postDetailsProvider(widget.postId));
      ref.invalidate(groupPostsProvider); // Also refresh the list
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post updated successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating post: $e')));
      }
    }
  }

  void _showEditPostDialog(Map<String, dynamic> post) {
    final titleController = TextEditingController(text: post['title']);
    final contentController = TextEditingController(text: post['content']);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Post"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (value) => value!.trim().isEmpty ? "Title required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: contentController,
                decoration: const InputDecoration(labelText: "Content"),
                maxLines: 4,
                validator: (value) => value!.trim().length < 10 ? "At least 10 chars" : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _handleUpdatePost(titleController.text.trim(), contentController.text.trim());
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailsProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Post"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (postAsync.hasValue && (postAsync.value?['isAuthor'] ?? false))
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditPostDialog(postAsync.value!);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.black54, size: 20),
                      SizedBox(width: 12),
                      Text("Edit Post"),
                    ],
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert, color: Colors.black),
            ),
        ],
      ),
      body: postAsync.when(
        data: (post) {
            final comments = (post['comments'] as List?) ?? [];
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildPostHeader(post),
                      const SizedBox(height: 16),
                      Text(
                        post['content'] ?? '',
                        style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          "Comments (${comments.length})",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                        ),
                      ),
                      ...comments.map((c) => _buildCommentItem(c)),
                      if (comments.isEmpty)
                         const Padding(
                           padding: EdgeInsets.all(24.0),
                           child: Center(child: Text("No comments yet.", style: TextStyle(color: Colors.grey))),
                         ),
                    ],
                  ),
                ),
                _buildCommentInput(),
              ],
            );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildPostHeader(dynamic post) {
    final authorName = post['author']?['name'] ?? 'Unknown Member';
    final groupName = post['group']?['name'];
    
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFE91E63).withOpacity(0.1),
          child: Text(authorName[0].toUpperCase(), style: const TextStyle(color: Color(0xFFE91E63))),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            if (groupName != null)
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
                child: Text("in $groupName", style: const TextStyle(color: Color(0xFFE91E63), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const Spacer(),
        // Date could go here
      ],
    );
  }

  Widget _buildCommentItem(dynamic comment) {
    final authorName = comment['author']?['name'] ?? 'Unknown';
    final content = comment['content'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 12, 
        bottom: 12 + MediaQuery.of(context).padding.bottom
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: "Add a comment...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              minLines: 1,
              maxLines: 4,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isPostingComment ? null : _submitComment,
            icon: _isPostingComment 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Icon(Icons.send, color: Color(0xFFE91E63)),
          ),
        ],
      ),
    );
  }
}
