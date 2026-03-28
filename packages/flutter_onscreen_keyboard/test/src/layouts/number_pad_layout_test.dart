import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberPadKeyboardLayout', () {
    test('is a KeyboardLayout', () {
      expect(const NumberPadKeyboardLayout(), isA<KeyboardLayout>());
    });

    test('aspectRatio is 3/4', () {
      expect(
        const NumberPadKeyboardLayout().aspectRatio,
        closeTo(3 / 4, 0.001),
      );
    });

    test('widthFactor is 0.5', () {
      expect(const NumberPadKeyboardLayout().widthFactor, 0.5);
    });

    group('modes', () {
      test('has exactly 1 mode', () {
        expect(const NumberPadKeyboardLayout().modes.length, 1);
      });

      test('has numbers mode', () {
        expect(
          const NumberPadKeyboardLayout().modes.containsKey('numbers'),
          isTrue,
        );
      });

      test('first mode is numbers', () {
        expect(const NumberPadKeyboardLayout().modes.keys.first, 'numbers');
      });
    });

    group('numbers mode rows', () {
      late List<KeyboardRow> rows;

      setUp(() {
        rows = const NumberPadKeyboardLayout().modes['numbers']!.rows;
      });

      test('has 4 rows', () {
        expect(rows.length, 4);
      });

      test('row 0 has 3 keys (1, 2, 3)', () {
        expect(rows[0].keys.length, 3);
      });

      test('row 1 has 3 keys (4, 5, 6)', () {
        expect(rows[1].keys.length, 3);
      });

      test('row 2 has 3 keys (7, 8, 9)', () {
        expect(rows[2].keys.length, 3);
      });

      test('row 3 has 4 keys (spacer/±, 0, spacer/., backspace)', () {
        expect(rows[3].keys.length, 4);
      });

      test('row 0 first key is text key "1"', () {
        final key = rows[0].keys.first;
        expect(key, isA<TextKey>());
        expect((key as TextKey).primary, '1');
      });

      test('row 2 last key is text key "9"', () {
        final key = rows[2].keys.last;
        expect(key, isA<TextKey>());
        expect((key as TextKey).primary, '9');
      });

      test('row 3 second key is text key "0"', () {
        final key = rows[3].keys[1];
        expect(key, isA<TextKey>());
        expect((key as TextKey).primary, '0');
      });

      test('row 3 last key is backspace action key', () {
        final key = rows[3].keys.last;
        expect(key, isA<ActionKey>());
        expect((key as ActionKey).name, 'backspace');
      });
    });

    group('decimal flag', () {
      test('without decimal: row 3 third key is a noop action (no dot)', () {
        final rows = const NumberPadKeyboardLayout().modes['numbers']!.rows;
        final key = rows[3].keys[2];
        expect(key, isA<ActionKey>());
        expect((key as ActionKey).name, 'noop');
      });

      test('with decimal: row 3 third key is text key "."', () {
        final rows = const NumberPadKeyboardLayout(
          decimal: true,
        ).modes['numbers']!.rows;
        final key = rows[3].keys[2];
        expect(key, isA<TextKey>());
        expect((key as TextKey).primary, '.');
      });
    });

    group('signed flag', () {
      test('without signed: row 3 first key is a noop action (no ±)', () {
        final rows = const NumberPadKeyboardLayout().modes['numbers']!.rows;
        final key = rows[3].keys[0];
        expect(key, isA<ActionKey>());
        expect((key as ActionKey).name, 'noop');
      });

      test('with signed: row 3 first key is text key "±"', () {
        final rows = const NumberPadKeyboardLayout(
          signed: true,
        ).modes['numbers']!.rows;
        final key = rows[3].keys[0];
        expect(key, isA<TextKey>());
        expect((key as TextKey).primary, '±');
      });
    });

    group('decimal and signed both enabled', () {
      late List<KeyboardRow> rows;

      setUp(() {
        rows = const NumberPadKeyboardLayout(
          decimal: true,
          signed: true,
        ).modes['numbers']!.rows;
      });

      test('row 3 first key is "±"', () {
        expect((rows[3].keys[0] as TextKey).primary, '±');
      });

      test('row 3 third key is "."', () {
        expect((rows[3].keys[2] as TextKey).primary, '.');
      });
    });
  });
}
