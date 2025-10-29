export class UIActions {
  generateFindCode(finder: string, value: string): string {
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
      case 'ancestor':
        return `find.ancestor(of: find.text('${value}'), matching: find.byType(Widget))`;
      case 'descendant':
        return `find.descendant(of: find.byType(${value}), matching: find.byType(Widget))`;
      default:
        return `find.text('${value}')`;
    }
  }

  generateTapCode(finder: string, value: string): string {
    const findCode = this.generateFindCode(finder, value);
    return `await tester.tap(${findCode});
await tester.pumpAndSettle();`;
  }

  generateDoubleTapCode(finder: string, value: string): string {
    const findCode = this.generateFindCode(finder, value);
    return `await tester.tap(${findCode});
await tester.pump(Duration(milliseconds: 100));
await tester.tap(${findCode});
await tester.pumpAndSettle();`;
  }

  generateLongPressCode(finder: string, value: string): string {
    const findCode = this.generateFindCode(finder, value);
    return `await tester.longPress(${findCode});
await tester.pumpAndSettle();`;
  }

  generateEnterTextCode(finder: string, value: string, text: string): string {
    const findCode = this.generateFindCode(finder, value);
    return `await tester.enterText(${findCode}, '${text}');
await tester.pumpAndSettle();`;
  }

  generateScrollCode(
    direction: 'up' | 'down' | 'left' | 'right',
    distance: number = 300,
    finder?: string,
    value?: string
  ): string {
    const offset = this.getScrollOffset(direction, distance);
    
    if (finder && value) {
      const findCode = this.generateFindCode(finder, value);
      return `await tester.drag(${findCode}, Offset(${offset.dx}, ${offset.dy}));
await tester.pumpAndSettle();`;
    } else {
      return `await tester.drag(find.byType(Scrollable).first, Offset(${offset.dx}, ${offset.dy}));
await tester.pumpAndSettle();`;
    }
  }

  generateScrollUntilVisibleCode(
    targetFinder: string,
    targetValue: string,
    scrollableFinder?: string,
    scrollableValue?: string
  ): string {
    const targetFindCode = this.generateFindCode(targetFinder, targetValue);
    const scrollableFindCode = scrollableFinder && scrollableValue 
      ? this.generateFindCode(scrollableFinder, scrollableValue)
      : 'find.byType(Scrollable).first';

    return `await tester.scrollUntilVisible(
  ${targetFindCode},
  500.0,
  scrollable: ${scrollableFindCode},
);
await tester.pumpAndSettle();`;
  }

  generateVerifyTextCode(text: string, shouldExist: boolean = true): string {
    const expectation = shouldExist ? 'findsOneWidget' : 'findsNothing';
    return `expect(find.text('${text}'), ${expectation});`;
  }

  generateVerifyElementCode(finder: string, value: string, shouldExist: boolean = true): string {
    const findCode = this.generateFindCode(finder, value);
    const expectation = shouldExist ? 'findsOneWidget' : 'findsNothing';
    return `expect(${findCode}, ${expectation});`;
  }

  generateVerifyMultipleElementsCode(finder: string, value: string, count: number): string {
    const findCode = this.generateFindCode(finder, value);
    return `expect(${findCode}, findsNWidgets(${count}));`;
  }

  generateScreenshotCode(filename?: string): string {
    const name = filename || `screenshot_\${DateTime.now().millisecondsSinceEpoch}`;
    return `await binding.convertFlutterSurfaceToImage();
await binding.takeScreenshot('${name}');`;
  }

  generateDragCode(
    fromFinder: string,
    fromValue: string,
    toFinder: string,
    toValue: string
  ): string {
    const fromFindCode = this.generateFindCode(fromFinder, fromValue);
    const toFindCode = this.generateFindCode(toFinder, toValue);
    
    return `final fromCenter = tester.getCenter(${fromFindCode});
final toCenter = tester.getCenter(${toFindCode});
await tester.dragFrom(fromCenter, toCenter - fromCenter);
await tester.pumpAndSettle();`;
  }

  generateSwipeCode(
    finder: string,
    value: string,
    direction: 'up' | 'down' | 'left' | 'right',
    distance: number = 300
  ): string {
    const findCode = this.generateFindCode(finder, value);
    const offset = this.getScrollOffset(direction, distance);
    
    return `await tester.fling(${findCode}, Offset(${offset.dx}, ${offset.dy}), 1000);
await tester.pumpAndSettle();`;
  }

  generateTapAtCoordinatesCode(x: number, y: number): string {
    return `await tester.tapAt(Offset(${x}, ${y}));
await tester.pumpAndSettle();`;
  }

  generateSelectDropdownCode(
    dropdownFinder: string,
    dropdownValue: string,
    optionText: string
  ): string {
    const dropdownFindCode = this.generateFindCode(dropdownFinder, dropdownValue);
    
    return `await tester.tap(${dropdownFindCode});
await tester.pumpAndSettle();
await tester.tap(find.text('${optionText}').last);
await tester.pumpAndSettle();`;
  }

  generateToggleSwitchCode(finder: string, value: string): string {
    const findCode = this.generateFindCode(finder, value);
    return `await tester.tap(${findCode});
await tester.pumpAndSettle();`;
  }

  private getScrollOffset(
    direction: 'up' | 'down' | 'left' | 'right',
    distance: number
  ): { dx: number; dy: number } {
    switch (direction) {
      case 'up':
        return { dx: 0, dy: distance };
      case 'down':
        return { dx: 0, dy: -distance };
      case 'left':
        return { dx: distance, dy: 0 };
      case 'right':
        return { dx: -distance, dy: 0 };
      default:
        return { dx: 0, dy: -distance };
    }
  }
}