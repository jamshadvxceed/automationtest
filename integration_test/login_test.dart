import 'package:automationtest/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:automationtest/utils/test_keys.dart';

// Function to be called by orchestrator
Future<void> runLoginTest(PatrolIntegrationTester $) async {
  // Start the app
  await $.pumpWidgetAndSettle(const MyApp());

  // Wait for splash screen and navigation to login
  await $.pumpAndSettle(timeout: const Duration(seconds: 5));

  // Verify we're on the login screen
  $.log('💳 Proceeding to VXCEED Sales');
  expect($('Welcome Back!'), findsOneWidget);
  expect($('Sign in to continue shopping'), findsOneWidget);

  // Enter valid email using key-based finding
  await $(TestKeys.emailField).enterText('user@vxceed.com');
  await $.pumpAndSettle();

  // Enter valid password using key-based finding
  await $(TestKeys.passwordField).enterText('password123');
  await $.pumpAndSettle();

  // Tap the Login button using key-based finding
  await $(TestKeys.loginButton).tap();

  // Additional wait for controllers to initialize
  await Future.delayed(const Duration(seconds: 3));
  await $.pumpAndSettle();

  // Verify successful login - should navigate to home screen
  // Check for the bottom navigation bar itself (more reliable)
  expect($(TestKeys.bottomNavigationBar), findsOneWidget);
  $.log('💳 Proceeding to Shopping');

  // Verify navigation items by text (more reliable than individual icon keys)
  expect($('Home'), findsOneWidget);
  expect($('Wishlist'), findsOneWidget);
  expect($('Cart'), findsOneWidget);
  expect($('Profile'), findsOneWidget);
}

void main() {
  patrolTest('Valid user login', ($) async {
    await runLoginTest($);
  });
}
