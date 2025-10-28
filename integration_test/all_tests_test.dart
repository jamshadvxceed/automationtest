import 'package:patrol/patrol.dart';
import 'login_test.dart' as login;
import 'home_screen_test.dart' as home;

void main() {
  patrolTest('Execute login then home screen flow sequentially', ($) async {
    print('🧩 Starting login test...');
    await login.runLoginTest($);

    print('✅ Login successful, proceeding to home screen...');
    await home.runHomeScreenTest($);

    print('🎉 All tests completed successfully.');
  });
}
