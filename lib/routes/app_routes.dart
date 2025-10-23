import 'package:get/get.dart';
import '../views/splash_screen.dart';
import '../views/login_screen.dart';
import '../views/home_screen.dart';
import '../views/product_detail_screen.dart';
import '../views/cart_screen.dart';
import '../views/wishlist_screen.dart';
import '../views/profile_screen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';

class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String wishlist = '/wishlist';
  static const String profile = '/profile';

  // Route pages
  static List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
        // Initialize ProductController first as WishlistController depends on it
        Get.put<ProductController>(ProductController());
        Get.put<CartController>(CartController());
        // Initialize WishlistController after ProductController
        Get.put<WishlistController>(WishlistController());
      }),
    ),
    GetPage(
      name: productDetail,
      page: () => const ProductDetailScreen(),
      binding: BindingsBuilder(() {
        Get.put<ProductController>(ProductController());
        Get.put<CartController>(CartController());
        Get.put<WishlistController>(WishlistController());
      }),
    ),
    GetPage(
      name: cart,
      page: () => const CartScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<CartController>(() => CartController());
      }),
    ),
    GetPage(
      name: wishlist,
      page: () => const WishlistScreen(),
      binding: BindingsBuilder(() {
        Get.put<ProductController>(ProductController());
        Get.put<CartController>(CartController());
        Get.put<WishlistController>(WishlistController());
      }),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
  ];

  // Navigation methods
  static void toSplash() => Get.offAllNamed(splash);
  static void toLogin() => Get.offAllNamed(login);
  static void toHome() => Get.offAllNamed(home);
  static void toProductDetail(String productId) => Get.toNamed(productDetail, arguments: productId);
  static void toCart() => Get.toNamed(cart);
  static void toWishlist() => Get.toNamed(wishlist);
  static void toProfile() => Get.toNamed(profile);
}
