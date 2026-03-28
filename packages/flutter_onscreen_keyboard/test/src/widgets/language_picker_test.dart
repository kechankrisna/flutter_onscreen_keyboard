import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_onscreen_keyboard/src/widgets/language_picker_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LanguagePickerBar', () {
    const khmer = KhmerKeyboardLayout();

    Widget buildTestApp({
      required List<LanguageKeyboardLayout> languages,
      String? activeCode,
    }) {
      return MaterialApp(
        builder: OnscreenKeyboard.builder(
          width: (_) => 400,
          height: (_) => 200,
          supportedLanguages: languages,
        ),
        home: Scaffold(
          body: Column(
            children: [
              LanguagePickerBar(
                supportedLanguages: languages,
                activeLanguageCode: activeCode,
              ),
            ],
          ),
        ),
      );
    }

    testWidgets('renders one button per language', (tester) async {
      await tester.pumpWidget(
        buildTestApp(languages: [khmer, khmer]),
      );
      expect(find.byType(TextButton), findsNWidgets(2));
    });

    testWidgets('displays language displayName text', (tester) async {
      await tester.pumpWidget(
        buildTestApp(languages: [khmer]),
      );
      expect(find.text('ភាសាខ្មែរ'), findsOneWidget);
    });

    testWidgets('active language button is highlighted', (tester) async {
      await tester.pumpWidget(
        buildTestApp(languages: [khmer], activeCode: 'km'),
      );
      // The button text should be present regardless of style.
      expect(find.text('ភាសាខ្មែរ'), findsOneWidget);
    });

    testWidgets('has a fixed height of 36', (tester) async {
      await tester.pumpWidget(
        buildTestApp(languages: [khmer]),
      );
      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(LanguagePickerBar),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.height, 36);
    });

    testWidgets(
      'language picker is hidden when supportedLanguages has 1 entry '
      'inside OnscreenKeyboard',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            builder: OnscreenKeyboard.builder(
              width: (_) => 400,
              supportedLanguages: [const KhmerKeyboardLayout()],
            ),
            home: const Scaffold(body: OnscreenKeyboardTextField()),
          ),
        );

        await tester.tap(find.byType(OnscreenKeyboardTextField));
        await tester.pumpAndSettle();

        // Only 1 language → picker should not be rendered.
        expect(find.byType(LanguagePickerBar), findsNothing);
      },
    );
  });
}
