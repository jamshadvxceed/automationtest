import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../controllers/wishlist_controller.dart';
import '../controllers/cart_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/product_card.dart';
import '../widgets/custom_button.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WishlistController wishlistController =
        Get.find<WishlistController>();
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Wishlist',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          Obx(
            () => wishlistController.wishlistItems.isNotEmpty
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'move_all':
                          wishlistController.moveAllToCart();
                          break;
                        case 'clear_all':
                          _showClearWishlistDialog(context, wishlistController);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'move_all',
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_cart, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Move All to Cart',
                              style: GoogleFonts.poppins(),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.clear_all,
                              size: 20,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Clear Wishlist',
                              style: GoogleFonts.poppins(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
          ),
        ],
      ),
      body: Obx(() {
        if (wishlistController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (wishlistController.wishlistItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_outline,
                  size: 80,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your wishlist is empty',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Save your favorite items here',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  key: const Key('start_shopping_button'),
                  text: 'Start Shopping',
                  onPressed: () => Get.back(),
                  width: 200,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  key: const Key('refresh_wishlist_button'),
                  text: 'Refresh Wishlist',
                  onPressed: () => wishlistController.loadWishlist(),
                  isOutlined: true,
                  width: 200,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Wishlist Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.favorite, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${wishlistController.wishlistCount} items',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (wishlistController.wishlistItems.isNotEmpty)
                    CustomButton(
                      key: const Key('move_all_to_cart_button'),
                      text: 'Move All to Cart',
                      onPressed: () => wishlistController.moveAllToCart(),
                      isOutlined: true,
                      fontSize: 12,
                      height: 36,
                    ),
                ],
              ),
            ),

            // Wishlist Items Grid
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  wishlistController.refreshWishlist();
                },
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: wishlistController.wishlistItems.length,
                    itemBuilder: (context, index) {
                      final product = wishlistController.wishlistItems[index];
                      return WishlistProductCard(
                        product: product,
                        onMoveToCart: () {
                          wishlistController.moveToCart(product);
                        },
                        onRemove: () {
                          wishlistController.removeFromWishlist(product.id);
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showClearWishlistDialog(
    BuildContext context,
    WishlistController controller,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Clear Wishlist',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to remove all items from your wishlist?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.clearWishlist();
              Get.back();
            },
            child: Text(
              'Clear',
              style: GoogleFonts.poppins(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class WishlistProductCard extends StatelessWidget {
  final product;
  final VoidCallback onMoveToCart;
  final VoidCallback onRemove;

  const WishlistProductCard({
    super.key,
    required this.product,
    required this.onMoveToCart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Use the existing ProductCard but with custom actions
          ProductCard(
            product: product,
            onTap: () {
              // Navigate to product detail
              Get.toNamed('/product-detail', arguments: product.id);
            },
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Add to Cart',
                    onPressed: onMoveToCart,
                    fontSize: 10,
                    height: 36,
                    icon: Icons.shopping_cart_outlined,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 16,
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
}
