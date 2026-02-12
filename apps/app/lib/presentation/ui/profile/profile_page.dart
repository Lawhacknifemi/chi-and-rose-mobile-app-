import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/presentation/ui/period_tracker/edit_period_page.dart';
import 'package:flutter_app/presentation/ui/home/home_providers.dart';
import 'package:flutter_app/composition_root/repositories/health_repository.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileProvider);
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
             child: Image.asset(
               'assets/home_gradient_bg.png',
               fit: BoxFit.cover,
               errorBuilder: (_, __, ___) => Container(color: const Color(0xFFFDF8F9)),
             ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Header
                  userProfileAsync.when(
                    data: (profile) => _buildHeader(profile),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => _buildHeader(null),
                  ),
                  const SizedBox(height: 32),
                  
                  // My Cycle Card
                  _buildSectionTitle("My Health"),
                  const SizedBox(height: 12),
                  userProfileAsync.when(
                    data: (profile) => _buildHealthSummary(context, profile),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => _buildHealthSummary(context, null),
                  ),
                  const SizedBox(height: 32),
                  
                  // AI Personalization
                  _buildSectionTitle("AI Personalization"),
                  const SizedBox(height: 12),
                  _buildPersonalizationCard(context),
                  const SizedBox(height: 32),

                  // Settings
                  _buildSectionTitle("Settings"),
                  const SizedBox(height: 12),
                  _buildSettingsCard(),
                  
                  const SizedBox(height: 48),
                  TextButton(
                    onPressed: () {},
                    child: Text("Log Out", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic>? profile) {
    final name = profile?['name'] ?? ' Elena';
    final imageUrl = profile?['image'];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12)],
          ),
          child: CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFFF8BBD0),
            backgroundImage: imageUrl != null && imageUrl.toString().isNotEmpty 
                ? NetworkImage(imageUrl) 
                : null,
            child: imageUrl == null || imageUrl.toString().isEmpty
                ? const Icon(Icons.person, size: 48, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name.toString().trim(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE91E63).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "Premium Member",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFE91E63)),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthSummary(BuildContext context, Map<String, dynamic>? profile) {
    final conditions = (profile?['conditions'] as List?)?.length ?? 0;
    final goals = (profile?['goals'] as List?)?.length ?? 0;
    final sensitivities = (profile?['sensitivities'] as List?)?.length ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("$conditions", "Conditions"),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              _buildStatItem("$goals", "Health Goals"),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              _buildStatItem("$sensitivities", "Sensitivities"),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                 // Open Edit Profile (future)
                 context.push('/personalization');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFCE4EC),
                foregroundColor: const Color(0xFFE91E63),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Update Health Profile", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPersonalizationCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              context.push('/personalization');
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFF3E5F5), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF9C27B0), size: 20),
            ),
            title: const Text("Update Preferences", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text("Goals, Diet, Conditions", style: TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _buildSettingItem(Icons.notifications_none_rounded, "Notifications", hasSwitch: true),
          const Divider(height: 1, indent: 56, endIndent: 24, color: Color(0xFFF5F5F5)),
          _buildSettingItem(Icons.lock_outline_rounded, "Privacy & Security"),
          const Divider(height: 1, indent: 56, endIndent: 24, color: Color(0xFFF5F5F5)),
          _buildSettingItem(Icons.help_outline_rounded, "Help & Support"),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {bool hasSwitch = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFFAFAFA), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: hasSwitch 
          ? Transform.scale(
              scale: 0.8,
              child: Switch(
                value: true, 
                onChanged: (v) {}, 
                activeColor: const Color(0xFFE91E63),
                activeTrackColor: const Color(0xFFFCE4EC),
              ),
            )
          : const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
    );
  }
}
