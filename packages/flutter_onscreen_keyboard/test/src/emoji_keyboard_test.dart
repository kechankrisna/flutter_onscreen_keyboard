import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_onscreen_keyboard/src/widgets/emoji_keyboard_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Shared helpers ──────────────────────────────────────────────────────────

  /// Builds an app with [OnscreenKeyboard] and a text field using the given
  /// [layout]. Width + height are fixed so test layout is deterministic.
  Widget buildApp({
    LanguageKeyboardLayout layout = const EnglishKeyboardLayout(),
  }) {
    return MaterialApp(
      builder: OnscreenKeyboard.builder(
        width: (_) => 400,
        height: (_) => 240,
        supportedLanguages: [layout],
      ),
      home: const Scaffold(body: OnscreenKeyboardTextField()),
    );
  }

  /// Opens the keyboard by tapping the text field and waiting for animations.
  Future<void> openKeyboard(WidgetTester tester) async {
    await tester.tap(find.byType(OnscreenKeyboardTextField));
    await tester.pumpAndSettle();
  }

  /// Finds and taps the emoji switch key (😊 text widget in the keyboard).
  Future<void> tapEmojiKey(WidgetTester tester) async {
    // The emoji action key is rendered as a Text('😊') inside ActionKeyWidget.
    final emojiKey = find.descendant(
      of: find.byType(RawOnscreenKeyboard),
      matching: find.text('😊'),
    );
    expect(emojiKey, findsOneWidget);
    await tester.tap(emojiKey);
    await tester.pumpAndSettle();
  }

  // ── EmojiKeyboardWidget renders ─────────────────────────────────────────────

  group('EmojiKeyboardWidget renders', () {
    testWidgets(
      'emoji mode shows EmojiKeyboardWidget after tapping emoji key (English)',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        expect(find.byType(EmojiKeyboardWidget), findsOneWidget);
      },
    );

    testWidgets(
      'emoji mode shows EmojiKeyboardWidget after tapping emoji key (Khmer)',
      (tester) async {
        await tester.pumpWidget(buildApp(layout: const KhmerKeyboardLayout()));
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        expect(find.byType(EmojiKeyboardWidget), findsOneWidget);
      },
    );

    testWidgets(
      'emoji mode has no layout overflow error',
      (tester) async {
        // Collect flutter errors during the test.
        final errors = <FlutterErrorDetails>[];
        final original = FlutterError.onError;
        FlutterError.onError = errors.add;

        await tester.pumpWidget(buildApp());
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        FlutterError.onError = original;
        expect(errors, isEmpty, reason: 'No render exceptions expected');
      },
    );

    testWidgets(
      'emoji keyboard shows category tab strip',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        // Each category icon should appear in the tab strip.
        for (final cat in emojiCategories) {
          expect(find.text(cat.icon), findsWidgets);
        }
      },
    );

    testWidgets(
      'emoji keyboard shows section headers for visible categories',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        // The first category header is always visible.
        expect(find.text(emojiCategories.first.name), findsOneWidget);
      },
    );

    testWidgets(
      'emoji keyboard shows backspace action key',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        expect(
          find.descendant(
            of: find.byType(EmojiKeyboardWidget),
            matching: find.byIcon(Icons.backspace_outlined),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'emoji keyboard shows back-to-keyboard label for English',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        expect(
          find.descendant(
            of: find.byType(EmojiKeyboardWidget),
            matching: find.text('ABC'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'emoji keyboard shows back-to-keyboard label for Khmer',
      (tester) async {
        await tester.pumpWidget(buildApp(layout: const KhmerKeyboardLayout()));
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        // 'ក' is the back label for Khmer emoji mode.
        expect(
          find.descendant(
            of: find.byType(EmojiKeyboardWidget),
            matching: find.text('ក'),
          ),
          findsOneWidget,
        );
      },
    );
  });

  // ── Emoji insertion ─────────────────────────────────────────────────────────

  group('EmojiKeyboardWidget inserts emoji', () {
    testWidgets(
      'tapping an emoji appends it to the text field',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        // Use the second emoji to avoid hitting the category tab icon (which
        // is always the same as emojis[0] and would navigate instead of insert).
        final cat = emojiCategories.first;
        final targetEmoji = cat.emojis[1];
        await tester.tap(find.text(targetEmoji).first);
        await tester.pumpAndSettle();

        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.controller!.text, contains(targetEmoji));
      },
    );

    testWidgets(
      'tapping multiple emoji appends each in order',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        // Skip emojis[0] because it doubles as the category tab icon.
        final emojis = emojiCategories.first.emojis.skip(1).take(3).toList();
        for (final e in emojis) {
          await tester.tap(find.text(e).first);
          await tester.pump();
        }
        await tester.pumpAndSettle();

        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.controller!.text, equals(emojis.join()));
      },
    );
  });

  // ── Backspace ───────────────────────────────────────────────────────────────

  group('EmojiKeyboardWidget backspace', () {
    testWidgets(
      'tapping backspace removes the last inserted emoji',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        // Use emojis[1] to avoid hitting the category tab icon (emojis[0]).
        final firstEmoji = emojiCategories.first.emojis[1];
        await tester.tap(find.text(firstEmoji).first);
        await tester.pump();

        // Now delete it.
        await tester.tap(
          find.descendant(
            of: find.byType(EmojiKeyboardWidget),
            matching: find.byIcon(Icons.backspace_outlined),
          ),
        );
        await tester.pumpAndSettle();

        final tf = tester.widget<TextField>(find.byType(TextField));
        expect(tf.controller!.text, isEmpty);
      },
    );
  });

  // ── Back-to-keyboard navigation ─────────────────────────────────────────────

  group('EmojiKeyboardWidget navigation', () {
    testWidgets(
      'tapping back label returns to alphabets mode (English)',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        expect(find.byType(EmojiKeyboardWidget), findsOneWidget);

        // Tap the 'ABC' back key.
        await tester.tap(
          find.descendant(
            of: find.byType(EmojiKeyboardWidget),
            matching: find.text('ABC'),
          ),
        );
        await tester.pumpAndSettle();

        // EmojiKeyboardWidget should be gone; alphabets mode is back.
        expect(find.byType(EmojiKeyboardWidget), findsNothing);
        // A key unique to alphabets mode: the space bar icon.
        expect(find.byIcon(Icons.space_bar_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'tapping back label returns to khmer mode (Khmer)',
      (tester) async {
        await tester.pumpWidget(buildApp(layout: const KhmerKeyboardLayout()));
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        expect(find.byType(EmojiKeyboardWidget), findsOneWidget);

        await tester.tap(
          find.descendant(
            of: find.byType(EmojiKeyboardWidget),
            matching: find.text('ក'),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(EmojiKeyboardWidget), findsNothing);
        expect(find.byIcon(Icons.space_bar_rounded), findsOneWidget);
      },
    );

    testWidgets(
      'can re-open emoji mode after returning to keyboard',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        // Go back to alphabets.
        await tester.tap(
          find.descendant(
            of: find.byType(EmojiKeyboardWidget),
            matching: find.text('ABC'),
          ),
        );
        await tester.pumpAndSettle();

        // Open emoji again.
        await tapEmojiKey(tester);
        expect(find.byType(EmojiKeyboardWidget), findsOneWidget);
      },
    );
  });

  // ── Category tab interaction ────────────────────────────────────────────────

  group('EmojiKeyboardWidget category tabs', () {
    testWidgets(
      'first category tab is active by default',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        // The first section header should be visible in the emoji grid.
        expect(find.text(emojiCategories.first.name), findsOneWidget);
      },
    );

    testWidgets(
      'tapping a category tab scrolls to that section',
      (tester) async {
        await tester.pumpWidget(buildApp());
        await openKeyboard(tester);
        await tapEmojiKey(tester);

        // Tap the second category tab (Animals & Nature icon).
        final secondCat = emojiCategories[1];
        // The icon appears in the tab strip.
        await tester.tap(find.text(secondCat.icon).first);
        await tester.pumpAndSettle();

        // After scrolling, the second category header should be visible.
        expect(find.text(secondCat.name), findsOneWidget);
      },
    );
  });

  // ── EmojiCategory data integrity ────────────────────────────────────────────

  group('EmojiCategory data', () {
    test('emojiCategories is non-empty', () {
      expect(emojiCategories, isNotEmpty);
    });

    test('every category has a non-empty name and icon', () {
      for (final cat in emojiCategories) {
        expect(cat.name, isNotEmpty, reason: 'category name should be set');
        expect(cat.icon, isNotEmpty, reason: 'category icon should be set');
      }
    });

    test('every category has at least one emoji', () {
      for (final cat in emojiCategories) {
        expect(
          cat.emojis,
          isNotEmpty,
          reason: '${cat.name} should have emoji',
        );
      }
    });

    test('no emoji is the empty string', () {
      for (final cat in emojiCategories) {
        for (final e in cat.emojis) {
          expect(e, isNotEmpty, reason: 'found empty string in ${cat.name}');
        }
      }
    });
  });
}
