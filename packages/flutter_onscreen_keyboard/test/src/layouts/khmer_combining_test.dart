import 'package:characters/characters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KhmerKeyboardLayout — Khmer grapheme cluster backspace', () {
    // The existing ActionKeyType.backspace handler deletes the last grapheme
    // cluster, not the last code unit. These tests verify that the
    // String.characters API (used internally) handles combined Khmer clusters.

    test('single consonant deletes correctly', () {
      const text = 'ក';
      final deleted = text.characters.skipLast(1).string;
      expect(deleted, '');
    });

    test(
      'consonant + vowel sign form one grapheme cluster (UAX #29 SpacingMark)',
      () {
        // ក (U+1780) + ា (U+17B6 KHMER VOWEL SIGN AA, property SpacingMark).
        // Per UAX #29 rule GB9a: × SpacingMark — never break before a spacing
        // mark, so the two code units are ONE grapheme cluster.
        // Backspace therefore removes both characters together.
        const combined = 'កា';
        final deleted = combined.characters.skipLast(1).string;
        expect(deleted, '');
      },
    );

    test(
      'coeng (subscript) splits at the following base consonant (UAX #29)',
      () {
        // ក (U+1780) + ្ (U+17D2 KHMER SIGN COENG, property Extend) + ត (U+178F).
        // Per UAX #29 rule GB9: × Extend — ្ attaches to its preceding base ក,
        // forming cluster "ក្", while ត starts a new cluster.
        // Grapheme clusters: [ 'ក្', 'ត' ]
        // Backspace removes 'ត'; 'ក្' (with the coeng) remains.
        const coeng = 'ក្ត';
        final deleted = coeng.characters.skipLast(1).string;
        expect(deleted, 'ក្');
        expect(deleted.contains('\u17D2'), isTrue); // coeng still present
      },
    );

    test('empty string backspace returns empty string', () {
      const text = '';
      final deleted = text.characters.skipLast(1).string;
      expect(deleted, '');
    });

    test('mixed Khmer + ASCII deletes last cluster', () {
      const text = 'aក';
      final deleted = text.characters.skipLast(1).string;
      expect(deleted, 'a');
    });
  });
}
