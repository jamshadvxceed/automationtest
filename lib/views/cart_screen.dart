import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/cart_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Shopping Cart',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          Obx(
            () => cartController.cartItems.isNotEmpty
                ? TextButton(
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: Text(
                            'Clear Cart',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to remove all items from your cart?',
                            style: GoogleFonts.poppins(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                cartController.clearCart();
                                Get.back();
                              },
                              child: Text(
                                'Clear',
                                style: GoogleFonts.poppins(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Clear',
                      style: GoogleFonts.poppins(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
      body: Obx(() {
        if (cartController.cartItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your cart is empty',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add some products to get started',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Start Shopping',
                  onPressed: () => Get.back(),
                  width: 200,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Cart Items List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cartController.cartItems.length,
                itemBuilder: (context, index) {
                  final cartItem = cartController.cartItems[index];
                  return CartItemCard(
                    cartItem: cartItem,
                    index: index,
                    onQuantityChanged: (newQuantity) {
                      cartController.updateQuantity(index, newQuantity);
                    },
                    onRemove: () {
                      cartController.removeFromCart(index);
                    },
                  );
                },
              ),
            ),

            // Cart Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Price Breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal (${cartController.totalItems.value} items)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '₹${cartController.subtotal.value.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Fee',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        cartController.deliveryFee.value == 0
                            ? 'FREE'
                            : '₹${cartController.deliveryFee.value.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: cartController.deliveryFee.value == 0
                              ? AppColors.success
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (cartController.subtotal.value < 1999 &&
                      cartController.subtotal.value > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Add ₹${(1999 - cartController.subtotal.value).toInt()} more for FREE delivery',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '₹${cartController.totalAmount.value.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomButton(
                    key: const Key('proceed_to_checkout_button'),
                    text: 'Proceed to Checkout',
                    onPressed: () async {
                      final success = await cartController.checkout();
                      if (success) {
                        Get.snackbar(
                          'Success',
                          'Order placed successfully!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.success,
                          colorText: Colors.white,
                        );
                      }
                    },
                    width: double.infinity,
                    height: 52,
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final CartItem cartItem;
  final int index;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.index,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find<CartController>();

    return Container(
      key: Key('cart_item_${cartItem.product.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: cartItem.product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 80,
                height: 80,
                color: AppColors.surface,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 80,
                height: 80,
                color: AppColors.surface,
                child: const Icon(
                  Icons.image_not_supported,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.brand,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  cartItem.product.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (cartItem.selectedSize.isNotEmpty) ...[
                      Text(
                        'Size: ${cartItem.selectedSize}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                      if (cartItem.selectedColor.isNotEmpty) ...[
                        const Text(' • '),
                        Text(
                          cartItem.selectedColor,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ] else if (cartItem.selectedColor.isNotEmpty) ...[
                      Text(
                        'Color: ${cartItem.selectedColor}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '₹${cartItem.product.price.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    // Quantity Controls
                    Row(
                      children: [
                        GestureDetector(
                          key: Key('quantity_decrease_${cartItem.product.id}'),
                          onTap: () => cartController.decreaseQuantity(index),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.remove,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 32,
                          alignment: Alignment.center,
                          child: Text(
                            cartItem.quantity.toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          key: Key('quantity_increase_${cartItem.product.id}'),
                          onTap: () => cartController.increaseQuantity(index),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Remove Button
          IconButton(
            key: Key('remove_cart_item_${cartItem.product.id}'),
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
