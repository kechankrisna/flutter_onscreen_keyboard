import 'package:flutter/widgets.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';

/// Abstract base class for defining keyboard layouts.
///
/// Extend this class to provide custom arrangements of keyboard rows and keys.
/// A layout is composed of multiple [KeyboardRow]s grouped under different
/// [modes] (e.g., letters, symbols, numbers), which allow dynamic layout
/// switching (commonly used in mobile keyboards).
///
/// You can use the [KeyboardLayout.custom] constructor to define your
/// own layout without needing to extend this class directly.
abstract class KeyboardLayout {
  /// Creates a keyboard layout.
  const KeyboardLayout();

  /// Creates a custom keyboard layout with multiple modes.
  ///
  /// [aspectRatio] controls the width-to-height ratio of the keyboard.
  ///
  /// [modes] is a map of layout modes (like 'letters', 'symbols', etc.)
  /// to their corresponding [KeyboardMode]s.
  const factory KeyboardLayout.custom({
    required double aspectRatio,
    required Map<String, KeyboardMode> modes,
  }) = _CustomKeyboardLayout;

  /// {@template keyboardLayout.aspectRatio}
  /// The aspect ratio of the keyboard layout.
  ///
  /// For example, a 16:9 width:height aspect ratio would have a value of 16.0/9.0.
  /// {@endtemplate}
  double get aspectRatio;

  /// A map of layout modes to their corresponding [KeyboardMode]s.
  ///
  /// Each mode (e.g., `'letters'`, `'symbols'`, `'numbers'`) defines the
  /// structure of the keyboard when that mode is active.
  Map<String, KeyboardMode> get modes;

  /// Fraction of the configured keyboard width this layout should occupy.
  ///
  /// Defaults to `1.0` (full width). Override to a smaller value (e.g. `0.5`)
  /// for compact layouts like a numeric keypad.
  double get widthFactor => 1;
}

/// Signature for a fully custom keyboard mode builder.
///
/// Called by [RawOnscreenKeyboard] when [KeyboardMode.builder] is set.
///
/// Parameters:
/// - [context]: the current build context (includes [OnscreenKeyboard] in tree)
/// - [rowHeight]: suggested height for each key row, derived from the reference
///   non-custom mode so all rows share a consistent height across modes
/// - [insertText]: inserts [text] into the active text field at the cursor,
///   respecting any input formatters on the field
/// - [onBackspace]: deletes the character (or grapheme cluster) before the
///   cursor, or the current selection if one exists
typedef KeyboardModeBuilder = Widget Function(
  BuildContext context,
  double rowHeight,
  void Function(String text) insertText,
  VoidCallback onBackspace,
);

/// Represents a single layout mode in the keyboard.
///
/// A mode is a group of [KeyboardRow]s rendered together.
/// This allows the keyboard to switch between different input styles,
/// such as letters, symbols, numbers, etc.
///
/// When [builder] is provided it takes full control of rendering and [rows] is
/// ignored. Use [builder] for completely custom modes such as an emoji picker.
class KeyboardMode {
  /// Creates a keyboard mode.
  ///
  /// Provide either [rows] (standard row/key layout) or [builder] (fully
  /// custom widget). At least one must be non-empty / non-null.
  const KeyboardMode({
    this.rows = const [],
    this.verticalSpacing = 0,
    this.scrollable = false,
    this.theme,
    this.builder,
  });

  /// The rows of keys displayed in this mode.
  ///
  /// Ignored when [builder] is set.
  final List<KeyboardRow> rows;

  /// The vertical spacing between rows.
  final double verticalSpacing;

  /// Whether the key rows can be scrolled vertically.
  ///
  /// When `true`, the rows are rendered inside a [SingleChildScrollView] with a
  /// fixed per-row height derived from the keyboard's available height and the
  /// row count of the first non-scrollable mode. This allows the keyboard to
  /// contain more rows than fit on screen (e.g. emoji categories).
  ///
  /// Ignored when [builder] is set.
  final bool scrollable;

  /// The keyboard theme for this mode.
  final OnscreenKeyboardThemeData Function(BuildContext context)? theme;

  /// Optional fully custom widget builder for this mode.
  ///
  /// When provided, [RawOnscreenKeyboard] delegates all rendering to this
  /// builder. The [rows], [scrollable], and [verticalSpacing] fields are
  /// ignored. See [KeyboardModeBuilder] for parameter details.
  final KeyboardModeBuilder? builder;
}

/// Represents a single row in a keyboard layout.
///
/// Each row contains a list of [OnscreenKeyboardKey]s
/// which will be rendered horizontally.
class KeyboardRow {
  /// Creates a keyboard row with a list of keys.
  ///
  /// The [keys] parameter defines the keys rendered in this row.
  ///
  /// Use [leading] and [trailing] widgets to add widgets at the start or end
  /// of the row (e.g., padding, arrows, labels).
  const KeyboardRow({
    required this.keys,
    this.leading,
    this.trailing,
  });

  /// The list of keys displayed in this row.
  final List<OnscreenKeyboardKey> keys;

  /// Optional widget shown at the beginning of the row.
  final Widget? leading;

  /// Optional widget shown at the end of the row.
  final Widget? trailing;
}

/// Internal implementation of a custom [KeyboardLayout].
class _CustomKeyboardLayout extends KeyboardLayout {
  const _CustomKeyboardLayout({
    required this.aspectRatio,
    required this.modes,
  });

  @override
  final double aspectRatio;

  @override
  final Map<String, KeyboardMode> modes;
}
