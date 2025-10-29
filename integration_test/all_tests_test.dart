import 'package:patrol/patrol.dart';
import 'login_test.dart' as login;
import 'home_screen_test.dart' as home;

void main() {
  patrolTest(
    'Execute login then home screen flow sequentially with key-based finding',
    ($) async {
      print('🧩 Starting login test with key-based finding...');
      await login.runLoginTest($);

      print(
        '✅ Login successful, proceeding to home screen test with key-based finding...',
      );
      await home.runHomeScreenTest($);

      print(
        '🎉 All tests completed successfully using key-based widget finding.',
      );
    },
  );
}
