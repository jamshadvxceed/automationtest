import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../utils/app_colors.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../routes/app_routes.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ProductController _productController;
  late final CartController _cartController;
  WishlistController? _wishlistController;
  final TextEditingController _searchController = TextEditingController();

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Get controllers that should already be initialized by routes
    _productController = Get.find<ProductController>();
    _cartController = Get.find<CartController>();
    // Get wishlist controller with a small delay to ensure it's ready
    Future.delayed(const Duration(milliseconds: 50), () {
      _wishlistController = Get.find<WishlistController>();
    });
  }

  final List<Widget> _screens = [
    const HomeContent(),
    const WishlistScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          key: const Key('bottom_navigation_bar'),
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, key: Key('home_tab_icon')),
              activeIcon: Icon(Icons.home, key: Key('home_tab_active_icon')),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(
                    Icons.favorite_outline,
                    key: Key('wishlist_tab_icon'),
                  ),
                  if ((_wishlistController?.wishlistCount ?? 0) > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          (_wishlistController?.wishlistCount ?? 0).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: Stack(
                children: [
                  const Icon(
                    Icons.favorite,
                    key: Key('wishlist_tab_active_icon'),
                  ),
                  if ((_wishlistController?.wishlistCount ?? 0) > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          (_wishlistController?.wishlistCount ?? 0).toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Wishlist',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    key: Key('cart_tab_icon'),
                  ),
                  if (_cartController.totalItems.value > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          _cartController.totalItems.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: Stack(
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    key: Key('cart_tab_active_icon'),
                  ),
                  if (_cartController.totalItems.value > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          _cartController.totalItems.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, key: Key('profile_tab_icon')),
              activeIcon: Icon(
                Icons.person,
                key: Key('profile_tab_active_icon'),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  late final ProductController _productController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Get controller that should already be initialized by routes
    _productController = Get.find<ProductController>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // App Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.background,
            child: Column(
              children: [
                // Header with logo and search
                Row(
                  children: [
                    Text(
                      'Vxceed',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      key: const Key('search_button'),
                      onPressed: () {
                        // Search functionality
                      },
                      icon: const Icon(
                        Icons.search,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      key: const Key('notifications_button'),
                      onPressed: () {
                        // Notifications
                        Get.snackbar(
                          'Notifications',
                          'No new notifications',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search Bar
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    key: const Key('search_field'),
                    controller: _searchController,
                    onChanged: (value) {
                      _productController.searchProducts(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for products, brands and more',
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: Obx(
                        () => _productController.searchQuery.value.isNotEmpty
                            ? IconButton(
                                key: const Key('clear_search_button'),
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _productController.clearSearch();
                                },
                              )
                            : const SizedBox(),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories
          Obx(
            () => CategoryChipList(
              categories: _productController.categories,
              selectedCategory: _productController.selectedCategory.value,
              onCategorySelected: (category) {
                _productController.filterByCategory(category);
              },
            ),
          ),

          const SizedBox(height: 8),

          // Products Grid
          Expanded(
            child: Obx(() {
              print('Loading: ${_productController.isLoading.value}'); // Debug
              print(
                'Products count: ${_productController.filteredProducts.length}',
              ); // Debug

              if (_productController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              // Force show products for testing
              final testProducts = _productController.allProducts.isNotEmpty
                  ? _productController.filteredProducts
                  : _productController.allProducts;

              if (testProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No products found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search or filters',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _productController.loadProducts();
                        },
                        child: const Text('Reload Products'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  _productController.refreshProducts();
                },
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: testProducts.length,
                    itemBuilder: (context, index) {
                      final product = testProducts[index];
                      return ProductCard(product: product);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
