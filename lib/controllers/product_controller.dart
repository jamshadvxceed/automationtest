import 'package:get/get.dart';
import '../models/product_model.dart';
import '../utils/dummy_data.dart';

class ProductController extends GetxController {
  // Observable variables
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxString selectedCategory = 'All'.obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Categories
  final List<String> categories = DummyData.categories;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void loadProducts() {
    try {
      isLoading.value = true;
      
      // Load products immediately for testing
      allProducts.value = DummyData.products;
      filteredProducts.value = allProducts;
      isLoading.value = false;
      
      print('Products loaded: ${allProducts.length}'); // Debug print
    } catch (e) {
      isLoading.value = false;
      print('Error loading products: $e'); // Debug print
      Get.snackbar(
        'Error',
        'Failed to load products: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    
    if (category == 'All') {
      filteredProducts.value = allProducts;
    } else {
      filteredProducts.value = allProducts
          .where((product) => product.category == category)
          .toList();
    }
    
    // Apply search filter if there's a search query
    if (searchQuery.value.isNotEmpty) {
      searchProducts(searchQuery.value);
    }
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      // If search is empty, show filtered products by category
      filterByCategory(selectedCategory.value);
      return;
    }
    
    List<ProductModel> baseProducts = selectedCategory.value == 'All' 
        ? allProducts 
        : allProducts.where((product) => product.category == selectedCategory.value).toList();
    
    filteredProducts.value = baseProducts
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.brand.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void toggleFavorite(String productId) {
    // Find product in all products list
    final productIndex = allProducts.indexWhere((product) => product.id == productId);
    if (productIndex != -1) {
      allProducts[productIndex].isFavorite = !allProducts[productIndex].isFavorite;
      allProducts.refresh();
      
      // Update filtered products if the product is in the current filtered list
      final filteredIndex = filteredProducts.indexWhere((product) => product.id == productId);
      if (filteredIndex != -1) {
        filteredProducts[filteredIndex].isFavorite = allProducts[productIndex].isFavorite;
        filteredProducts.refresh();
      }
      
      
      // Show snackbar
      final product = allProducts[productIndex];
      Get.snackbar(
        product.isFavorite ? 'Added to Wishlist' : 'Removed from Wishlist',
        product.name,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    }
  }

  ProductModel? getProductById(String id) {
    try {
      return allProducts.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ProductModel> getFavoriteProducts() {
    return allProducts.where((product) => product.isFavorite).toList();
  }

  // Get products by category for home screen
  List<ProductModel> getProductsByCategory(String category) {
    if (category == 'All') {
      return allProducts;
    }
    return allProducts.where((product) => product.category == category).toList();
  }

  // Clear search
  void clearSearch() {
    searchQuery.value = '';
    filterByCategory(selectedCategory.value);
  }

  // Refresh products
  void refreshProducts() {
    loadProducts();
  }
}
