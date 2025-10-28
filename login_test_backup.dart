import 'package:automationtest/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('Valid user login', ($) async {
    // Start the app
    await $.pumpWidgetAndSettle(const MyApp());

    // Wait for splash screen and navigation to login
    await $.pumpAndSettle(timeout: const Duration(seconds: 5));

    // Verify we're on the login screen
    expect($('Welcome Back!'), findsOneWidget);
    expect($('Sign in to continue shopping'), findsOneWidget);

    // Enter valid email (first TextFormField)
    await $(TextFormField).at(0).enterText('user@vxceed.com');
    await $.pumpAndSettle();

    // Enter valid password (second TextFormField)
    await $(TextFormField).at(1).enterText('password123');
    await $.pumpAndSettle();

    // Tap the Login button
    await $('Login').tap();

    // Wait for login process and navigation
    await $.pumpAndSettle(timeout: const Duration(seconds: 5));

    // Verify successful login - should navigate to home screen
    // Check for home screen elements
    expect($('Home'), findsOneWidget);
    // Or check for bottom navigation bar
    expect($('Wishlist'), findsOneWidget);
    expect($('Cart'), findsOneWidget);
  });
}
