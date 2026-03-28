import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_onscreen_keyboard/src/constants/action_key_type.dart';

/// A numeric keypad [KeyboardLayout] that is automatically shown when
/// an [OnscreenKeyboardTextField] has a `keyboardType` of
/// [TextInputType.number] or [TextInputType.numberWithOptions].
///
/// The layout is phone-style (1–2–3 on top, 7–8–9 in the middle).
///
/// ### Flags
/// - [decimal] — shows a `.` key (enabled when `TextInputType.numberWithOptions(decimal: true)`)
/// - [signed] — shows a `±` key (enabled when `TextInputType.numberWithOptions(signed: true)`)
///
/// This layout is not intended to be used as a standalone language layout.
/// It is constructed automatically by [OnscreenKeyboard] based on the
/// focused field's `keyboardType`.
class NumberPadKeyboardLayout extends KeyboardLayout {
  /// Creates a [NumberPadKeyboardLayout].
  ///
  /// [decimal] enables the `.` key. [signed] enables the `±` key.
  const NumberPadKeyboardLayout({this.decimal = false, this.signed = false});

  /// Whether to show the decimal (`.`) key.
  final bool decimal;

  /// Whether to show the signed (`±`) key.
  final bool signed;

  @override
  double get aspectRatio => 1;

  /// Uses the full configured keyboard width.
  @override
  double get widthFactor => 1;

  @override
  Map<String, KeyboardMode> get modes => {
    'numbers': KeyboardMode(rows: _numberRows),
  };

  List<KeyboardRow> get _numberRows => [
    // Row 1: 1 2 3
    const KeyboardRow(
      keys: [
        OnscreenKeyboardKey.text(primary: '1'),
        OnscreenKeyboardKey.text(primary: '2'),
        OnscreenKeyboardKey.text(primary: '3'),
      ],
    ),

    // Row 2: 4 5 6
    const KeyboardRow(
      keys: [
        OnscreenKeyboardKey.text(primary: '4'),
        OnscreenKeyboardKey.text(primary: '5'),
        OnscreenKeyboardKey.text(primary: '6'),
      ],
    ),

    // Row 3: 7 8 9
    const KeyboardRow(
      keys: [
        OnscreenKeyboardKey.text(primary: '7'),
        OnscreenKeyboardKey.text(primary: '8'),
        OnscreenKeyboardKey.text(primary: '9'),
      ],
    ),

    // Row 4: ± (or spacer) | 0 | . (or spacer) | backspace
    KeyboardRow(
      keys: [
        if (signed)
          const OnscreenKeyboardKey.text(primary: '±')
        else
          const OnscreenKeyboardKey.action(
            name: 'noop',
            child: SizedBox.shrink(),
          ),
        const OnscreenKeyboardKey.text(primary: '0'),
        if (decimal)
          const OnscreenKeyboardKey.text(primary: '.')
        else
          const OnscreenKeyboardKey.action(
            name: 'noop',
            child: SizedBox.shrink(),
          ),
        const OnscreenKeyboardKey.action(
          name: ActionKeyType.backspace,
          child: Icon(Icons.backspace_outlined),
        ),
      ],
    ),
  ];
}
