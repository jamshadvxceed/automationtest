# Flutter Test MCP

A Model Context Protocol (MCP) server for Flutter integration testing that supports generating and executing UI automation tests through natural language descriptions.

## Features

- ✅ Natural language-driven test generation
- ✅ Complete UI operation support (tap, scroll, text input, etc.)
- ✅ Smart waiting and delay mechanisms
- ✅ Text and element verification
- ✅ Screenshot functionality
- ✅ Test execution and reporting
- ✅ Device management

## Installation

1. Clone the repository
```bash
git clone https://github.com/your-username/flutter-test-mcp.git
cd flutter-test-mcp
```

2. Install dependencies
```bash
pnpm install
```

3. Build the project
```bash
pnpm run build
```

## Usage

### Start the MCP Server

```bash
pnpm start
```

### Configure in Claude Code

Add to your Claude Code MCP configuration:

```json
{
  "mcpServers": {
    "flutter-test": {
      "command": "node",
      "args": ["/path/to/flutter-test-mcp/dist/index.js"]
    }
  }
}
```

## Main Tools

### 1. generate_flutter_test
Generate Flutter integration test code from natural language descriptions

**Parameters:**
- `description`: Natural language description of the test scenario
- `testName`: Test case name
- `projectPath`: Flutter project path

**Example:**
```
Description: "Tap login button, enter username admin, enter password 123456, tap confirm button, verify welcome text is displayed"
```

### 2. run_integration_test
Execute Flutter integration tests

**Parameters:**
- `projectPath`: Flutter project path
- `testFile`: Test file path
- `device`: Device ID (optional)

### 3. UI Operation Tools

#### tap_element - Tap Element
- `finder`: Finding method (text, key, type, etc.)
- `value`: Finding value

#### enter_text - Enter Text
- `finder`: Input field finding method
- `value`: Input field finding value
- `text`: Text to enter

#### scroll - Scroll
- `direction`: Scroll direction (up, down, left, right)
- `distance`: Scroll distance (pixels)

### 4. Wait and Verification Tools

#### wait_for_element - Wait for Element
- `finder`: Element finding method
- `value`: Finding value
- `timeout`: Timeout in seconds

#### verify_text_exists - Verify Text Exists
- `text`: Text to verify
- `shouldExist`: Whether the text should exist

#### delay - Delay
- `seconds`: Delay duration in seconds

## Natural Language Parsing

Supported operation types:

### Tap Operations
- "Tap login button"
- "Click 'Submit' button"
- "Press the confirm button"

### Input Operations
- "Enter username 'admin'"
- "Type password '123456'"
- "Fill email address 'test@example.com'"

### Scroll Operations
- "Scroll down"
- "Swipe up"
- "Slide left"

### Wait Operations
- "Wait 2 seconds"
- "Delay 1.5 seconds"
- "Pause for 500 milliseconds"

### Verification Operations
- "Verify page shows 'Login successful'"
- "Confirm 'Welcome' text exists"
- "Check 'Error' message does not exist"

## Element Finding Methods

| Method | Description | Example |
|--------|-------------|---------|
| text | Find by text | `find.text('Login')` |
| key | Find by Key | `find.byKey(Key('login_btn'))` |
| type | Find by type | `find.byType(ElevatedButton)` |
| icon | Find by icon | `find.byIcon(Icons.home)` |
| tooltip | Find by tooltip | `find.byTooltip('Tap to login')` |
| semantics | Find by semantics | `find.bySemanticsLabel('Login button')` |

## Test File Generation Example

Input description:
```
"Open app, tap login button, enter username admin, enter password 123456, tap confirm, wait 2 seconds, verify welcome page is displayed"
```

Generated test code:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('User Login Test', () {
    testWidgets('Open app, tap login button, enter username admin, enter password 123456, tap confirm, wait 2 seconds, verify welcome page is displayed', (WidgetTester tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('login button'));
      await tester.pumpAndSettle();

      // Enter username admin
      await tester.enterText(find.text('username'), 'admin');
      await tester.pumpAndSettle();

      // Enter password 123456
      await tester.enterText(find.text('password'), '123456');
      await tester.pumpAndSettle();

      // Tap confirm
      await tester.tap(find.text('confirm'));
      await tester.pumpAndSettle();

      // Wait 2 seconds
      await Future.delayed(Duration(milliseconds: 2000));

      // Verify welcome page exists
      expect(find.text('welcome page'), findsOneWidget);

    });
  });
}
```

## Development

### Project Structure
```
src/
├── index.ts              # MCP server main entry
├── generators/
│   └── test-generator.ts # Test code generator
├── tools/
│   ├── test-runner.ts    # Test executor
│   ├── ui-actions.ts     # UI action tools
│   └── wait-actions.ts   # Wait action tools
└── utils/
    └── logger.ts         # Logger utility
```

### Development Mode
```bash
pnpm run dev
```

### Build
```bash
pnpm run build
```

## Contributing

Issues and Pull Requests are welcome!

## License

MIT License