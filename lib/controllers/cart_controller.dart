import 'package:get/get.dart';
import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  final String selectedSize;
  final String selectedColor;

  CartItem({
    required this.product,
    this.quantity = 1,
    required this.selectedSize,
    required this.selectedColor,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'],
      selectedSize: json['selectedSize'],
      selectedColor: json['selectedColor'],
    );
  }
}

class CartController extends GetxController {
  // Observable variables
  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxDouble subtotal = 0.0.obs;
  final RxDouble deliveryFee = 99.0.obs;
  final RxInt totalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to cart changes and update totals
    ever(cartItems, (_) => calculateTotals());
  }

  void addToCart(ProductModel product, {String? size, String? color}) {
    // Use default values if size/color not provided
    final selectedSize = size ?? (product.sizes.isNotEmpty ? product.sizes.first : 'Standard');
    final selectedColor = color ?? (product.colors.isNotEmpty ? product.colors.first : 'Default');
    
    // Check if item already exists in cart with same size and color
    final existingItemIndex = cartItems.indexWhere(
      (item) => 
        item.product.id == product.id &&
        item.selectedSize == selectedSize &&
        item.selectedColor == selectedColor,
    );

    if (existingItemIndex != -1) {
      // Item exists, increase quantity
      cartItems[existingItemIndex].quantity++;
      cartItems.refresh();
    } else {
      // Add new item to cart
      cartItems.add(CartItem(
        product: product,
        selectedSize: selectedSize,
        selectedColor: selectedColor,
      ));
    }

    Get.snackbar(
      'Added to Cart',
      '${product.name} has been added to your cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < cartItems.length) {
      final item = cartItems[index];
      cartItems.removeAt(index);
      
      Get.snackbar(
        'Removed from Cart',
        '${item.product.name} has been removed from your cart',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void updateQuantity(int index, int newQuantity) {
    if (index >= 0 && index < cartItems.length) {
      if (newQuantity <= 0) {
        removeFromCart(index);
      } else {
        cartItems[index].quantity = newQuantity;
        cartItems.refresh();
      }
    }
  }

  void increaseQuantity(int index) {
    if (index >= 0 && index < cartItems.length) {
      cartItems[index].quantity++;
      cartItems.refresh();
    }
  }

  void decreaseQuantity(int index) {
    if (index >= 0 && index < cartItems.length) {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
        cartItems.refresh();
      } else {
        removeFromCart(index);
      }
    }
  }

  void clearCart() {
    cartItems.clear();
    Get.snackbar(
      'Cart Cleared',
      'All items have been removed from your cart',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void calculateTotals() {
    // Calculate subtotal
    subtotal.value = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
    
    // Calculate total items
    totalItems.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
    
    // Calculate total amount (subtotal + delivery fee if cart is not empty)
    if (cartItems.isEmpty) {
      totalAmount.value = 0.0;
      deliveryFee.value = 0.0;
    } else {
      // Free delivery for orders above ₹1999
      if (subtotal.value >= 1999) {
        deliveryFee.value = 0.0;
      } else {
        deliveryFee.value = 99.0;
      }
      totalAmount.value = subtotal.value + deliveryFee.value;
    }
  }

  bool isProductInCart(String productId) {
    return cartItems.any((item) => item.product.id == productId);
  }

  int getProductQuantityInCart(String productId) {
    final items = cartItems.where((item) => item.product.id == productId);
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Checkout functionality (dummy)
  Future<bool> checkout() async {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Cart Empty',
        'Please add items to cart before checkout',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    try {
      // Simulate checkout process
      await Future.delayed(const Duration(seconds: 2));
      
      // Clear cart after successful checkout
      cartItems.clear();
      
      Get.snackbar(
        'Order Placed',
        'Your order has been placed successfully!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      
      return true;
    } catch (e) {
      Get.snackbar(
        'Checkout Failed',
        'Failed to place order. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
