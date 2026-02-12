import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Product {
  final String imagePath;
  final String brand;
  final String hostName; 
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
      width: width ?? double.infinity,
      height: 100,
      margin: const EdgeInsets.fromLTRB(0, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product Thumbnail
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(8),
              child: Center(
                child: product.imagePath.startsWith('http')
                    ? Image.network(
                        product.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(Icons.shopping_bag_outlined, color: Colors.grey.shade400),
                      )
                    : Image.asset(
                        product.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(Icons.shopping_bag_outlined, color: Colors.grey.shade400),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.brand.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFB0BEC5), // Slate Blue Grey
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.hostName,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF333333),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildStatusChip(product.isSafe),
                ],
              ),
            ),
            const SizedBox(width: 12), // Added gap for long names
            
            // Score Section
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        value: product.score / 100,
                        backgroundColor: Colors.grey.shade100,
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          product.isSafe ? const Color(0xFFC04E7D) : const Color(0xFFE57373),
                        ),
                      ),
                    ),
                    Text(
                      '${product.score}',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'SCORE',
                  style: GoogleFonts.outfit(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFB0BEC5),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isSafe) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSafe ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isSafe ? 'Excellent' : 'Caution',
        style: GoogleFonts.outfit(
          color: isSafe ? const Color(0xFF4CAF50) : const Color(0xFFE57373),
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}
