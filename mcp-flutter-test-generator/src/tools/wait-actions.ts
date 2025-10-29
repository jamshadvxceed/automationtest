export class WaitActions {
  generateWaitForElementCode(
    finder: string,
    value: string,
    timeout: number = 10
  ): string {
    const findCode = this.generateFindCode(finder, value);
    const timeoutMs = timeout * 1000;
    
    return `// 等待元素出现，超时时间：${timeout}秒
final stopwatch = Stopwatch()..start();
while (stopwatch.elapsedMilliseconds < ${timeoutMs}) {
  await tester.pump(Duration(milliseconds: 100));
  if (tester.any(${findCode})) {
    break;
  }
}
expect(${findCode}, findsOneWidget);`;
  }

  generateWaitForElementToDisappearCode(
    finder: string,
    value: string,
    timeout: number = 10
  ): string {
    const findCode = this.generateFindCode(finder, value);
    const timeoutMs = timeout * 1000;
    
    return `// 等待元素消失，超时时间：${timeout}秒
final stopwatch = Stopwatch()..start();
while (stopwatch.elapsedMilliseconds < ${timeoutMs}) {
  await tester.pump(Duration(milliseconds: 100));
  if (!tester.any(${findCode})) {
    break;
  }
}
expect(${findCode}, findsNothing);`;
  }

  generateWaitForTextCode(text: string, timeout: number = 10): string {
    const timeoutMs = timeout * 1000;
    
    return `// 等待文本出现：${text}，超时时间：${timeout}秒
final stopwatch = Stopwatch()..start();
while (stopwatch.elapsedMilliseconds < ${timeoutMs}) {
  await tester.pump(Duration(milliseconds: 100));
  if (tester.any(find.text('${text}'))) {
    break;
  }
}
expect(find.text('${text}'), findsOneWidget);`;
  }

  generateWaitForTextToDisappearCode(text: string, timeout: number = 10): string {
    const timeoutMs = timeout * 1000;
    
    return `// 等待文本消失：${text}，超时时间：${timeout}秒
final stopwatch = Stopwatch()..start();
while (stopwatch.elapsedMilliseconds < ${timeoutMs}) {
  await tester.pump(Duration(milliseconds: 100));
  if (!tester.any(find.text('${text}'))) {
    break;
  }
}
expect(find.text('${text}'), findsNothing);`;
  }

  generateDelayCode(seconds: number): string {
    const milliseconds = Math.round(seconds * 1000);
    return `// 延时 ${seconds} 秒
await Future.delayed(Duration(milliseconds: ${milliseconds}));`;
  }

  generateWaitForAnimationCode(duration: number = 1): string {
    const milliseconds = Math.round(duration * 1000);
    return `// 等待动画完成，时间：${duration}秒
await tester.pump(Duration(milliseconds: ${milliseconds}));
await tester.pumpAndSettle();`;
  }

  generateWaitForConditionCode(
    condition: string,
    timeout: number = 10,
    description?: string
  ): string {
    const timeoutMs = timeout * 1000;
    const desc = description || '条件满足';
    
    return `// 等待${desc}，超时时间：${timeout}秒
final stopwatch = Stopwatch()..start();
while (stopwatch.elapsedMilliseconds < ${timeoutMs}) {
  await tester.pump(Duration(milliseconds: 100));
  if (${condition}) {
    break;
  }
}
expect(${condition}, isTrue);`;
  }

  generateWaitForLoadingToFinishCode(
    loadingFinder: string = 'key',
    loadingValue: string = 'loading_indicator',
    timeout: number = 30
  ): string {
    const findCode = this.generateFindCode(loadingFinder, loadingValue);
    const timeoutMs = timeout * 1000;
    
    return `// 等待加载完成，超时时间：${timeout}秒
final stopwatch = Stopwatch()..start();
while (stopwatch.elapsedMilliseconds < ${timeoutMs}) {
  await tester.pump(Duration(milliseconds: 100));
  if (!tester.any(${findCode})) {
    break;
  }
}
expect(${findCode}, findsNothing);`;
  }

  generateWaitForPageToLoadCode(
    pageIdentifierFinder: string,
    pageIdentifierValue: string,
    timeout: number = 15
  ): string {
    const findCode = this.generateFindCode(pageIdentifierFinder, pageIdentifierValue);
    const timeoutMs = timeout * 1000;
    
    return `// 等待页面加载完成，超时时间：${timeout}秒
final stopwatch = Stopwatch()..start();
while (stopwatch.elapsedMilliseconds < ${timeoutMs}) {
  await tester.pumpAndSettle(Duration(milliseconds: 100));
  if (tester.any(${findCode})) {
    break;
  }
}
expect(${findCode}, findsOneWidget);`;
  }

  generateWaitForNetworkResponseCode(timeout: number = 20): string {
    return `// 等待网络请求完成，超时时间：${timeout}秒
await tester.pump(Duration(milliseconds: 100));
await tester.pumpAndSettle(Duration(seconds: ${timeout}));`;
  }

  generateWaitUntilSettledCode(timeout: number = 10): string {
    const timeoutMs = timeout * 1000;
    
    return `// 等待UI稳定，超时时间：${timeout}秒
final endTime = DateTime.now().add(Duration(milliseconds: ${timeoutMs}));
while (DateTime.now().isBefore(endTime)) {
  await tester.pump(Duration(milliseconds: 100));
  final hasScheduledFrame = WidgetsBinding.instance.hasScheduledFrame;
  if (!hasScheduledFrame) {
    await tester.pump(Duration(milliseconds: 100));
    if (!WidgetsBinding.instance.hasScheduledFrame) {
      break;
    }
  }
}`;
  }

  generateRetryActionCode(
    action: string,
    maxAttempts: number = 3,
    delayBetweenAttempts: number = 1
  ): string {
    const delayMs = Math.round(delayBetweenAttempts * 1000);
    
    return `// 重试操作，最大尝试次数：${maxAttempts}
bool actionSucceeded = false;
for (int attempt = 1; attempt <= ${maxAttempts} && !actionSucceeded; attempt++) {
  try {
    ${action}
    actionSucceeded = true;
  } catch (e) {
    if (attempt == ${maxAttempts}) {
      rethrow;
    }
    await Future.delayed(Duration(milliseconds: ${delayMs}));
  }
}`;
  }

  private generateFindCode(finder: string, value: string): string {
    switch (finder.toLowerCase()) {
      case 'text':
        return `find.text('${value}')`;
      case 'key':
        const keyValue = value.includes('Key(') ? value : `Key('${value}')`;
        return `find.byKey(${keyValue})`;
      case 'type':
        return `find.byType(${value})`;
      case 'icon':
        return `find.byIcon(Icons.${value})`;
      case 'tooltip':
        return `find.byTooltip('${value}')`;
      case 'semantics':
        return `find.bySemanticsLabel('${value}')`;
      default:
        return `find.text('${value}')`;
    }
  }
}