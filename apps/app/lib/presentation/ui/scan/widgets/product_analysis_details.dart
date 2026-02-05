import 'package:flutter/material.dart';
import 'dart:ui';

class ProductAnalysisDetails extends StatelessWidget {
  final Map<String, dynamic> product;
  final Map<String, dynamic> analysis;
  final VoidCallback? onScanAgain; // Optional, maybe hide button if null
  final bool showScanAgainButton;

  const ProductAnalysisDetails({
    super.key,
    required this.product,
    required this.analysis,
    this.onScanAgain,
    this.showScanAgainButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final safetyLevel = analysis['safetyLevel'] ?? "Unknown";
    final score = analysis['overallSafetyScore'] ?? 0;
    
    Color scoreColor = Colors.green;
    if (safetyLevel == "Caution") scoreColor = Colors.orange;
    if (safetyLevel == "Avoid") scoreColor = Colors.red;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header actions
            if (showScanAgainButton && onScanAgain != null)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onScanAgain,
                ),
              ),
            
            // Score Circle
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: scoreColor, width: 8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "$score",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: scoreColor),
                      ),
                      Text(
                        safetyLevel,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: scoreColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Product Image (if available)
            if (product['imageUrl'] != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product['imageUrl'],
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),

            // Product Details
            Text(
              product['name'] ?? "Unknown Product",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (product['brand'] != null)
              Text(
                product['brand'],
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            
            const SizedBox(height: 24),
            
            // Summary
            // NEW: Product Analysis (Risk Categories)
            if (analysis['riskCategories'] != null) ...[
               const Text("Product analysis", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
               const SizedBox(height: 16),
               
               _buildRiskCategory(
                 "Carcinogens", 
                 analysis['riskCategories']['carcinogens'], 
                 Icons.coronavirus_outlined
               ),
               _buildRiskCategory(
                 "Hormone Disruptors", 
                 analysis['riskCategories']['hormone_disruptors'], 
                 Icons.science_outlined 
               ),
              _buildRiskCategory(
                 "Allergens", 
                 analysis['riskCategories']['allergens'], 
                 Icons.spa_outlined 
               ),
               _buildRiskCategory(
                 "Reproductive Toxicants", 
                 analysis['riskCategories']['reproductive_toxicants'], 
                 Icons.pregnant_woman_outlined 
               ),
               _buildRiskCategory(
                 "Developmental Toxicants", 
                 analysis['riskCategories']['developmental_toxicants'], 
                 Icons.child_care_outlined 
               ),
               _buildRiskCategory(
                 "Banned Ingredients", 
                 analysis['riskCategories']['banned_ingredients'], 
                 Icons.block_outlined 
               ),
               const SizedBox(height: 24),
               const Divider(),
               const SizedBox(height: 24),
            ],

            // Legacy Summary (Fallback)
            if (analysis['riskCategories'] == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  analysis['summary'] ?? "No summary available.",
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
            
            const SizedBox(height: 24),

            // "What's inside" (Ingredients List)
            const Text("What's inside", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildIngredientList(context, product['ingredients'], analysis['concerns']),

            const SizedBox(height: 32),
            if (showScanAgainButton && onScanAgain != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onScanAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Scan Another Product"),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientList(BuildContext context, String? ingredientsRaw, List<dynamic>? concerns) {
    if (ingredientsRaw == null || ingredientsRaw.isEmpty) {
      return const Text("Ingredients not available.");
    }

    // Split and cleanup ingredients
    final List<String> ingredients = ingredientsRaw
        .split(',')
        .map((e) => e.trim().replaceAll(RegExp(r'[\(\)]'), '')) // Simple cleanup
        .where((e) => e.isNotEmpty)
        .toList();

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: ingredients.map((ing) {
        // Find matching concern (fuzzy match)
        final match = concerns?.firstWhere(
          (c) => (c['ingredient'] as String).toLowerCase().contains(ing.toLowerCase()) || 
                 ing.toLowerCase().contains((c['ingredient'] as String).toLowerCase()),
          orElse: () => null,
        );

        final isConcern = match != null;
        final severity = isConcern ? match['severity'] : null;
        final isAvoid = severity == "Avoid";
        
        Color chipColor = Colors.grey[100]!;
        Color textColor = Colors.black87;
        
        if (isConcern) {
          chipColor = isAvoid ? Colors.red[50]! : Colors.orange[50]!;
          textColor = isAvoid ? Colors.red[700]! : Colors.orange[800]!;
        }

        return ActionChip(
          label: Text(ing),
          labelStyle: TextStyle(color: textColor, fontWeight: isConcern ? FontWeight.bold : FontWeight.normal),
          backgroundColor: chipColor,
          side: isConcern ? BorderSide(color: isAvoid ? Colors.red[200]! : Colors.orange[200]!) : BorderSide.none,
          onPressed: () {
            // Show Tooltip/Insight
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(isConcern ? (match['ingredient'] ?? ing) : ing),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isConcern) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAvoid ? Colors.red : Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          severity ?? "Caution",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(match['reason'] ?? "No specific details."),
                    ] else ...[
                      Container(
                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                         decoration: BoxDecoration(
                           color: Colors.green,
                           borderRadius: BorderRadius.all(Radius.circular(4)),
                         ),
                         child: Text("Safe", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                       const SizedBox(height: 12),
                       const Text("This ingredient does not match any known toxicity rules or personal constraints based on your profile."),
                    ]
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // Definitions for Tooltips
  static const Map<String, String> _categoryDefinitions = {
    "Carcinogens": "Substances that have been scientifically linked to an increased risk of cancer over time.",
    "Hormone Disruptors": "Chemicals that can interfere with endocrine (or hormonal) systems. These substances can mimic or block natural hormones.",
    "Allergens": "Ingredients capable of triggering an immune response, resulting in an allergic reaction in sensitive individuals.",
    "Reproductive Toxicants": "Substances that may interfere with sexual function and fertility in adults.",
    "Developmental Toxicants": "Agents that can cause adverse effects on the developing organism (embryo or fetus) before conception, during prenatal development, or postnatally.",
    "Banned Ingredients": "Ingredients effectively prohibited by regulatory authorities due to safety concerns or potential health risks.",
  };

  void _showCategoryTooltip(BuildContext context, String title, GlobalKey key) {
    final definition = _categoryDefinitions[title] ?? "No definition available.";
    
    // Calculate position
    // Handle case where context might be null if called too early, though onTap should be safe
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final offset = renderBox.localToGlobal(Offset.zero);

    OverlayEntry? entry;
    
    entry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Blur Background
          Positioned.fill(
             child: GestureDetector(
               onTap: () => entry?.remove(),
               child: BackdropFilter(
                 filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                 child: Container(color: Colors.black.withOpacity(0.3)),
               ),
             ),
          ),
          
          // Tooltip Bubble
          Positioned(
            left: offset.dx, 
            top: offset.dy - 160, // approximate height above, adjusted dynamically ideally
            width: 280, // Reduced width as requested "too big"
            child: Material(
              color: Colors.transparent,
                child: CustomPaint(
                   painter: _SpeechBubblePainter(color: const Color(0xFFF3E5F5)),
                   child: Container(
                     padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // Extra bottom padding for arrow
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                             Expanded(
                               child: Text(
                                 title,
                                 style: const TextStyle(color: Color(0xFF880E4F), fontSize: 18, fontWeight: FontWeight.bold),
                               ),
                             ),
                             GestureDetector(
                               onTap: () => entry?.remove(),
                               child: const Icon(Icons.close, size: 20, color: Color(0xFF880E4F)),
                             )
                           ],
                         ),
                         const SizedBox(height: 8),
                         Text(
                           definition,
                           style: const TextStyle(color: Colors.black87, fontSize: 15, height: 1.3),
                         ),
                       ],
                     ),
                   ),
                ),
              ),
            ),
          ],
      ),
    );

    Overlay.of(context).insert(entry);
  }

  Widget _buildRiskCategory(String title, dynamic data, IconData icon) {
    if (data == null) return const SizedBox.shrink();
    
    final status = data['status'] ?? "Unknown";
    final description = data['description'] ?? "No data available";
    final isSafe = status == "Safe" || status == "Good" || status == "Risk-Free";
    
    final Color categoryColor = const Color(0xFFE91E63);
    final Color statusColor = isSafe ? Colors.greenAccent : (status == "Limit Risk" || status == "Caution" ? Colors.orangeAccent : Colors.redAccent);

    // Key to find render info for tooltip positioning
    final GlobalKey chipKey = GlobalKey();

    return Builder( 
      builder: (context) => Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            mainAxisSize: MainAxisSize.min, 
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. The Category Chip - Clickable
              GestureDetector(
                key: chipKey,
                onTap: () => _showCategoryTooltip(context, title, chipKey),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    // color: const Color(0xFF1E1E1E), // REMOVED FILL as requested
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[800]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 18, color: categoryColor),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Status
              Text("•", style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
              const SizedBox(width: 6),
              Text(
                isSafe ? "Risk-Free" : status, 
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4), // Lighter text
          ),
        ],
      ),
      )
    );
  }
}

class _SpeechBubblePainter extends CustomPainter {
  final Color color;
  _SpeechBubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path();
    
    const double arrowHeight = 10;
    const double arrowWidth = 20;
    final double w = size.width;
    final double h = size.height - arrowHeight;
    final double r = 12; // radius

    // Bubble Body
    path.moveTo(r, 0);
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r);
    path.lineTo(w, h - r);
    path.quadraticBezierTo(w, h, w - r, h);
    
    // Arrow (Sharp tail on the left side)
    const double arrowX = 20.0;
    path.lineTo(arrowX + arrowWidth, h); 
    path.lineTo(arrowX + (arrowWidth / 2), h + arrowHeight); // Sharp Tip
    path.lineTo(arrowX, h);
    
    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
