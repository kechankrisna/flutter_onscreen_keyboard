import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('switchLanguage()', () {
    const english = EnglishKeyboardLayout();
    const khmer = KhmerKeyboardLayout();

    Widget buildApp({required List<LanguageKeyboardLayout> languages}) {
      return MaterialApp(
        builder: OnscreenKeyboard.builder(
          width: (_) => 400,
          height: (_) => 200,
          supportedLanguages: languages,
        ),
        home: const Scaffold(body: OnscreenKeyboardTextField()),
      );
    }

    Future<void> openKeyboard(WidgetTester tester) async {
      await tester.tap(find.byType(OnscreenKeyboardTextField));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'tapping switch_language cycles to the next language',
      (tester) async {
        await tester.pumpWidget(
          buildApp(languages: [english, khmer]),
        );
        await openKeyboard(tester);

        // Initially on English — find the switch_language key and tap it.
        final switchKey = find.byWidgetPredicate(
          (w) => w is Icon && w.icon == Icons.language_rounded,
        );
        expect(switchKey, findsOneWidget);
        await tester.tap(switchKey);
        await tester.pumpAndSettle();

        // Layout should now be Khmer — look for a Khmer consonant key.
        expect(find.text('ក'), findsWidgets);
      },
    );

    testWidgets(
      'tapping switch_language with a single language does nothing',
      (tester) async {
        await tester.pumpWidget(
          buildApp(languages: [english]),
        );
        await openKeyboard(tester);

        // switch_language key is present in the layout but should be a no-op.
        final switchKey = find.byWidgetPredicate(
          (w) => w is Icon && w.icon == Icons.language_rounded,
        );
        expect(switchKey, findsOneWidget);
        await tester.tap(switchKey);
        await tester.pumpAndSettle();

        // Still on English — space bar text key should be present.
        expect(find.byIcon(Icons.space_bar_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'tapping switch_language twice wraps back to the first language',
      (tester) async {
        await tester.pumpWidget(
          buildApp(languages: [english, khmer]),
        );
        await openKeyboard(tester);

        final switchKey = find.byWidgetPredicate(
          (w) => w is Icon && w.icon == Icons.language_rounded,
        );

        // First tap → Khmer
        await tester.tap(switchKey);
        await tester.pumpAndSettle();
        expect(find.text('ក'), findsWidgets);

        // Second tap → back to English (swap_horiz icon for mode_switch)
        await tester.tap(switchKey);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.swap_horiz_rounded), findsWidgets);
      },
    );
  });
}
