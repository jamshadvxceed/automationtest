import * as fs from 'fs';
import * as path from 'path';
import { logger } from '../utils/logger.js';

interface TestGenerationResult {
  filePath: string;
  testCode: string;
}

export class FlutterTestGenerator {
  async generateTest(
    description: string,
    testName: string,
    projectPath: string
  ): Promise<TestGenerationResult> {
    logger.info(`Generating test: ${testName}`);
    
    const testCode = this.generateTestCode(description, testName);
    const filePath = await this.saveTestFile(testCode, testName, projectPath);
    
    return { filePath, testCode };
  }

  private generateTestCode(description: string, testName: string): string {
    const testSteps = this.parseDescription(description);
    const testBody = this.generateTestBody(testSteps);

    return `import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('${testName}', () {
    testWidgets('${description}', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();

${testBody}
    });
  });
}`;
  }

  private parseDescription(description: string): TestStep[] {
    const steps: TestStep[] = [];
    const sentences = description.split(/[，。,.!？]/).filter(s => s.trim());

    for (const sentence of sentences) {
      const trimmed = sentence.trim();
      if (!trimmed) continue;

      if (this.isClickAction(trimmed)) {
        steps.push(this.parseClickAction(trimmed));
      } else if (this.isInputAction(trimmed)) {
        steps.push(this.parseInputAction(trimmed));
      } else if (this.isScrollAction(trimmed)) {
        steps.push(this.parseScrollAction(trimmed));
      } else if (this.isWaitAction(trimmed)) {
        steps.push(this.parseWaitAction(trimmed));
      } else if (this.isVerifyAction(trimmed)) {
        steps.push(this.parseVerifyAction(trimmed));
      } else {
        steps.push({
          type: 'comment',
          description: trimmed
        });
      }
    }

    return steps;
  }

  private isClickAction(text: string): boolean {
    return /点击|tap|click|按下|press/.test(text);
  }

  private isInputAction(text: string): boolean {
    return /输入|input|enter|type|填写/.test(text);
  }

  private isScrollAction(text: string): boolean {
    return /滚动|scroll|滑动|swipe|上滑|下滑|左滑|右滑/.test(text);
  }

  private isWaitAction(text: string): boolean {
    return /等待|wait|延时|delay|暂停|pause/.test(text);
  }

  private isVerifyAction(text: string): boolean {
    return /验证|verify|检查|check|确认|confirm|应该|should|存在|显示|appear/.test(text);
  }

  private parseClickAction(text: string): TestStep {
    const buttonMatch = text.match(/点击.*?[按钮|button].*?["']([^"']+)["']|点击.*?["']([^"']+)["'].*?[按钮|button]|点击.*?([^点击，。]+)/);
    const target = buttonMatch ? (buttonMatch[1] || buttonMatch[2] || buttonMatch[3]).trim() : '按钮';
    
    return {
      type: 'tap',
      target: target,
      finder: this.determineFinder(target)
    };
  }

  private parseInputAction(text: string): TestStep {
    const inputMatch = text.match(/输入.*?["']([^"']+)["']|在.*?([^在，。]+).*?输入.*?["']([^"']+)["']|输入.*?([^输入，。]+)/);
    const valueMatch = text.match(/["']([^"']+)["']/);
    
    const field = inputMatch ? (inputMatch[2] || '输入框').trim() : '输入框';
    const value = valueMatch ? valueMatch[1] : inputMatch?.[1] || inputMatch?.[3] || inputMatch?.[4] || '';
    
    return {
      type: 'input',
      target: field,
      value: value,
      finder: this.determineFinder(field)
    };
  }

  private parseScrollAction(text: string): TestStep {
    let direction = 'down';
    if (/上滑|向上|up/.test(text)) direction = 'up';
    else if (/下滑|向下|down/.test(text)) direction = 'down';
    else if (/左滑|向左|left/.test(text)) direction = 'left';
    else if (/右滑|向右|right/.test(text)) direction = 'right';

    return {
      type: 'scroll',
      direction: direction as 'up' | 'down' | 'left' | 'right',
      distance: 300
    };
  }

  private parseWaitAction(text: string): TestStep {
    const timeMatch = text.match(/(\\d+(?:\\.\\d+)?)(秒|second|s|毫秒|ms|分钟|min|m)/);
    let seconds = 2;
    
    if (timeMatch) {
      const value = parseFloat(timeMatch[1]);
      const unit = timeMatch[2];
      
      if (unit.includes('毫秒') || unit === 'ms') {
        seconds = value / 1000;
      } else if (unit.includes('分钟') || unit === 'min' || unit === 'm') {
        seconds = value * 60;
      } else {
        seconds = value;
      }
    }

    return {
      type: 'wait',
      duration: seconds
    };
  }

  private parseVerifyAction(text: string): TestStep {
    const textMatch = text.match(/验证.*?["']([^"']+)["']|检查.*?["']([^"']+)["']|确认.*?["']([^"']+)["']|["']([^"']+)["'].*?[存在|显示]/);
    const target = textMatch ? (textMatch[1] || textMatch[2] || textMatch[3] || textMatch[4]).trim() : text.trim();
    
    const shouldExist = !/不存在|不显示|没有|not/.test(text);
    
    return {
      type: 'verify',
      target: target,
      shouldExist: shouldExist,
      finder: this.determineFinder(target)
    };
  }

  private determineFinder(target: string): string {
    if (target.includes('Key(') || target.includes('key:')) {
      return 'key';
    } else if (target.includes('Type:') || target.includes('类型:')) {
      return 'type';
    } else {
      return 'text';
    }
  }

  private generateTestBody(steps: TestStep[]): string {
    const codeLines: string[] = [];

    for (const step of steps) {
      switch (step.type) {
        case 'tap':
          codeLines.push(this.generateTapCode(step));
          break;
        case 'input':
          codeLines.push(this.generateInputCode(step));
          break;
        case 'scroll':
          codeLines.push(this.generateScrollCode(step));
          break;
        case 'wait':
          codeLines.push(this.generateWaitCode(step));
          break;
        case 'verify':
          codeLines.push(this.generateVerifyCode(step));
          break;
        case 'comment':
          codeLines.push(`      // ${step.description}`);
          break;
      }
      codeLines.push('');
    }

    return codeLines.join('\n');
  }

  private generateTapCode(step: TestStep): string {
    const finder = this.generateFinder(step.finder!, step.target!);
    return `      // 点击 ${step.target}
      await tester.tap(${finder});
      await tester.pumpAndSettle();`;
  }

  private generateInputCode(step: TestStep): string {
    const finder = this.generateFinder(step.finder!, step.target!);
    return `      // 在 ${step.target} 中输入 ${step.value}
      await tester.enterText(${finder}, '${step.value}');
      await tester.pumpAndSettle();`;
  }

  private generateScrollCode(step: TestStep): string {
    const offset = this.getScrollOffset(step.direction!, step.distance || 300);
    return `      // 滚动 ${step.direction} ${step.distance}px
      await tester.drag(find.byType(Scrollable).first, Offset(${offset.dx}, ${offset.dy}));
      await tester.pumpAndSettle();`;
  }

  private generateWaitCode(step: TestStep): string {
    return `      // 等待 ${step.duration} 秒
      await Future.delayed(Duration(milliseconds: ${Math.round(step.duration! * 1000)}));`;
  }

  private generateVerifyCode(step: TestStep): string {
    const finder = this.generateFinder(step.finder!, step.target!);
    const expectation = step.shouldExist ? 'findsOneWidget' : 'findsNothing';
    return `      // 验证 ${step.target} ${step.shouldExist ? '存在' : '不存在'}
      expect(${finder}, ${expectation});`;
  }

  private generateFinder(finderType: string, value: string): string {
    switch (finderType) {
      case 'key':
        const keyValue = value.includes('Key(') ? value : `Key('${value}')`;
        return `find.byKey(${keyValue})`;
      case 'type':
        const typeValue = value.replace(/^Type:/, '').trim();
        return `find.byType(${typeValue})`;
      case 'text':
      default:
        return `find.text('${value}')`;
    }
  }

  private getScrollOffset(direction: 'up' | 'down' | 'left' | 'right', distance: number): { dx: number, dy: number } {
    switch (direction) {
      case 'up': return { dx: 0, dy: distance };
      case 'down': return { dx: 0, dy: -distance };
      case 'left': return { dx: distance, dy: 0 };
      case 'right': return { dx: -distance, dy: 0 };
      default: return { dx: 0, dy: -distance };
    }
  }

  private async saveTestFile(testCode: string, testName: string, projectPath: string): Promise<string> {
    const testDir = path.join(projectPath, 'integration_test');
    
    if (!fs.existsSync(testDir)) {
      fs.mkdirSync(testDir, { recursive: true });
    }

    const fileName = `${testName.toLowerCase().replace(/[\\s]+/g, '_').replace(/[^a-z0-9_]/g, '')}_test.dart`;
    const filePath = path.join(testDir, fileName);
    
    fs.writeFileSync(filePath, testCode, 'utf8');
    
    logger.info(`Test file saved: ${filePath}`);
    return filePath;
  }
}

interface TestStep {
  type: 'tap' | 'input' | 'scroll' | 'wait' | 'verify' | 'comment';
  target?: string;
  value?: string;
  finder?: string;
  direction?: 'up' | 'down' | 'left' | 'right';
  distance?: number;
  duration?: number;
  shouldExist?: boolean;
  description?: string;
}