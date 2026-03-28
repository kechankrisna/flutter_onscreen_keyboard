import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_onscreen_keyboard/src/constants/action_key_type.dart';
import 'package:flutter_onscreen_keyboard/src/utils/extensions.dart';

/// A [LanguageKeyboardLayout] for Khmer Unicode script (NiDA layout).
///
/// Provides three modes:
///  - `'khmer'` (default) — Standard Khmer Unicode keyboard with number row;
///    CapsLock reveals each key's secondary character.
///  - `'symbols'` — ASCII punctuation and special characters
///  - `'emojis'` — common emoji
///
/// The **NotoSerifKhmer** font is applied automatically to the `'khmer'` mode.
/// The font is bundled in this package — consumers do not need to declare it in
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
  double get aspectRatio => 5 / 3;

  @override
  Map<String, KeyboardMode> get modes => {
    'khmer': KeyboardMode(rows: _khmerMode, theme: _khmerTheme),
    'symbols': KeyboardMode(rows: _symbolsMode, verticalSpacing: 20),
    'emojis': KeyboardMode(
      rows: _emojisMode,
      theme: (context) {
        final theme = context.theme;
        return theme.copyWith(
          actionKeyThemeData: theme.actionKeyThemeData.copyWith(
            padding: const EdgeInsets.all(10),
          ),
          textKeyThemeData: theme.textKeyThemeData.copyWith(
            backgroundColor: Colors.transparent,
            boxShadow: [],
            // fix for: https://github.com/flutter/flutter/issues/119623
            padding: const EdgeInsets.only(left: 3),
          ),
        );
      },
    ),
  };

  // ── Theme ──────────────────────────────────────────────────────────────────

  /// Applies the NotoSerifKhmer font family to all text keys in the khmer mode.
  OnscreenKeyboardThemeData _khmerTheme(BuildContext context) {
    final base = context.theme;
    return base.copyWith(
      textKeyThemeData: base.textKeyThemeData.copyWith(
        textStyle: const TextStyle(
          fontFamily: 'NotoSerifKhmer',
          package: 'flutter_onscreen_keyboard',
        ),
      ),
    );
  }

  // ── Khmer mode ─────────────────────────────────────────────────────────────

  /// Standard Khmer Unicode (NiDA) keyboard layout.
  ///
  /// Row 0 carries Khmer digits with symbol secondaries (backspace at end).
  /// Rows 1–3 map to QWERTY, ASDF, and ZXCV positions using the NiDA mapping.
  /// Holding CapsLock reveals each key's secondary Khmer character.
  List<KeyboardRow> get _khmerMode => [
    // Row 0 — Khmer digits + symbols + backspace
    KeyboardRow(
      keys: [
        ...[
          ('១', '!'),
          ('២', 'ៗ'),
          ('៣', '#'),
          ('៤', '៛'),
          ('៥', '%'),
          ('៦', '៍'),
          ('៧', '័'),
          ('៨', '៏'),
          ('៩', '('),
          ('០', ')'),
          ('-', '៌'),
          ('=', 'ឱ'),
        ].map(_buildKeyWithSecondary),
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.backspace,
          child: Icon(Icons.backspace_outlined),
          flex: 30,
        ),
      ],
    ),

    // Row 1 — QWERTY row
    _buildRowWithSecondary([
      ('ឆ', 'ឈ'),
      ('ឹ', 'ឺ'),
      ('េ', 'ែ'),
      ('រ', 'ឬ'),
      ('ត', 'ទ'),
      ('យ', 'ួ'),
      ('ុ', 'ូ'),
      ('ិ', 'ី'),
      ('ោ', 'ៅ'),
      ('ផ', 'ភ'),
      ('ៀ', '្ឿ'),
      ('ឪ', 'ឧ'),
    ]),

    // Row 2 — ASDF row
    _buildRowWithSecondary([
      ('ា', 'ាំ'),
      ('ស', 'ៃ'),
      ('ដ', 'ឌ'),
      ('ថ', 'ធ'),
      ('ង', 'អ'),
      ('ហ', 'ះ'),
      ('្', 'ញ'),
      ('ក', 'គ'),
      ('ល', 'ឡ'),
      ('ើ', 'ោះ'),
      ('់', '៉'),
    ]),

    // Row 3 — CapsLock + ZXCV row (no backspace — it's on row 0)
    KeyboardRow(
      keys: [
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.capslock,
          child: Icon(Icons.keyboard_capslock_rounded),
          flex: 30,
          canHold: true,
        ),
        ...[
          ('ច', 'ជ'),
          ('ខ', 'ឃ'),
          ('ច', 'ជ'),
          ('ដ', 'ឍ'),
          ('វ', 'េះ'),
          ('ប', 'ព'),
          ('ន', 'ណ'),
          ('ម', 'ំ'),
          ('ុំ', 'ុះ'),
          ('។', '៕'),
          ('៊', '?'),
        ].map(_buildKeyWithSecondary),
      ],
    ),

    // Row 4 — action row
    KeyboardRow(
      keys: [
        OnscreenKeyboardKey.action(
          name: 'mode_switch',
          child: const Text('?123'),
          onTap: (context) => context.controller.setModeNamed('symbols'),
          flex: 30,
        ),
        OnscreenKeyboardKey.action(
          name: 'emoji',
          child: const Text('😊'),
          onTap: (context) => context.controller.setModeNamed('emojis'),
        ),
        OnscreenKeyboardKey.action(
          name: 'switch_language',
          child: const Icon(Icons.language_rounded),
          onTap: (context) => context.controller.switchLanguage(),
        ),
        const OnscreenKeyboardKey.text(
          primary: ' ',
          child: Icon(Icons.space_bar_rounded),
          flex: 100,
        ),
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.enter,
          child: Icon(Icons.keyboard_return_rounded),
          flex: 30,
        ),
      ],
    ),
  ];

  // ── Symbols mode ───────────────────────────────────────────────────────────

  List<KeyboardRow> get _symbolsMode => [
    ...[
      [
        ('1', '~'),
        ('2', '`'),
        ('3', '|'),
        ('4', '•'),
        ('5', '√'),
        ('6', 'π'),
        ('7', '÷'),
        ('8', '×'),
        ('9', '§'),
        ('0', '∆'),
      ],
      [
        ('@', '£'),
        ('#', '¢'),
        (r'$', '€'),
        ('_', '¥'),
        ('&', '^'),
        ('-', '°'),
        ('+', '='),
        ('(', '{'),
        (')', '}'),
        ('/', r'\'),
      ],
    ].map(_buildRowWithSecondary),

    KeyboardRow(
      keys: [
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.capslock,
          child: Icon(Icons.keyboard_capslock_rounded),
          flex: 30,
          canHold: true,
        ),
        ...[
          ('*', '%'),
          ('"', '©'),
          ("'", '®'),
          (':', '™'),
          (';', '✓'),
          ('!', '['),
          ('?', ']'),
        ].map(_buildKeyWithSecondary),
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.backspace,
          child: Icon(Icons.backspace_outlined),
          flex: 30,
        ),
      ],
    ),

    KeyboardRow(
      keys: [
        OnscreenKeyboardKey.action(
          name: 'mode_switch',
          child: const Text('ក'),
          onTap: (context) => context.controller.setModeNamed('khmer'),
          flex: 30,
        ),
        OnscreenKeyboardKey.action(
          name: 'emoji',
          child: const Text('😊'),
          onTap: (context) => context.controller.setModeNamed('emojis'),
        ),
        OnscreenKeyboardKey.action(
          name: 'switch_language',
          child: const Icon(Icons.language_rounded),
          onTap: (context) => context.controller.switchLanguage(),
        ),
        const OnscreenKeyboardKey.text(
          primary: ' ',
          child: Icon(Icons.space_bar_rounded),
          flex: 100,
        ),
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.enter,
          child: Icon(Icons.keyboard_return_rounded),
          flex: 30,
        ),
      ],
    ),
  ];

  // ── Emojis mode ────────────────────────────────────────────────────────────

  List<KeyboardRow> get _emojisMode => [
    ...const [
      ['😂', '❤️', '😍', '😭', '😊', '🔥', '🤣', '👍', '🥰', '😘'],
      ['😅', '🙏', '💕', '😭', '🤔', '😁', '🥲', '😎', '😢', '😋'],
      ['👏', '😮', '😳', '🤗', '🎉', '💔', '😴', '🙄', '😡', '🤩'],
    ].map(_buildRow),

    KeyboardRow(
      keys: [
        ...['😬', '😐', '😇', '🤤', '🤪', '👀', '😷', '😌', '🙈'].map(
          _buildKey,
        ),
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.backspace,
          child: Icon(Icons.backspace_outlined),
        ),
      ],
    ),

    KeyboardRow(
      keys: [
        OnscreenKeyboardKey.action(
          name: 'mode_switch',
          child: const Text('ក'),
          onTap: (context) => context.controller.setModeNamed('khmer'),
        ),
        OnscreenKeyboardKey.action(
          name: 'switch_language',
          child: const Icon(Icons.language_rounded),
          onTap: (context) => context.controller.switchLanguage(),
        ),
        ...['🌹', '🎂', '🤯', '🥺', '💀', '💩', '🫶', '😈'].map(_buildKey),
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.enter,
          child: Icon(Icons.keyboard_return_rounded),
        ),
      ],
    ),
  ];

  // ── Helpers ────────────────────────────────────────────────────────────────

  OnscreenKeyboardKey _buildKey(String character) =>
      OnscreenKeyboardKey.text(primary: character);

  KeyboardRow _buildRow(List<String> characters) =>
      KeyboardRow(keys: characters.map(_buildKey).toList());

  OnscreenKeyboardKey _buildKeyWithSecondary((String, String) key) =>
      OnscreenKeyboardKey.text(primary: key.$1, secondary: key.$2);

  KeyboardRow _buildRowWithSecondary(List<(String, String)> keys) =>
      KeyboardRow(keys: keys.map(_buildKeyWithSecondary).toList());
}
