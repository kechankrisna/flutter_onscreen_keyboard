import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberPad auto-switch via keyboardType', () {
    Widget buildApp({
      TextInputType? numericFieldKeyboardType,
      List<LanguageKeyboardLayout>? languages,
    }) {
      return MaterialApp(
        builder: OnscreenKeyboard.builder(
          width: (_) => 400,
          height: (_) => 300,
          supportedLanguages: languages ?? [const EnglishKeyboardLayout()],
        ),
        home: Scaffold(
          body: Column(
            children: [
              OnscreenKeyboardTextField(
                key: const ValueKey('numeric'),
                keyboardType: numericFieldKeyboardType ?? TextInputType.number,
                decoration: const InputDecoration(labelText: 'Number'),
              ),
              const OnscreenKeyboardTextField(
                key: ValueKey('text'),
                decoration: InputDecoration(labelText: 'Text'),
              ),
            ],
          ),
        ),
      );
    }

    OnscreenKeyboardController controller(WidgetTester tester) =>
        OnscreenKeyboard.of(tester.element(find.byType(Scaffold)));

    testWidgets(
      'focusing a TextInputType.number field switches to NumberPadKeyboardLayout',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await tester.tap(find.byKey(const ValueKey('numeric')));
        await tester.pumpAndSettle();

        expect(
          controller(tester).layout,
          isA<NumberPadKeyboardLayout>(),
        );
      },
    );

    testWidgets(
      'TextInputType.number numpad has decimal=false and signed=false',
      (tester) async {
        await tester.pumpWidget(
          buildApp(numericFieldKeyboardType: TextInputType.number),
        );
        await tester.tap(find.byKey(const ValueKey('numeric')));
        await tester.pumpAndSettle();

        final layout = controller(tester).layout as NumberPadKeyboardLayout;
        expect(layout.decimal, isFalse);
        expect(layout.signed, isFalse);
      },
    );

    testWidgets(
      'TextInputType.numberWithOptions(decimal:true, signed:true) sets flags',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            numericFieldKeyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
          ),
        );
        await tester.tap(find.byKey(const ValueKey('numeric')));
        await tester.pumpAndSettle();

        final layout = controller(tester).layout as NumberPadKeyboardLayout;
        expect(layout.decimal, isTrue);
        expect(layout.signed, isTrue);
      },
    );

    testWidgets(
      'focusing a regular text field after numpad restores the prior layout',
      (tester) async {
        const english = EnglishKeyboardLayout();
        await tester.pumpWidget(buildApp(languages: [english]));

        // Focus the number field → switches to numpad.
        await tester.tap(find.byKey(const ValueKey('numeric')));
        await tester.pumpAndSettle();
        expect(controller(tester).layout, isA<NumberPadKeyboardLayout>());

        // Focus the text field → restores English layout.
        await tester.tap(find.byKey(const ValueKey('text')));
        await tester.pumpAndSettle();
        expect(controller(tester).layout, isA<EnglishKeyboardLayout>());
      },
    );

    testWidgets(
      'numpad layout shows only 0 and backspace by default (no ± or .)',
      (tester) async {
        await tester.pumpWidget(
          buildApp(numericFieldKeyboardType: TextInputType.number),
        );
        await tester.tap(find.byKey(const ValueKey('numeric')));
        await tester.pumpAndSettle();

        expect(find.text('0'), findsOneWidget);
        expect(find.text('±'), findsNothing);
        expect(find.text('.'), findsNothing);
      },
    );

    testWidgets(
      'numpad with decimal=true shows "." key',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            numericFieldKeyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
        );
        await tester.tap(find.byKey(const ValueKey('numeric')));
        await tester.pumpAndSettle();

        expect(find.text('.'), findsOneWidget);
      },
    );

    testWidgets(
      'numpad with signed=true shows "±" key',
      (tester) async {
        await tester.pumpWidget(
          buildApp(
            numericFieldKeyboardType: const TextInputType.numberWithOptions(
              signed: true,
            ),
          ),
        );
        await tester.tap(find.byKey(const ValueKey('numeric')));
        await tester.pumpAndSettle();

        expect(find.text('±'), findsOneWidget);
      },
    );
  });
}
