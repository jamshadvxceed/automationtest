import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product_model.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductController _productController = Get.find<ProductController>();
  final CartController _cartController = Get.find<CartController>();
  final WishlistController _wishlistController = Get.find<WishlistController>();

  late String productId;
  ProductModel? product;
  String? selectedSize;
  String? selectedColor;

  @override
  void initState() {
    super.initState();
    productId = Get.arguments as String;
    product = _productController.getProductById(productId);

    // Set default selections
    if (product != null) {
      selectedSize = product!.sizes.isNotEmpty ? product!.sizes.first : null;
      selectedColor = product!.colors.isNotEmpty ? product!.colors.first : null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Product Not Found', style: GoogleFonts.poppins()),
        ),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Hero Image
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            actions: [
              Obx(() {
                final isFavorite = _productController.allProducts
                    .firstWhere(
                      (p) => p.id == product!.id,
                      orElse: () => product!,
                    )
                    .isFavorite;

                return IconButton(
                  key: Key('favorite_button_detail_${product!.id}'),
                  onPressed: () =>
                      _productController.toggleFavorite(product!.id),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                );
              }),
              IconButton(
                onPressed: () {
                  // Share functionality
                  Get.snackbar(
                    'Share',
                    'Share functionality would be implemented here',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: AppColors.textPrimary),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product-${product!.id}',
                child: CachedNetworkImage(
                  imageUrl: product!.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surface,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppColors.textLight,
                      size: 60,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand and Name
                    Text(
                      product!.brand,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product!.name,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Price and Rating
                    Row(
                      children: [
                        Text(
                          '₹${product!.price.toInt()}',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (product!.originalPrice > product!.price) ...[
                          Text(
                            '₹${product!.originalPrice.toInt()}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: AppColors.textLight,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.discount,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product!.discountText,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.rating,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${product!.rating} (${product!.reviewCount})',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Size Selection
                    if (product!.sizes.isNotEmpty) ...[
                      Text(
                        'Size',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: product!.sizes.map((size) {
                          final isSelected = selectedSize == size;
                          return GestureDetector(
                            key: Key(
                              'size_${size.toLowerCase().replaceAll(' ', '_')}',
                            ),
                            onTap: () {
                              setState(() {
                                selectedSize = size;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                size,
                                style: GoogleFonts.poppins(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Color Selection
                    if (product!.colors.isNotEmpty) ...[
                      Text(
                        'Color',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: product!.colors.map((color) {
                          final isSelected = selectedColor == color;
                          return GestureDetector(
                            key: Key(
                              'color_${color.toLowerCase().replaceAll(' ', '_')}',
                            ),
                            onTap: () {
                              setState(() {
                                selectedColor = color;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                color,
                                style: GoogleFonts.poppins(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Description
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product!.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Action Buttons
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: CustomButton(
          key: const Key('add_to_cart_button'),
          text: 'Add to Cart',
          onPressed: () {
            _cartController.addToCart(
              product!,
              size: selectedSize,
              color: selectedColor,
            );
          },
          icon: Icons.shopping_cart,
        ),
      ),
    );
  }
}
