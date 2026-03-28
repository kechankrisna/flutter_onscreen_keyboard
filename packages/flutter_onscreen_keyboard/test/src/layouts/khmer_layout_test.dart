import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KhmerKeyboardLayout', () {
    const layout = KhmerKeyboardLayout();

    test('languageCode is km', () {
      expect(layout.languageCode, 'km');
    });

    test('displayName is in Khmer script', () {
      expect(layout.displayName, 'ភាសាខ្មែរ');
    });

    test('isRtl is false', () {
      expect(layout.isRtl, isFalse);
    });

    test('aspectRatio is 4/1.5', () {
      expect(layout.aspectRatio, closeTo(4 / 1.5, 0.001));
    });

    test('is a LanguageKeyboardLayout', () {
      expect(layout, isA<LanguageKeyboardLayout>());
    });

    test('is a KeyboardLayout', () {
      expect(layout, isA<KeyboardLayout>());
    });

    group('modes', () {
      test('has khmer mode', () {
        expect(layout.modes.containsKey('khmer'), isTrue);
      });

      test('has symbols mode', () {
        expect(layout.modes.containsKey('symbols'), isTrue);
      });

      test('has emojis mode', () {
        expect(layout.modes.containsKey('emojis'), isTrue);
      });

      test('has exactly 3 modes', () {
        expect(layout.modes.length, 3);
      });

      test('first mode is khmer', () {
        expect(layout.modes.keys.first, 'khmer');
      });
    });

    group('khmer mode', () {
      late List<KeyboardRow> rows;

      setUp(() {
        rows = layout.modes['khmer']!.rows;
      });

      test('has 5 rows', () {
        expect(rows.length, 5);
      });

      test('first row has 13 keys (12 text + backspace)', () {
        expect(rows[0].keys.length, 13);
      });

      test('second row has 12 keys', () {
        expect(rows[1].keys.length, 12);
      });

      test('third row has 11 keys', () {
        expect(rows[2].keys.length, 11);
      });

      test('first row starts with Khmer digit ១', () {
        final key = rows[0].keys.first;
        expect(key, isA<TextKey>());
        expect((key as TextKey).primary, '១');
      });

      test('row 0 contains backspace action', () {
        final actionKeys = rows[0].keys.whereType<ActionKey>();
        expect(
          actionKeys.any((k) => k.name == 'backspace'),
          isTrue,
        );
      });

      test('row 4 contains enter action', () {
        final actionKeys = rows[4].keys.whereType<ActionKey>();
        expect(
          actionKeys.any((k) => k.name == 'enter'),
          isTrue,
        );
      });

      test('row 4 contains space key', () {
        final spaceKeys = rows[4].keys.whereType<TextKey>().where(
          (k) => k.primary == ' ',
        );
        expect(spaceKeys, isNotEmpty);
      });
    });
  });
}
