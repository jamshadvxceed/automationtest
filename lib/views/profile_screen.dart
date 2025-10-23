import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import '../routes/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final CartController cartController = Get.find<CartController>();
    final WishlistController wishlistController = Get.find<WishlistController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
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
                children: [
                  // Profile Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Obx(() => Center(
                      child: Text(
                        authController.userName.value.isNotEmpty
                            ? authController.userName.value[0].toUpperCase()
                            : 'U',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  
                  // User Info
                  Obx(() => Column(
                    children: [
                      Text(
                        authController.userName.value.isNotEmpty
                            ? authController.userName.value
                            : 'John Doe',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authController.userEmail.value.isNotEmpty
                            ? authController.userEmail.value
                            : 'user@vxceed.com',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )),
                  const SizedBox(height: 16),
                  
                  // Stats Row
                  Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Cart Items',
                        cartController.totalItems.value.toString(),
                        Icons.shopping_cart,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.border,
                      ),
                      _buildStatItem(
                        'Wishlist',
                        wishlistController.wishlistCount.toString(),
                        Icons.favorite,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.border,
                      ),
                      _buildStatItem(
                        'Orders',
                        '0',
                        Icons.shopping_bag,
                      ),
                    ],
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Menu Items
            _buildMenuSection([
              _buildMenuItem(
                'My Orders',
                Icons.shopping_bag_outlined,
                () {
                  Get.snackbar(
                    'My Orders',
                    'This feature would show order history',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              _buildMenuItem(
                'Address Book',
                Icons.location_on_outlined,
                () {
                  Get.snackbar(
                    'Address Book',
                    'This feature would manage delivery addresses',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              _buildMenuItem(
                'Payment Methods',
                Icons.payment_outlined,
                () {
                  Get.snackbar(
                    'Payment Methods',
                    'This feature would manage payment options',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ]),
            const SizedBox(height: 16),
            
            _buildMenuSection([
              _buildMenuItem(
                'Notifications',
                Icons.notifications_outlined,
                () {
                  Get.snackbar(
                    'Notifications',
                    'This feature would manage notification settings',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              _buildMenuItem(
                'Help & Support',
                Icons.help_outline,
                () {
                  Get.snackbar(
                    'Help & Support',
                    'This feature would provide customer support',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              _buildMenuItem(
                'About',
                Icons.info_outline,
                () {
                  _showAboutDialog(context);
                },
              ),
            ]),
            const SizedBox(height: 24),
            
            // Logout Button
            CustomButton(
              text: 'Logout',
              onPressed: () {
                _showLogoutDialog(context, authController);
              },
              backgroundColor: AppColors.error,
              width: double.infinity,
              height: 52,
              icon: Icons.logout,
            ),
            const SizedBox(height: 16),
            
            // App Version
            Text(
              'Version 1.0.0',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
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
        children: items,
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textSecondary,
        size: 22,
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textLight,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to logout?',
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
              authController.logout();
              Get.back();
              AppRoutes.toLogin();
            },
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_bag,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Vxceed',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A Flutter demo application showcasing an e-commerce shopping experience.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'Features:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...const [
              '• Product browsing and search',
              '• Shopping cart management',
              '• Wishlist functionality',
              '• User authentication',
              '• Responsive design',
            ].map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                feature,
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            )),
            const SizedBox(height: 16),
            Text(
              'Built with Flutter & GetX',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
