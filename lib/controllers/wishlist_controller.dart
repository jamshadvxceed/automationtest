import 'package:get/get.dart';
import '../models/product_model.dart';
import 'product_controller.dart';
import 'cart_controller.dart';

class WishlistController extends GetxController {
  // Observable variables
  final RxList<ProductModel> wishlistItems = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;

  // Get other controllers lazily
  ProductController get _productController => Get.find<ProductController>();
  CartController get _cartController => Get.find<CartController>();

  @override
  void onInit() {
    super.onInit();
    // Delay loading wishlist to ensure ProductController is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      loadWishlist();
      
      // Listen to changes in ProductController's allProducts
      ever(_productController.allProducts, (_) {
        loadWishlist(); // Reload wishlist when products change
      });
    });
  }

  void loadWishlist() {
    try {
      isLoading.value = true;
      
      // Get favorite products from product controller
      final favoriteProducts = _productController.getFavoriteProducts();
      wishlistItems.value = favoriteProducts;
      
      print('Wishlist loaded: ${favoriteProducts.length} items'); // Debug
      
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      print('Wishlist load error: $e'); // Debug
      Get.snackbar(
        'Error',
        'Failed to load wishlist: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void addToWishlist(ProductModel product) {
    // Use product controller's toggle favorite method
    _productController.toggleFavorite(product.id);
    
    // Refresh wishlist
    loadWishlist();
  }

  void removeFromWishlist(String productId) {
    // Use product controller's toggle favorite method
    _productController.toggleFavorite(productId);
    
    // Remove from local wishlist
    wishlistItems.removeWhere((product) => product.id == productId);
  }

  void toggleWishlist(ProductModel product) {
    if (isInWishlist(product.id)) {
      removeFromWishlist(product.id);
    } else {
      addToWishlist(product);
    }
  }

  bool isInWishlist(String productId) {
    return wishlistItems.any((product) => product.id == productId);
  }

  void clearWishlist() {
    // Remove all items from wishlist by toggling their favorite status
    for (final product in List.from(wishlistItems)) {
      _productController.toggleFavorite(product.id);
    }
    
    wishlistItems.clear();
    
    Get.snackbar(
      'Wishlist Cleared',
      'All items have been removed from your wishlist',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void moveToCart(ProductModel product) {
    // Add to cart
    _cartController.addToCart(product);
    
    // Optionally remove from wishlist
    // removeFromWishlist(product.id);
    
    Get.snackbar(
      'Moved to Cart',
      '${product.name} has been added to your cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void moveAllToCart() {
    if (wishlistItems.isEmpty) {
      Get.snackbar(
        'Wishlist Empty',
        'No items in wishlist to move to cart',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Add all wishlist items to cart
    for (final product in wishlistItems) {
      _cartController.addToCart(product);
    }

    Get.snackbar(
      'Moved to Cart',
      'All wishlist items have been added to your cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  // Get wishlist count
  int get wishlistCount => wishlistItems.length;

  // Check if wishlist is empty
  bool get isEmpty => wishlistItems.isEmpty;

  // Refresh wishlist
  void refreshWishlist() {
    loadWishlist();
  }

  // Get products by category from wishlist
  List<ProductModel> getWishlistByCategory(String category) {
    if (category == 'All') {
      return wishlistItems;
    }
    return wishlistItems.where((product) => product.category == category).toList();
  }

  // Search in wishlist
  List<ProductModel> searchInWishlist(String query) {
    if (query.isEmpty) {
      return wishlistItems;
    }
    
    return wishlistItems
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.brand.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
