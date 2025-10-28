import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> runHomeScreenTest(PatrolIntegrationTester $) async {
  // --- Step 0: Wait for home screen ---
  await $.pumpAndSettle(timeout: const Duration(seconds: 5));
  expect($('Home'), findsOneWidget);

  // --- Step 1: Search for product ---
  await $(TextField).enterText('Slim Fit Jeans');
  await $.pumpAndSettle();

  // Try tapping the search icon if present
  if (await $(Icons.search).exists) {
    await $(Icons.search).tap();
  }
  await $.pumpAndSettle(timeout: const Duration(seconds: 5));

  // Get all tappable widgets (buttons, gesture detectors, or images)
  final tappables = await $.tester.widgetList(find.byType(GestureDetector));
  // Alternatively, if your product images are Image widgets:
  final images = await $.tester.widgetList(find.byType(Image));
  // Decide which to tap — first visible one
  if (images.isNotEmpty) {
    // Wrap with PatrolFinder to scroll & tap
    final firstImageText = images.first; // we just need index 0
    await $(find.byWidget(firstImageText)).scrollTo();
    await $(find.byWidget(firstImageText)).tap();
  } else if (tappables.isNotEmpty) {
    // Fallback: first GestureDetector
    final firstTap = tappables.first;
    await $(find.byWidget(firstTap)).scrollTo();
    await $(find.byWidget(firstTap)).tap();
  } else {
    throw Exception('No tappable product found after search');
  }

  await $.pumpAndSettle(timeout: const Duration(seconds: 3));

  // --- Step 4: Select size and color ---
  await $('30').tap();
  await $('Light Blue').tap();
  await $.pumpAndSettle(timeout: const Duration(seconds: 5));

  // --- Step 5: Add to cart ---
  await $('Add to Cart').tap();
  await $.pumpAndSettle(timeout: const Duration(seconds: 3));

  // --- Step 6: Verify cart badge increment ---
  //expect($('1'), findsWidgets);

  // --- Step 7: Checkout flow ---
  await $(Icons.shopping_cart).tap();
  await $.pumpAndSettle(timeout: const Duration(seconds: 2));
  await $('Proceed to Checkout').tap();
  await $.pumpAndSettle(timeout: const Duration(seconds: 3));

  expect($('Order placed successfully'), findsOneWidget);
}

void main() {
  patrolTest('Validate search, add Slim Fit Jeans to cart, and checkout', (
    $,
  ) async {
    await runHomeScreenTest($);
  });
}
