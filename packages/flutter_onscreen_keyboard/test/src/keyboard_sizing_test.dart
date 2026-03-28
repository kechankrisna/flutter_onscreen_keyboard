import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens the keyboard and returns the rendered size of [RawOnscreenKeyboard].
Future<Size> _rawKeyboardSize(WidgetTester tester) async {
  OnscreenKeyboard.of(tester.element(find.byType(Scaffold))).open();
  await tester.pumpAndSettle();
  return tester.getSize(find.byType(RawOnscreenKeyboard));
}

/// Returns the size of the first ancestor Container of [RawOnscreenKeyboard].
/// This is the outer keyboard box that carries the explicit width/height.
Size _outerContainerSize(WidgetTester tester) {
  final containerFinder = find
      .ancestor(
        of: find.byType(RawOnscreenKeyboard),
        matching: find.byType(Container),
      )
      .first;
  return tester.getSize(containerFinder);
}

void main() {
  // The default test surface is 800 × 600 logical pixels.
  const surfaceHeight = 600.0;

  group('keyboard sizing', () {
    testWidgets('width only — RawOnscreenKeyboard width matches', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: OnscreenKeyboard.builder(width: (_) => 400),
          home: const Scaffold(),
        ),
      );

      final size = await _rawKeyboardSize(tester);
      expect(size.width, closeTo(400, 1));
    });

    testWidgets(
      'width + height — outer keyboard container is exactly width × height',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            builder: OnscreenKeyboard.builder(
              width: (_) => 400,
              height: (_) => 200,
            ),
            home: const Scaffold(),
          ),
        );

        OnscreenKeyboard.of(tester.element(find.byType(Scaffold))).open();
        await tester.pumpAndSettle();

        final outerSize = _outerContainerSize(tester);
        expect(outerSize.width, closeTo(400, 1));
        expect(outerSize.height, closeTo(200, 1));
      },
    );

    testWidgets(
      'height only — outer container height matches, width derived from '
      'aspect ratio',
      (tester) async {
        const layout = MobileKeyboardLayout();
        await tester.pumpWidget(
          MaterialApp(
            builder: OnscreenKeyboard.builder(
              layout: layout,
              height: (_) => 200,
            ),
            home: const Scaffold(),
          ),
        );

        OnscreenKeyboard.of(tester.element(find.byType(Scaffold))).open();
        await tester.pumpAndSettle();

        final outerSize = _outerContainerSize(tester);
        expect(outerSize.height, closeTo(200, 1));
        // width ≈ height × aspectRatio
        expect(
          outerSize.width,
          closeTo(200 * layout.aspectRatio, 1),
        );
      },
    );

    testWidgets(
      'no width/height — keyboard height is well under full screen height',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            builder: OnscreenKeyboard.builder(),
            home: const Scaffold(),
          ),
        );

        final rawSize = await _rawKeyboardSize(tester);
        final outerSize = _outerContainerSize(tester);

        // Keys-only area is driven by the 40%-of-height heuristic; bars
        // (ControlBar etc.) add overhead, so the outer box will be slightly
        // taller. The important guarantee is that the keyboard does NOT fill
        // the screen. We allow up to 55 % to accommodate bar overhead.
        expect(outerSize.height, lessThanOrEqualTo(surfaceHeight * 0.55 + 1));
        // Width must be at most the full surface width.
        expect(rawSize.width, lessThanOrEqualTo(800 + 1));
      },
    );
  });
}
