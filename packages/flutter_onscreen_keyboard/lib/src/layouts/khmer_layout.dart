import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_onscreen_keyboard/src/constants/action_key_type.dart';
import 'package:flutter_onscreen_keyboard/src/utils/extensions.dart';

/// A [LanguageKeyboardLayout] for Khmer Unicode script.
///
/// Provides three modes:
///  - `'consonants'` (default) — 33 Khmer consonants
///  - `'vowels'` — 10 dependent vowels, diacritics, and special characters
///  - `'numbers'` — Khmer digits (០–៩) and common punctuation/ASCII symbols
///
/// All modes apply the bundled **NotoSerifKhmer** font automatically. The
/// font is bundled in this package — consumers do not need to declare it in
/// their own `pubspec.yaml`.
///
/// ### Usage
/// ```dart
/// MaterialApp(
///   builder: OnscreenKeyboard.builder(
///     supportedLanguages: [const KhmerKeyboardLayout()],
///   ),
///   home: const MyApp(),
/// );
/// ```
class KhmerKeyboardLayout extends LanguageKeyboardLayout {
  /// Creates a [KhmerKeyboardLayout].
  const KhmerKeyboardLayout();

  @override
  String get languageCode => 'km';

  @override
  String get displayName => 'ភាសាខ្មែរ';

  @override
  bool get isRtl => false;

  @override
  double get aspectRatio => 4 / 3;

  @override
  Map<String, KeyboardMode> get modes => {
    'consonants': KeyboardMode(rows: _consonantsMode, theme: _khmerTheme),
    'vowels': KeyboardMode(rows: _vowelsMode, theme: _khmerTheme),
    'numbers': KeyboardMode(rows: _numbersMode, theme: _khmerTheme),
  };

  // ── Theme ──────────────────────────────────────────────────────────────────

  /// Applies the NotoSerifKhmer font family to all text keys in a mode.
  OnscreenKeyboardThemeData _khmerTheme(BuildContext context) {
    final base = context.theme;
    return base.copyWith(
      textKeyThemeData: base.textKeyThemeData.copyWith(
        textStyle: const TextStyle(
          fontFamily: 'NotoSerifKhmer',
          package: 'flutter_onscreen_keyboard',
          fontSize: 16,
          height: 1.2,
        ),
      ),
    );
  }

  // ── Consonants mode ────────────────────────────────────────────────────────

  /// The 33 Khmer consonants arranged in the traditional order, with
  /// CapsLock, Backspace, and a mode-switch action row at the bottom.
  List<KeyboardRow> get _consonantsMode => [
    // Row 0 — 10 consonants
    _buildRow(['ក', 'ខ', 'គ', 'ឃ', 'ង', 'ច', 'ឆ', 'ជ', 'ឈ', 'ញ']),

    // Row 1 — 10 consonants
    _buildRow(['ដ', 'ឋ', 'ឌ', 'ឍ', 'ណ', 'ត', 'ថ', 'ទ', 'ធ', 'ន']),

    // Row 2 — 9 consonants (indented)
    KeyboardRow(
      leading: const Expanded(flex: 10, child: SizedBox.shrink()),
      keys: [
        'ប',
        'ផ',
        'ព',
        'ភ',
        'ម',
        'យ',
        'រ',
        'ល',
        'វ',
      ].map(_buildKey).toList(),
      trailing: const Expanded(flex: 10, child: SizedBox.shrink()),
    ),

    // Row 3 — CapsLock + 4 consonants + Backspace
    KeyboardRow(
      keys: [
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.capslock,
          child: Icon(Icons.keyboard_capslock_rounded),
          flex: 30,
          canHold: true,
        ),
        ...[
          'ស',
          'ហ',
          'ឡ',
          'អ',
        ].map(_buildKey),
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.backspace,
          child: Icon(Icons.backspace_outlined),
          flex: 30,
        ),
      ],
    ),

    // Row 4 — mode-switch, space, ។, Enter
    KeyboardRow(
      keys: [
        OnscreenKeyboardKey.action(
          name: 'switch_vowels',
          child: const Text('ក→'),
          onTap: (context) => context.controller.setModeNamed('vowels'),
          flex: 35,
        ),
        const OnscreenKeyboardKey.text(
          primary: ' ',
          child: Icon(Icons.space_bar_rounded),
          flex: 100,
        ),
        const OnscreenKeyboardKey.text(primary: '។'),
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.enter,
          child: Icon(Icons.keyboard_return_rounded),
          flex: 30,
        ),
      ],
    ),
  ];

  // ── Vowels mode ────────────────────────────────────────────────────────────

  /// Dependent vowels, diacritics, and special Khmer characters.
  List<KeyboardRow> get _vowelsMode => [
    // Row 0 — 10 vowel signs
    _buildRow(['ា', 'ិ', 'ី', 'ឹ', 'ឺ', 'ុ', 'ូ', 'ួ', 'ើ', 'ឿ']),

    // Row 1 — 10 more vowels / diacritics
    _buildRow(['ៀ', 'េ', 'ែ', 'ៃ', 'ោ', 'ៅ', 'ំ', 'ះ', 'ៈ', '្']),

    // Row 2 — 9 less-common signs (indented)
    KeyboardRow(
      leading: const Expanded(flex: 10, child: SizedBox.shrink()),
      keys: [
        '់',
        '័',
        '៌',
        '៍',
        'ឥ',
        'ឦ',
        'ឧ',
        'ឩ',
        'ឪ',
      ].map(_buildKey).toList(),
      trailing: const Expanded(flex: 10, child: SizedBox.shrink()),
    ),

    // Row 3 — mode-switching + punctuation + backspace + enter
    KeyboardRow(
      keys: [
        OnscreenKeyboardKey.action(
          name: 'switch_numbers',
          child: const Text('123'),
          onTap: (context) => context.controller.setModeNamed('numbers'),
          flex: 35,
        ),
        OnscreenKeyboardKey.action(
          name: 'switch_consonants',
          child: const Text('ក'),
          onTap: (context) => context.controller.setModeNamed('consonants'),
          flex: 35,
        ),
        const OnscreenKeyboardKey.text(primary: '។'),
        const OnscreenKeyboardKey.text(primary: '៕'),
        const OnscreenKeyboardKey.text(
          primary: ' ',
          child: Icon(Icons.space_bar_rounded),
          flex: 80,
        ),
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.backspace,
          child: Icon(Icons.backspace_outlined),
          flex: 30,
        ),
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.enter,
          child: Icon(Icons.keyboard_return_rounded),
          flex: 30,
        ),
      ],
    ),
  ];

  // ── Numbers mode ───────────────────────────────────────────────────────────

  /// Khmer digits (០–៩) plus ASCII punctuation and symbols.
  List<KeyboardRow> get _numbersMode => [
    // Row 0 — Khmer digits
    _buildRow(['១', '២', '៣', '៤', '៥', '៦', '៧', '៨', '៩', '០']),

    // Row 1 — Common ASCII symbols
    _buildRow(['!', '@', '#', r'$', '%', '^', '&', '*', '(', ')']),

    // Row 2 — More symbols (indented)
    KeyboardRow(
      leading: const Expanded(flex: 10, child: SizedBox.shrink()),
      keys: [
        '_',
        '-',
        '+',
        '=',
        '[',
        ']',
        '{',
        '}',
        '?',
      ].map(_buildKey).toList(),
      trailing: const Expanded(flex: 10, child: SizedBox.shrink()),
    ),

    // Row 3 — back to consonants + punctuation + space + backspace + enter
    KeyboardRow(
      keys: [
        OnscreenKeyboardKey.action(
          name: 'switch_consonants',
          child: const Text('ក'),
          onTap: (context) => context.controller.setModeNamed('consonants'),
          flex: 35,
        ),
        const OnscreenKeyboardKey.text(primary: '។'),
        const OnscreenKeyboardKey.text(primary: '៕'),
        const OnscreenKeyboardKey.text(primary: '៖'),
        const OnscreenKeyboardKey.text(
          primary: ' ',
          child: Icon(Icons.space_bar_rounded),
          flex: 100,
        ),
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.backspace,
          child: Icon(Icons.backspace_outlined),
          flex: 30,
        ),
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.enter,
          child: Icon(Icons.keyboard_return_rounded),
          flex: 30,
        ),
      ],
    ),
  ];

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Creates a basic text key with the given [character].
  OnscreenKeyboardKey _buildKey(String character) =>
      OnscreenKeyboardKey.text(primary: character);

  /// Creates a row of text keys from a list of characters.
  KeyboardRow _buildRow(List<String> characters) =>
      KeyboardRow(keys: characters.map(_buildKey).toList());
}
