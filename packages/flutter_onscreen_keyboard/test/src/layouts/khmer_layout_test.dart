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

    test('aspectRatio is 4/3', () {
      expect(layout.aspectRatio, closeTo(4 / 3, 0.001));
    });

    test('is a LanguageKeyboardLayout', () {
      expect(layout, isA<LanguageKeyboardLayout>());
    });

    test('is a KeyboardLayout', () {
      expect(layout, isA<KeyboardLayout>());
    });

    group('modes', () {
      test('has consonants mode', () {
        expect(layout.modes.containsKey('consonants'), isTrue);
      });

      test('has vowels mode', () {
        expect(layout.modes.containsKey('vowels'), isTrue);
      });

      test('has numbers mode', () {
        expect(layout.modes.containsKey('numbers'), isTrue);
      });

      test('has exactly 3 modes', () {
        expect(layout.modes.length, 3);
      });

      test('first mode is consonants', () {
        expect(layout.modes.keys.first, 'consonants');
      });
    });

    group('consonants mode', () {
      late List<KeyboardRow> rows;

      setUp(() {
        rows = layout.modes['consonants']!.rows;
      });

      test('has 5 rows', () {
        expect(rows.length, 5);
      });

      test('first row has 10 consonants', () {
        expect(rows[0].keys.length, 10);
      });

      test('second row has 10 consonants', () {
        expect(rows[1].keys.length, 10);
      });

      test('third row has 9 consonants', () {
        expect(rows[2].keys.length, 9);
      });

      test('first row starts with ក', () {
        final key = rows[0].keys.first;
        expect(key, isA<TextKey>());
        expect((key as TextKey).primary, 'ក');
      });

      test('row 3 contains backspace action', () {
        final actionKeys = rows[3].keys.whereType<ActionKey>();
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

    group('vowels mode', () {
      late List<KeyboardRow> rows;

      setUp(() {
        rows = layout.modes['vowels']!.rows;
      });

      test('has 4 rows', () {
        expect(rows.length, 4);
      });

      test('first row has 10 vowel signs', () {
        expect(rows[0].keys.length, 10);
      });

      test('first row starts with ា', () {
        final key = rows[0].keys.first;
        expect(key, isA<TextKey>());
        expect((key as TextKey).primary, 'ា');
      });
    });

    group('numbers mode', () {
      late List<KeyboardRow> rows;

      setUp(() {
        rows = layout.modes['numbers']!.rows;
      });

      test('has 4 rows', () {
        expect(rows.length, 4);
      });

      test('first row has 10 Khmer digits', () {
        expect(rows[0].keys.length, 10);
      });

      test('first row starts with Khmer digit ១', () {
        final key = rows[0].keys.first;
        expect(key, isA<TextKey>());
        expect((key as TextKey).primary, '១');
      });

      test('first row ends with Khmer zero ០', () {
        final key = rows[0].keys.last;
        expect(key, isA<TextKey>());
        expect((key as TextKey).primary, '០');
      });
    });
  });
}
