export interface TestGenerationOptions {
  screenName: string;
  testType: string;
  scenario?: string;
  screenAnalysis: any;
}

export class TestGenerator {
  async generateTest(options: TestGenerationOptions): Promise<string> {
    const { screenName, testType, scenario, screenAnalysis } = options;

    switch (testType) {
      case "authentication":
        return this.generateAuthTest(screenName, screenAnalysis, scenario);
      case "form":
        return this.generateFormTest(screenName, screenAnalysis, scenario);
      case "navigation":
        return this.generateNavigationTest(screenName, screenAnalysis, scenario);
      default:
        return this.generateCustomTest(screenName, screenAnalysis, scenario);
    }
  }

  private generateAuthTest(screenName: string, analysis: any, scenario?: string): string {
    const testName = scenario || `${screenName} authentication flow`;
    const textFieldCount = analysis.textFields?.length || 0;
    
    return `import 'package:automationtest/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('${testName}', (\$) async {
    // Start the app
    await \$.pumpWidgetAndSettle(const MyApp());

    // Wait for navigation
    await \$.pumpAndSettle(timeout: const Duration(seconds: 5));

    // Verify screen elements
    ${this.generateScreenVerification(analysis)}

    // Enter credentials
    ${this.generateTextFieldInteractions(textFieldCount)}

    // Submit form
    ${this.generateButtonTap(analysis)}

    // Wait for response
    await \$.pumpAndSettle(timeout: const Duration(seconds: 5));

    // Verify navigation or result
    // TODO: Add your verification logic
    // Example: expect(\$('Dashboard'), findsOneWidget);
  });
}
`;
  }

  private generateFormTest(screenName: string, analysis: any, scenario?: string): string {
    const testName = scenario || `${screenName} form submission`;
    const textFieldCount = analysis.textFields?.length || 0;
    
    return `import 'package:automationtest/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('${testName}', (\$) async {
    // Start the app
    await \$.pumpWidgetAndSettle(const MyApp());
    await \$.pumpAndSettle(timeout: const Duration(seconds: 5));

    ${this.generateScreenVerification(analysis)}

    // Fill form fields
    ${this.generateTextFieldInteractions(textFieldCount)}

    // Submit form
    ${this.generateButtonTap(analysis)}

    // Wait and verify
    await \$.pumpAndSettle(timeout: const Duration(seconds: 5));
    
    // TODO: Add success verification
    // Example: expect(\$('Success message'), findsOneWidget);
  });
}
`;
  }

  private generateNavigationTest(screenName: string, analysis: any, scenario?: string): string {
    const testName = scenario || `Navigate to ${screenName}`;
    
    return `import 'package:automationtest/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('${testName}', (\$) async {
    // Start the app
    await \$.pumpWidgetAndSettle(const MyApp());
    await \$.pumpAndSettle(timeout: const Duration(seconds: 5));
    
    // TODO: Add navigation trigger (button tap, gesture, etc.)
    // Example: await \$('Go to ${screenName}').tap();
    
    await \$.pumpAndSettle(timeout: const Duration(seconds: 5));
    
    // Verify we're on ${screenName}
    ${this.generateScreenVerification(analysis)}
  });
}
`;
  }

  private generateCustomTest(screenName: string, analysis: any, scenario?: string): string {
    const testName = scenario || `${screenName} test`;
    
    return `import 'package:automationtest/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest('${testName}', (\$) async {
    // Start the app
    await \$.pumpWidgetAndSettle(const MyApp());
    await \$.pumpAndSettle(timeout: const Duration(seconds: 5));

    // Screen: ${screenName}
    // Detected elements:
    // - Text fields: ${analysis.textFields?.length || 0}
    // - Buttons: ${analysis.buttons?.length || 0}
    // - Widgets: ${analysis.widgets?.length || 0}
    
    ${this.generateScreenVerification(analysis)}

    // TODO: Implement your test scenario here
    ${analysis.textFields?.length > 0 ? '\n    // ' + this.generateTextFieldInteractions(analysis.textFields.length).split('\n').join('\n    // ') : ''}
    ${analysis.buttons?.length > 0 ? '\n    // ' + this.generateButtonTap(analysis) : ''}
    
    // Add assertions
  });
}
`;
  }

  private generateScreenVerification(analysis: any): string {
    if (!analysis.texts || analysis.texts.length === 0) {
      return `// Verify screen is displayed\n    // TODO: Add screen verification`;
    }
    
    const firstText = analysis.texts[0];
    return `// Verify we're on the correct screen\n    expect(\$('${firstText}'), findsOneWidget);`;
  }

  private generateTextFieldInteractions(count: number): string {
    if (count === 0) return "// No text fields found";

    let code = "";
    for (let i = 0; i < Math.min(count, 5); i++) {
      code += `await \$(TextFormField).at(${i}).enterText('test_value_${i + 1}');\n    await \$.pumpAndSettle();\n`;
      if (i < count - 1) code += "\n    ";
    }
    return code.trim();
  }

  private generateButtonTap(analysis: any): string {
    const buttonTexts = ['Submit', 'Login', 'Save', 'Continue', 'Next'];
    
    // Try to find a button text from analysis
    if (analysis.texts && analysis.texts.length > 0) {
      for (const text of analysis.texts) {
        if (buttonTexts.some(btn => text.toLowerCase().includes(btn.toLowerCase()))) {
          return `await \$('${text}').tap();`;
        }
      }
    }
    
    // Fallback
    if (analysis.buttons && analysis.buttons.length > 0) {
      return `// Tap button (adjust text as needed)\n    await \$('Submit').tap();`;
    }
    
    return "// No buttons found";
  }

  async generateTestSuite(analysis: any, coverage: string): Promise<any> {
    const tests = [];

    for (const screen of analysis.screens) {
      const testType = this.determineTestType(screen);
      
      tests.push({
        file: `integration_test/${screen.name.toLowerCase()}_test.dart`,
        content: await this.generateTest({
          screenName: screen.name,
          testType,
          screenAnalysis: screen,
        }),
      });
    }

    return { 
      tests, 
      coverage, 
      totalScreens: analysis.screens.length,
      summary: `Generated ${tests.length} tests with ${coverage} coverage`
    };
  }

  private determineTestType(screen: any): string {
    const name = screen.name.toLowerCase();
    
    if (name.includes('login') || name.includes('auth') || name.includes('signin')) {
      return 'authentication';
    }
    
    if (screen.textFields?.length >= 2) {
      return 'form';
    }
    
    if (screen.routes?.length > 0) {
      return 'navigation';
    }
    
    return 'custom';
  }
}