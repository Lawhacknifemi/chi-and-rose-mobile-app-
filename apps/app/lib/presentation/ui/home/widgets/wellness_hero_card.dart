import 'package:flutter/material.dart';

class WellnessHeroCard extends StatelessWidget {
  final String? title;
  final String? message;
  final String? tip;

  const WellnessHeroCard({
    super.key,
    this.title,
    this.message,
    this.tip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFE59BC5), Color(0xFFEBBAD9)], // Custom Linear Gradient
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Banner Image (Woman) on the right
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Image.asset(
                'assets/banner_image.png',
                fit: BoxFit.cover,
                // Adjust alignment if needed depending on the image aspect ratio
                alignment: Alignment.centerRight,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),

          // Text Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text Content
                SizedBox(
                  width: 200, // Limit width so it doesn't overlap image
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        fontFamily: 'Outfit', // Ensure font matches app
                      ),
                      children: [
                        TextSpan(
                          text: title ?? 'Daily Insight\n',
                          style: const TextStyle(color: Color(0xFF900759), fontSize: 18),
                        ),
                        TextSpan(
                          text: message ?? 'Check your personalization settings to get started!',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8E2463),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Recommendations'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
