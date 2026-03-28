import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_onscreen_keyboard/src/widgets/keys.dart';

/// A low-level on-screen keyboard widget that displays keys
/// based on the given [KeyboardLayout].
///
/// It handles key rendering, layout structure, and interaction callbacks
/// for key presses. This widget is useful for embedding the keyboard UI
/// inside another widget and controlling its behavior externally.
class RawOnscreenKeyboard extends StatelessWidget {
  /// Creates a [RawOnscreenKeyboard] widget.
  const RawOnscreenKeyboard({
    required this.layout,
    required this.onKeyDown,
    required this.onKeyUp,
    required this.mode,
    super.key,
    this.aspectRatio,
    this.pressedActionKeys = const {},
    this.showSecondary = false,
    this.textDirection = TextDirection.ltr,
  });

  /// The keyboard layout that defines rows and keys to render.
  final KeyboardLayout layout;

  /// {@macro keyboardLayout.aspectRatio}
  ///
  /// Defaults to the aspect ratio of [layout].
  final double? aspectRatio;

  /// Callback when a key is pressed down.
  final ValueChanged<OnscreenKeyboardKey> onKeyDown;

  /// Callback when a key is released.
  final ValueChanged<OnscreenKeyboardKey> onKeyUp;

  /// A set of currently pressed action key names (e.g., shift, capslock).
  ///
  /// Used to visually indicate active keys like modifiers.
  final Set<String> pressedActionKeys;

  /// Whether to show the secondary value for each [TextKey] (e.g., uppercase).
  final bool showSecondary;

  /// The currently active keyboard mode to render from the layout.
  ///
  /// Must match one of the keys defined in [KeyboardLayout.modes].
  final String mode;

  /// The text direction used to lay out key rows.
  ///
  /// Set to [TextDirection.rtl] for right-to-left scripts such as Arabic or
  /// Hebrew. Defaults to [TextDirection.ltr].
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    final activeMode = layout.modes[mode]!;
    final keyColumns = Material(
      type: MaterialType.transparency,
      child: Column(
        spacing: activeMode.verticalSpacing,
        children: [
          for (final row in activeMode.rows)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ?row.leading,
                  for (final k in row.keys)
                    Expanded(
                      flex: k.flex,
                      child: switch (k) {
                        TextKey() => TextKeyWidget(
                          textKey: k,
                          showSecondary: showSecondary,
                          onTapDown: () => onKeyDown(k),
                          onTapUp: () => onKeyUp(k),
                        ),
                        ActionKey() => ActionKeyWidget(
                          actionKey: k,
                          pressed: pressedActionKeys.contains(k.name),
                          onTapDown: () => onKeyDown(k),
                          onTapUp: () => onKeyUp(k),
                        ),
                      },
                    ),
                  ?row.trailing,
                ],
              ),
            ),
        ],
      ),
    );

    return Directionality(
      textDirection: textDirection,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // When the parent provides a finite height (e.g. an explicit
          // height was set on the keyboard container), skip AspectRatio
          // so the key rows fill that exact height instead of
          // overriding it.
          if (constraints.maxHeight.isFinite) return keyColumns;
          return AspectRatio(
            aspectRatio: aspectRatio ?? layout.aspectRatio,
            child: keyColumns,
          );
        },
      ),
    );
  }
}
