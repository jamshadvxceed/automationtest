import 'package:get/get.dart';

class AuthController extends GetxController {
  // Observable variables
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxString userEmail = ''.obs;
  final RxString userName = ''.obs;

  // Dummy user data
  final String dummyEmail = 'user@vxceed.com';
  final String dummyPassword = 'password123';
  final String dummyName = 'John Doe';

  @override
  void onInit() {
    super.onInit();
    // Check if user is already logged in (for demo purposes, always false initially)
    checkLoginStatus();
  }

  void checkLoginStatus() {
    // In a real app, you would check SharedPreferences or secure storage
    // For demo purposes, we'll assume user is not logged in initially
    isLoggedIn.value = false;
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Dummy validation
      if (email.isNotEmpty && password.isNotEmpty) {
        // In a real app, you would make an API call here
        if (email == dummyEmail && password == dummyPassword) {
          isLoggedIn.value = true;
          userEmail.value = email;
          userName.value = dummyName;
          
          Get.snackbar(
            'Success',
            'Login successful!',
            snackPosition: SnackPosition.BOTTOM,
          );
          return true;
        } else {
          Get.snackbar(
            'Error',
            'Invalid email or password',
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      } else {
        Get.snackbar(
          'Error',
          'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    isLoggedIn.value = false;
    userEmail.value = '';
    userName.value = '';
    
    Get.snackbar(
      'Success',
      'Logged out successfully',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Validation methods
  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
