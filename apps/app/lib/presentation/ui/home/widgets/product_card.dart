import 'package:flutter/material.dart';

class Product {
  final String imagePath;
  final String brand;
  final String hostName; // "Hollandia Yoghurt"
  final int score;
  final String date;
  final bool isSafe;

  Product({
    required this.imagePath,
    required this.brand,
    required this.hostName,
    required this.score,
    required this.date,
    required this.isSafe,
  });
}

class ProductCard extends StatelessWidget {
  final Product product;
  final double? width;
  final double? height;

  const ProductCard({
    super.key,
    required this.product,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark card background
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          // Product Image Section (Left)
          Container(
            width: 120,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Center(
              child: product.imagePath.startsWith('http')
                  ? Image.network(
                      product.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                      },
                    )
                  : Image.asset(
                      product.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                      },
                    ),
            ),
          ),
          
          // Info Section (Right)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0), // Reduced vertical padding further
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: TextStyle(
                      color: Colors.pink[200],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.hostName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6), // Reduced from 8
                  
                  // Score Row
                  Row(
                    children: [
                      _buildRadialScore(product.score),
                      const SizedBox(width: 8),
                      Text(
                        '${product.score}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 2),
                  Text(
                    'Scanned ${product.date}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                  
                  const SizedBox(height: 8), // Reduced from 12
                  _buildStatusChip(product.isSafe),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadialScore(int score) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        value: score / 100,
        backgroundColor: Colors.grey[800],
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 3,
      ),
    );
  }
  
  Widget _buildStatusChip(bool isSafe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSafe ? Icons.check_circle_outline : Icons.warning_amber_rounded,
            size: 16,
            color: isSafe ? Colors.green[800] : Colors.red[800],
          ),
          const SizedBox(width: 4),
          Text(
            isSafe ? 'Safe' : 'Caution',
            style: TextStyle(
              color: isSafe ? Colors.green[900] : Colors.red[900],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
