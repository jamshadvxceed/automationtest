# Test Keys - Shared Between App and Tests

## Overview
The `test_keys.dart` file contains all widget keys used for testing. This file is placed in `lib/utils/` so it can be:
- **Imported in app code** to assign keys to widgets
- **Imported in test code** to reference those same keys

## Benefits
1. **Single Source of Truth**: All test keys are defined in one place
2. **Type Safety**: Keys are strongly typed and can be used in both app and test code
3. **Maintainability**: Changes to keys only need to be made in one location
4. **Discoverability**: Developers can easily see all available test keys

## Usage in App Code

Import the test keys in your widget files:

```dart
import 'package:automationtest/utils/test_keys.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          key: TestKeys.emailField,  // Assign key to widget
          decoration: InputDecoration(labelText: 'Email'),
        ),
        ElevatedButton(
          key: TestKeys.loginButton,  // Assign key to widget
          onPressed: () {},
          child: Text('Login'),
        ),
      ],
    );
  }
}
```

## Usage in Test Code

Import the test keys in your test files:

```dart
import 'package:automationtest/utils/test_keys.dart';
import 'package:patrol/patrol.dart';

patrolTest('Login test', ($) async {
  // Use the same keys to find widgets
  await $(find.byKey(TestKeys.emailField)).enterText('test@example.com');
  await $(find.byKey(TestKeys.loginButton)).tap();
});
```

## Key Types

### Static Keys
Used for widgets that appear once on a screen:
```dart
static const Key loginButton = Key('login_button');
```

### Dynamic Keys
Used for widgets that appear multiple times (e.g., list items):
```dart
static Key productCard(String productId) => Key('product_card_$productId');
```

Usage:
```dart
// In app code:
Card(key: TestKeys.productCard('123'))

// In test code:
await $(find.byKey(TestKeys.productCard('123'))).tap();
```

## Best Practices

1. **Always use TestKeys**: When adding a new widget that needs testing, add its key to `test_keys.dart` first
2. **Descriptive names**: Use clear, descriptive names for keys (e.g., `loginButton` not `btn1`)
3. **Consistent naming**: Follow the existing naming conventions
4. **Group related keys**: Keep keys organized by screen or feature
5. **Document dynamic keys**: Add comments explaining what parameters dynamic keys expect

## File Location
- **Shared file**: `lib/utils/test_keys.dart`
- **Old location** (deprecated): `integration_test/test_keys.dart`

## Migration
If you have existing test files importing from the old location, update them:

```dart
// Old (deprecated)
import 'test_keys.dart';

// New (correct)
import 'package:automationtest/utils/test_keys.dart';
```

## Example
See `lib/utils/test_keys_usage_example.dart` for a complete example of how to use test keys in your widgets.
