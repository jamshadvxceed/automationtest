import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product_model.dart';
import '../utils/app_colors.dart';
import '../controllers/product_controller.dart';
import '../routes/app_routes.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    ProductController? productController;
    try {
      productController = Get.find<ProductController>();
    } catch (e) {
      // ProductController not found, use null
      productController = null;
    }

    return GestureDetector(
      key: Key('product_card_${product.id}'),
      onTap: onTap ?? () => AppRoutes.toProductDetail(product.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Hero animation and favorite button
            AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: [
                  Hero(
                    tag: 'product-${product.id}',
                    child: Container(
                      key: Key('product_image_${product.id}'),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surface,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surface,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: AppColors.textLight,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: productController != null
                        ? Obx(() {
                            final isFavorite = productController!.allProducts
                                .firstWhere(
                                  (p) => p.id == product.id,
                                  orElse: () => product,
                                )
                                .isFavorite;

                            return GestureDetector(
                              key: Key('favorite_button_${product.id}'),
                              onTap: () =>
                                  productController!.toggleFavorite(product.id),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  size: 18,
                                ),
                              ),
                            );
                          })
                        : GestureDetector(
                            key: Key('favorite_button_${product.id}'),
                            onTap: () {
                              // Fallback when controller not available
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                product.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: product.isFavorite
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                size: 18,
                              ),
                            ),
                          ),
                  ),
                  // Discount badge
                  if (product.discountPercentage > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.discount,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.discountText,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product Details
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand name
                  Text(
                    product.brand,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Product name
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Price and rating row
                  Row(
                    children: [
                      // Price
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${product.price.toInt()}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (product.originalPrice > product.price)
                              Text(
                                '₹${product.originalPrice.toInt()}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppColors.textLight,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.rating,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toString(),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
