import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_onscreen_keyboard/src/theme/onscreen_keyboard_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RawOnscreenKeyboard textDirection', () {
    // Helper: builds a pumpable widget tree containing a RawOnscreenKeyboard
    // with the given [textDirection].
    Widget buildKeyboard({TextDirection textDirection = TextDirection.ltr}) {
      return MaterialApp(
        home: Scaffold(
          body: OnscreenKeyboardTheme(
            data: const OnscreenKeyboardThemeData(),
            child: SizedBox(
              width: 400,
              child: RawOnscreenKeyboard(
                layout: const KhmerKeyboardLayout(),
                mode: 'consonants',
                onKeyDown: (_) {},
                onKeyUp: (_) {},
                textDirection: textDirection,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders with LTR direction', (tester) async {
      await tester.pumpWidget(buildKeyboard());
      expect(find.byType(RawOnscreenKeyboard), findsOneWidget);
    });

    testWidgets('renders with RTL direction', (tester) async {
      await tester.pumpWidget(buildKeyboard(textDirection: TextDirection.rtl));
      expect(find.byType(RawOnscreenKeyboard), findsOneWidget);
    });

    testWidgets('Directionality widget reflects LTR', (tester) async {
      await tester.pumpWidget(buildKeyboard());

      // The RawOnscreenKeyboard wraps its content in a Directionality widget.
      final directionality = tester.widget<Directionality>(
        find
            .descendant(
              of: find.byType(RawOnscreenKeyboard),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(directionality.textDirection, TextDirection.ltr);
    });

    testWidgets('Directionality widget reflects RTL', (tester) async {
      await tester.pumpWidget(
        buildKeyboard(textDirection: TextDirection.rtl),
      );

      final directionality = tester.widget<Directionality>(
        find
            .descendant(
              of: find.byType(RawOnscreenKeyboard),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(directionality.textDirection, TextDirection.rtl);
    });
  });

  group('OnscreenKeyboard RTL from KhmerKeyboardLayout', () {
    testWidgets('Khmer layout renders as LTR (isRtl=false)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: OnscreenKeyboard.builder(
            width: (_) => 400,
            supportedLanguages: [const KhmerKeyboardLayout()],
          ),
          home: const Scaffold(body: OnscreenKeyboardTextField()),
        ),
      );

      // Open the keyboard
      await tester.tap(find.byType(OnscreenKeyboardTextField));
      await tester.pumpAndSettle();

      expect(find.byType(RawOnscreenKeyboard), findsOneWidget);

      // KhmerKeyboardLayout.isRtl == false → key rows should be LTR
      final directionality = tester.widget<Directionality>(
        find
            .descendant(
              of: find.byType(RawOnscreenKeyboard),
              matching: find.byType(Directionality),
            )
            .first,
      );
      expect(directionality.textDirection, TextDirection.ltr);
    });
  });
}
