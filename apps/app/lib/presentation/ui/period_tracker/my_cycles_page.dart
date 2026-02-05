import 'package:flutter/material.dart';
import 'package:flutter_app/presentation/ui/period_tracker/edit_period_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyCyclesPage extends ConsumerWidget {
  const MyCyclesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          // Background (Using same gradient asset as others)
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
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildMainCard(context),
                        const SizedBox(height: 24),
                        // Edit button is now inside Main Card
                        
                        _buildMoodsCard(),
                        const SizedBox(height: 24),
                        _buildPhasesSection(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFC06C84), size: 20),
            ),
          ),
          const Text(
            'My Cycles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 44), // Placeholder for balance
        ],
      ),
    );
  }

  Widget _buildMainCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildStatBlock(
                  value: '4 days',
                  label: 'Average period',
                  icon: Icons.water_drop,
                  iconColor: const Color(0xFFE53935), // Deep Red
                  bgColor: const Color(0xFFEEEEEE), // Light Grey
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatBlock(
                  value: '28 days',
                  label: 'Average cycle',
                  icon: Icons.calendar_month,
                  iconColor: const Color(0xFF7986CB), // Periwinkle
                  bgColor: const Color(0xFFEEEEEE),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildEditButton(context),
        ],
      ),
    );
  }

  Widget _buildStatBlock({required String value, required String label, required IconData icon, required Color iconColor, required Color bgColor}) {
    return Container(
      height: 140, // Fixed height for square-ish look
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4), // Slightly less rounded than card? Design shows squarish internal blocks. Let's go with 12.
        // Actually screenshot shows 0? No, maybe 4-8.
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Icon(icon, size: 48, color: iconColor), // Large icon at bottom right
          )
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54, // Slightly taller
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const EditPeriodPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8B6CC), // Soft Pink
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
        ),
        child: const Text('Edit Period', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildMoodsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Moods', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLargeMoodItem('Neutral', Icons.sentiment_neutral, true, const Color(0xFFE8B6CC)),
              _buildLargeMoodItem('Happy', Icons.sentiment_satisfied_alt, false, Colors.transparent),
              _buildLargeMoodItem('Sad', Icons.sentiment_dissatisfied, false, Colors.transparent),
              _buildLargeMoodItem('Sensitive', Icons.sentiment_very_dissatisfied, false, Colors.transparent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLargeMoodItem(String label, IconData icon, bool isSelected, Color activeColor) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? activeColor : Colors.grey.shade300, width: 2),
              ), 
              child: Icon(icon, color: isSelected ? Colors.white : Colors.pinkAccent.shade100, size: 32),
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, size: 16, color: Color(0xFFE8B6CC)), 
                ),
              )
          ],
        ),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPhasesSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildPhaseCard('01', 'Menstruation', const Color(0xFFFF0062))),
        const SizedBox(width: 16),
        Expanded(child: _buildPhaseCard('02', 'Follicle phase', const Color(0xFFF8BBD0))),
      ],
    );
  }

  Widget _buildPhaseCard(String number, String title, Color color) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          const Spacer(),
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2), // Light circle bg
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.spa, color: color, size: 50), // Increased icon size
            ),
          ),
        ],
      ),
    );
  }
}
