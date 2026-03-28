import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_test/flutter_test.dart';

// A minimal concrete implementation used only in these tests.
class _TestLanguageLayout extends LanguageKeyboardLayout {
  const _TestLanguageLayout({
    required this.languageCode,
    required this.displayName,
    this.isRtl = false,
  });

  @override
  final String languageCode;

  @override
  final String displayName;

  @override
  final bool isRtl;

  @override
  double get aspectRatio => 4 / 3;

  @override
  Map<String, KeyboardMode> get modes => {
    'default': const KeyboardMode(
      rows: [
        KeyboardRow(
          keys: [
            OnscreenKeyboardKey.text(primary: 'A'),
          ],
        ),
      ],
    ),
  };
}

void main() {
  group('LanguageKeyboardLayout', () {
    test('languageCode is accessible', () {
      const layout = _TestLanguageLayout(
        languageCode: 'en',
        displayName: 'English',
      );
      expect(layout.languageCode, 'en');
    });

    test('displayName is accessible', () {
      const layout = _TestLanguageLayout(
        languageCode: 'km',
        displayName: 'ភាសាខ្មែរ',
      );
      expect(layout.displayName, 'ភាសាខ្មែរ');
    });

    test('isRtl defaults to false', () {
      const layout = _TestLanguageLayout(
        languageCode: 'en',
        displayName: 'English',
      );
      expect(layout.isRtl, isFalse);
    });

    test('isRtl can be set to true', () {
      const layout = _TestLanguageLayout(
        languageCode: 'ar',
        displayName: 'العربية',
        isRtl: true,
      );
      expect(layout.isRtl, isTrue);
    });

    test('is a subtype of KeyboardLayout', () {
      const layout = _TestLanguageLayout(
        languageCode: 'en',
        displayName: 'English',
      );
      expect(layout, isA<KeyboardLayout>());
    });

    test('modes map is not empty', () {
      const layout = _TestLanguageLayout(
        languageCode: 'en',
        displayName: 'English',
      );
      expect(layout.modes, isNotEmpty);
    });
  });
}
