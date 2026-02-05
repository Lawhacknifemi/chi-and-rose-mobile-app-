import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/composition_root/repositories/scan_repository.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> product;
  final Map<String, dynamic> analysis;
  final DateTime? scannedAt;

  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.analysis,
    this.scannedAt,
    this.barcode,
  });

  final String? barcode;

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  Map<String, dynamic>? _fullDetails;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.barcode != null) {
      _fetchFullDetails();
    }
  }

  Future<void> _fetchFullDetails() async {
    setState(() => _isLoading = true);
    try {
       final fullData = await ref.read(scanRepositoryProvider).getProductDetails(widget.barcode!);
       debugPrint('ProductDetailsPage: fullData keys: ${fullData?.keys}');
       if (fullData != null && fullData['analysis'] != null) {
          final alts = fullData['analysis']['alternatives'];
          debugPrint('ProductDetailsPage: alternatives type: ${alts.runtimeType}');
          debugPrint('ProductDetailsPage: alternatives data: $alts');
       }

       if (mounted && fullData != null) {
         setState(() {
           _fullDetails = fullData;
           _isLoading = false;
         });
       } else if (mounted) {
         setState(() => _isLoading = false);
       }
    } catch(e) {
       debugPrint('Error fetching details: $e');
       if (mounted) setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final effectiveAnalysis = _fullDetails?['analysis'] ?? widget.analysis;
    final effectiveProduct = _fullDetails?['product'] ?? widget.product;

    // Data Extraction
    final productName = effectiveProduct['name'] ?? 'Unknown Product';
    final brand = effectiveProduct['brand'] ?? 'Unknown Brand';
    final imageUrl = effectiveProduct['imageUrl'];
    // Handle both key formats (History API uses 'score', Live Scan uses 'overallSafetyScore')
    final score = (effectiveAnalysis['overallSafetyScore'] ?? effectiveAnalysis['score'] ?? 0) as num; 
    final safetyLevel = effectiveAnalysis['safetyLevel'] ?? 'Caution';
    final summaries = effectiveAnalysis['summary'] ?? '';
    final ingredients = effectiveProduct['ingredients'] ?? 'No ingredients listed.';
    
    final alternatives = effectiveAnalysis['alternatives'] as List? ?? [];
    
    // Formatting Date
    final dateStr = widget.scannedAt != null 
        ? "${widget.scannedAt!.month}/${widget.scannedAt!.day}/${widget.scannedAt!.year}"
        : "Just now";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl != null)
              Container(
                width: 30, 
                height: 30,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  brand.toUpperCase(),
                  style: TextStyle(
                    color: Colors.pink[200],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {}, 
          ),
        ],
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. Background
          Positioned.fill(
             child: Image.asset(
               'assets/home_gradient_bg.png', // User requested home background
               fit: BoxFit.cover,
               errorBuilder: (_, __, ___) => Container(color: Colors.black),
             ),
          ),
          
          // 2. Content
          SafeArea(
            top: false, // Handle manually to allow background to flow, but content to clear AppBar
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 120, 16, 16), // Top padding for AppBar space
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  
                  // --- TOP CARD: Product Image & Header ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF251E22).withOpacity(0.95), // Deep Warm Plum
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        // Image
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            image: imageUrl != null 
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.contain, // Contain to show full product
                                )
                              : null,
                          ),
                          child: imageUrl == null 
                            ? const Icon(Icons.image_not_supported, size: 50, color: Colors.grey)
                            : null,
                        ),
                        const SizedBox(height: 24),
                        
                        // Brand
                        Text(
                          brand, 
                          style: TextStyle(
                            color: Colors.pink[200], // Adjust to match "CeraVe" pink in image
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Name
                        Text(
                          productName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Date
                        Text(
                          "Scanned $dateStr",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // --- BOTTOM SECTION: Analysis ---
                  // Use a semi-transparent container or just sections?
                  // Image implies a "Sheet" or separate section. 
                  // Let's wrap in a secondary dark card for cohesion.
                  
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF251E22).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating Header
                        Row(
                          children: [
                            const Text(
                              "Overall rating:",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            _buildBadge(safetyLevel),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Summary Text
                        Text(
                          summaries.isNotEmpty ? summaries : "No summary available.",
                          style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.5),
                        ),
                        
                        const SizedBox(height: 24),
                        const Divider(color: Colors.grey, height: 1),
                        
                        // Accordions
                        _buildExpandableSection("Product analysis", _buildProductAnalysisContent(effectiveAnalysis)),
                        const Divider(color: Colors.grey, height: 1),
                        _buildExpandableSection("What's inside", _buildIngredientsList(ingredients, effectiveAnalysis)),
                        const Divider(color: Colors.grey, height: 1),
                        _buildExpandableSection("Alternatives", _buildAlternativesContent(alternatives)),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String safetyLevel) {
    Color bg = Colors.yellow[700]!;
    Color text = Colors.black;
    IconData icon = Icons.sentiment_neutral;
    
    if (safetyLevel == 'Good') {
      bg = Colors.green;
      icon = Icons.check_circle;
    } else if (safetyLevel == 'Avoid') {
      bg = Colors.red;
      text = Colors.white;
      icon = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: text),
          const SizedBox(width: 6),
          Text(
            safetyLevel,
            style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(String title, Widget content) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: content,
          )
        ],
      ),
    );
  }
  
  Widget _buildProductAnalysisContent(Map<String, dynamic> analysis) {
    final riskCategories = analysis['riskCategories'];
    
    if (riskCategories == null) {
       return const Text("Detailed analysis not available.", style: TextStyle(color: Colors.grey));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         _buildRiskCategory("Carcinogens", riskCategories['carcinogens'], Icons.coronavirus_outlined),
         _buildRiskCategory("Hormone Disruptors", riskCategories['hormone_disruptors'], Icons.science_outlined),
         _buildRiskCategory("Allergens", riskCategories['allergens'], Icons.spa_outlined),
         _buildRiskCategory("Reproductive Toxicants", riskCategories['reproductive_toxicants'], Icons.pregnant_woman_outlined),
         _buildRiskCategory("Developmental Toxicants", riskCategories['developmental_toxicants'], Icons.child_care_outlined),
         _buildRiskCategory("Banned Ingredients", riskCategories['banned_ingredients'], Icons.block_outlined),
      ],
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
            top: offset.dy - 160, 
            width: 280, 
            child: Material(
              color: Colors.transparent,
              child: CustomPaint(
                 painter: _SpeechBubblePainter(color: const Color(0xFFF3E5F5)),
                 child: Container(
                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), 
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

  void _showIngredientTooltip(BuildContext context, String title, String description, GlobalKey key) {
    // Calculate position
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
            left: offset.dx - 220, // Shift left since icon is on the right
            top: offset.dy - 120, // Show above
            width: 260, 
            child: Material(
              color: Colors.transparent,
              child: CustomPaint(
                 painter: _SpeechBubblePainter(color: const Color(0xFFF3E5F5)),
                 child: Container(
                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), 
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Expanded(
                             child: Text(
                               title,
                               style: const TextStyle(color: Color(0xFF880E4F), fontSize: 16, fontWeight: FontWeight.bold),
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
                         description,
                         style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.3),
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

    final GlobalKey chipKey = GlobalKey();

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Chip (Clickable for Tooltip)
              GestureDetector(
                key: chipKey,
                onTap: () => _showCategoryTooltip(context, title, chipKey),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.transparent, 
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
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4), 
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesContent(List alternatives) {
    if (_isLoading && alternatives.isEmpty) {
       return const Padding(padding: EdgeInsets.all(8.0), child: Center(child: CircularProgressIndicator()));
    }
    if (alternatives.isEmpty) {
      return const Text("No alternatives found.", style: TextStyle(color: Colors.grey));
    }
    
    // Horizontal scroll for better visuals with images
    return SizedBox(
      height: 240, 
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: alternatives.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final alt = alternatives[index];
          final imageUrl = alt['imageUrl'];
          debugPrint("Rendering Alternative: ${alt['productName']} - Image: $imageUrl"); // Debug Log

          final name = alt['productName'] ?? 'Alternative';
          final brand = alt['brand'] ?? 'Unknown Brand';
          final reason = alt['reason'] ?? '';

          return Container(
            width: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      image: imageUrl != null 
                          ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.contain)
                          : null,
                    ),
                    child: imageUrl == null 
                        ? const Icon(Icons.image, color: Colors.grey) 
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Text
                Text(
                  brand.toUpperCase(),
                  style: TextStyle(color: Colors.pink[200], fontSize: 10, fontWeight: FontWeight.bold),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  reason,
                  style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  Widget _buildIngredientsList(String ingredientsStr, Map<String, dynamic> analysis) {
    if (ingredientsStr.isEmpty || ingredientsStr.toLowerCase().contains("no ingredients")) {
       return const Text("No ingredients listed.", style: TextStyle(color: Colors.grey));
    }

    // Parse and clean ingredients
    // Remove parentheses for matching but keep for display? 
    // The design shows "Water (Aqua)" so we keep original string but clean up splitting.
    final List<String> ingredients = ingredientsStr
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Column(
      children: ingredients.map((ing) => _buildIngredientRow(ing, analysis)).toList(),
    );
  }

  Widget _buildIngredientRow(String ingredient, Map<String, dynamic> analysis) {
    // Logic to determine status
    // Check concerns
    final concerns = analysis['concerns'] as List? ?? [];
    
    // Simple matching logic (could be improved with normalization)
    final cleanName = ingredient.toLowerCase().replaceAll(RegExp(r'\s*\(.*\)'), ''); 
    
    // Find concern
    final concern = concerns.firstWhere((c) {
       final cIng = (c['ingredient'] ?? '').toString().toLowerCase();
       return cleanName.contains(cIng) || cIng.contains(cleanName);
    }, orElse: () => null);

    String status = "Risk-Free";
    Color statusColor = Colors.greenAccent;
    
    if (concern != null) {
       final severity = concern['severity'];
       if (severity == 'Avoid') {
          status = "High Risk";
          statusColor = Colors.redAccent;
       } else {
          status = "Limited Risk"; // Caution
          statusColor = Colors.orangeAccent;
       }
    }
    
    // Check positives? (Enhancement)
    
    final GlobalKey iconKey = GlobalKey();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        children: [
          // Name
          Expanded(
            flex: 2,
            child: Text(
              ingredient,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(width: 4, height: 4, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // Icon
          GestureDetector(
             key: iconKey,
             onTap: () {
                if (concern != null) {
                   final title = concern['ingredient'] ?? ingredient;
                   final reason = concern['reason'] ?? "Contains $title which may be a concern.";
                   _showIngredientTooltip(context, title, reason, iconKey);
                } else {
                   _showIngredientTooltip(context, ingredient, "This ingredient is generally considered safe.", iconKey);
                }
             },
             child: const Icon(Icons.info_outline, color: Color(0xFFE91E63), size: 18),
          ),
        ],
      ),
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
