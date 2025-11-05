import 'package:flutter/material.dart';

/// Test keys for widget identification in integration tests
/// This file centralizes all widget keys used for testing
/// Can be imported in both app code and test code
class TestKeys {
  // Login Screen Keys
  static const Key emailField = Key('email_field');
  static const Key passwordField = Key('password_field');
  static const Key passwordVisibilityToggle = Key('password_visibility_toggle');
  static const Key loginButton = Key('login_button');
  static const Key forgotPasswordButton = Key('forgot_password_button');
  static const Key signupButton = Key('signup_button');

  // Home Screen Keys
  static const Key searchField = Key('search_field');
  static const Key searchButton = Key('search_button');
  static const Key clearSearchButton = Key('clear_search_button');
  static const Key notificationsButton = Key('notifications_button');

  // Bottom Navigation Keys
  static const Key bottomNavigationBar = Key('bottom_navigation_bar');
  static const Key homeTabIcon = Key('home_tab_icon');
  static const Key homeTabActiveIcon = Key('home_tab_active_icon');
  static const Key wishlistTabIcon = Key('wishlist_tab_icon');
  static const Key wishlistTabActiveIcon = Key('wishlist_tab_active_icon');
  static const Key cartTabIcon = Key('cart_tab_icon');
  static const Key cartTabActiveIcon = Key('cart_tab_active_icon');
  static const Key profileTabIcon = Key('profile_tab_icon');
  static const Key profileTabActiveIcon = Key('profile_tab_active_icon');

  // Product Detail Screen Keys
  static const Key addToCartButton = Key('add_to_cart_button');

  // Cart Screen Keys
  static const Key proceedToCheckoutButton = Key('proceed_to_checkout_button');
  static const Key clearCartButton = Key('clear_cart_button');

  // Wishlist Screen Keys
  static const Key startShoppingButton = Key('start_shopping_button');
  static const Key refreshWishlistButton = Key('refresh_wishlist_button');
  static const Key moveAllToCartButton = Key('move_all_to_cart_button');

  // Profile Screen Keys
  static const Key logoutButton = Key('logout_button');

  // Common Product Keys
  static const Key productGrid = Key('product_grid');
  static const Key categoryChips = Key('category_chips');

  // Dynamic Keys (require parameters)
  static Key productCard(String productId) => Key('product_card_$productId');
  static Key productImage(String productId) => Key('product_image_$productId');
  static Key favoriteButton(String productId) =>
      Key('favorite_button_$productId');
  static Key favoriteButtonDetail(String productId) =>
      Key('favorite_button_detail_$productId');
  static Key sizeSelector(String size) =>
      Key('size_${size.toLowerCase().replaceAll(' ', '_')}');
  static Key colorSelector(String color) =>
      Key('color_${color.toLowerCase().replaceAll(' ', '_')}');
  static Key categoryChip(String category) =>
      Key('category_${category.toLowerCase().replaceAll(' ', '_')}');
  static Key cartItem(String productId) => Key('cart_item_$productId');
  static Key removeCartItem(String productId) =>
      Key('remove_cart_item_$productId');
  static Key quantityIncrease(String productId) =>
      Key('quantity_increase_$productId');
  static Key quantityDecrease(String productId) =>
      Key('quantity_decrease_$productId');
}

/// Helper class for common test operations
class TestHelpers {
  /// Common sizes used in the app
  static const List<String> commonSizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    '28',
    '30',
    '32',
    '34',
    '36',
  ];

  /// Common colors used in the app
  static const List<String> commonColors = [
    'Black',
    'White',
    'Blue',
    'Red',
    'Green',
    'Light Blue',
    'Dark Blue',
  ];

  /// Common categories used in the app
  static const List<String> commonCategories = [
    'All',
    'Clothing',
    'Shoes',
    'Accessories',
    'Electronics',
  ];

  /// Get size key for testing
  static Key getSizeKey(String size) => TestKeys.sizeSelector(size);

  /// Get color key for testing
  static Key getColorKey(String color) => TestKeys.colorSelector(color);

  /// Get category key for testing
  static Key getCategoryKey(String category) => TestKeys.categoryChip(category);

  /// Get product card key for testing
  static Key getProductCardKey(String productId) =>
      TestKeys.productCard(productId);
}
