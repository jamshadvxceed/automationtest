import 'package:flutter/material.dart';
import 'package:automationtest/utils/test_keys.dart';

/// Example showing how to use TestKeys in your app widgets
/// 
/// This demonstrates how to assign keys to widgets for testing purposes
class TestKeysUsageExample extends StatelessWidget {
  const TestKeysUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Keys Usage Example'),
      ),
      body: Column(
        children: [
          // Example 1: Static key for a text field
          TextField(
            key: TestKeys.emailField,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
          
          // Example 2: Static key for a button
          ElevatedButton(
            key: TestKeys.loginButton,
            onPressed: () {},
            child: const Text('Login'),
          ),
          
          // Example 3: Dynamic key for a product card
          Card(
            key: TestKeys.productCard('123'),
            child: const ListTile(
              title: Text('Product 123'),
            ),
          ),
          
          // Example 4: Dynamic key for size selector
          Wrap(
            children: ['S', 'M', 'L', 'XL'].map((size) {
              return ChoiceChip(
                key: TestKeys.sizeSelector(size),
                label: Text(size),
                selected: false,
              );
            }).toList(),
          ),
          
          // Example 5: Bottom navigation bar with keys
          BottomNavigationBar(
            key: TestKeys.bottomNavigationBar,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, key: TestKeys.homeTabIcon),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite, key: TestKeys.wishlistTabIcon),
                label: 'Wishlist',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart, key: TestKeys.cartTabIcon),
                label: 'Cart',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
