import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_onscreen_keyboard/src/constants/action_key_type.dart';
import 'package:flutter_onscreen_keyboard/src/utils/extensions.dart';
import 'package:flutter_onscreen_keyboard/src/widgets/emoji_keyboard_widget.dart';

/// A [LanguageKeyboardLayout] for English (QWERTY) input on mobile.
///
/// Provides three modes:
///  - `'alphabets'` (default) — A–Z with number row secondaries
///  - `'symbols'` — punctuation and special characters
///  - `'emojis'` — common emoji
///
/// This layout is the English-language equivalent of [MobileKeyboardLayout],
/// following the same [LanguageKeyboardLayout] contract as
/// [KhmerKeyboardLayout] for consistency.
///
/// ### Usage
/// ```dart
/// MaterialApp(
///   builder: OnscreenKeyboard.builder(
///     supportedLanguages: [
///       const EnglishKeyboardLayout(),
///       const KhmerKeyboardLayout(),
///     ],
///   ),
///   home: const MyApp(),
/// );
/// ```
class EnglishKeyboardLayout extends LanguageKeyboardLayout {
  /// Creates an [EnglishKeyboardLayout].
  const EnglishKeyboardLayout();

  @override
  String get languageCode => 'en';

  @override
  String get displayName => 'English';

  @override
  bool get isRtl => false;

  @override
  double get aspectRatio => 5 / 3;

  // Modes are static so that all KeyboardRow / OnscreenKeyboardKey objects
  // are allocated exactly once for the lifetime of the app, rather than on
  // every RawOnscreenKeyboard rebuild.
  static final Map<String, KeyboardMode> _modes = {
    'alphabets': KeyboardMode(rows: _alphabetsMode),
    'symbols': KeyboardMode(rows: _symbolsMode, verticalSpacing: 20),
    'emojis': KeyboardMode(
      builder: (context, rowHeight, insertText, onBackspace) =>
          EmojiKeyboardWidget(
            rowHeight: rowHeight,
            insertText: insertText,
            onBackspace: onBackspace,
            backModeName: 'alphabets',
            backModeLabel: 'ABC',
          ),
    ),
  };

  @override
  Map<String, KeyboardMode> get modes => _modes;

  // ── Alphabets mode ─────────────────────────────────────────────────────────

  static final List<KeyboardRow> _alphabetsMode = [
    // Row 0 — number row + backspace
    KeyboardRow(
      keys: [
        ..._buildRowWithSecondary([
          ('1', '!'),
          ('2', '@'),
          ('3', '#'),
          ('4', r'$'),
          ('5', '%'),
          ('6', '^'),
          ('7', '&'),
          ('8', '*'),
          ('9', '('),
          ('0', ')'),
          ('-', '_'),
          ('+', '='),
        ]).keys,
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.backspace,
          child: Icon(Icons.backspace_outlined),
          flex: 30,
        ),
      ],
    ),

    // Row 1 — QWERTY row with secondaries + brackets
    _buildRowWithSecondary([
      ('q', 'Q'),
      ('w', 'W'),
      ('e', 'E'),
      ('r', 'R'),
      ('t', 'T'),
      ('y', 'Y'),
      ('u', 'U'),
      ('i', 'I'),
      ('o', 'O'),
      ('p', 'P'),
      ('[', '{'),
      (']', '}'),
    ]),

    // Row 2 — ASDF row with secondaries (no indent)
    _buildRowWithSecondary([
      ('a', 'A'),
      ('s', 'S'),
      ('d', 'D'),
      ('f', 'F'),
      ('g', 'G'),
      ('h', 'H'),
      ('j', 'J'),
      ('k', 'K'),
      ('l', 'L'),
      (';', ':'),
      ("'", '"'),
    ]),

    // Row 3 — CapsLock + ZXCV row with secondaries + punctuation
    KeyboardRow(
      keys: [
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.capslock,
          child: Icon(Icons.keyboard_capslock_rounded),
          flex: 30,
          canHold: true,
        ),
        ...[
          ('z', 'Z'),
          ('x', 'X'),
          ('c', 'C'),
          ('v', 'V'),
          ('b', 'B'),
          ('n', 'N'),
          ('m', 'M'),
          (',', '<'),
          ('.', '>'),
          ('/', '?'),
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

  static final List<KeyboardRow> _symbolsMode = [
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
          child: const Text('ABC'),
          onTap: (context) => context.controller.setModeNamed('alphabets'),
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

  // ── Helpers ────────────────────────────────────────────────────────────────

  static OnscreenKeyboardKey _buildKeyWithSecondary((String, String) key) =>
      OnscreenKeyboardKey.text(primary: key.$1, secondary: key.$2);

  static KeyboardRow _buildRowWithSecondary(List<(String, String)> keys) =>
      KeyboardRow(keys: keys.map(_buildKeyWithSecondary).toList());
}
