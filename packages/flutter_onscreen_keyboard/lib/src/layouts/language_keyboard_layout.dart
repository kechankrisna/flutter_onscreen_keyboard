import 'package:flutter_onscreen_keyboard/src/models/layout.dart';

/// Abstract base class for all language-specific keyboard layouts.
///
/// Extend this class to create a layout for a specific language or script.
/// It adds BCP-47 language metadata and RTL support on top of [KeyboardLayout].
///
/// ### Example
/// ```dart
/// class MyLayout extends LanguageKeyboardLayout {
///   const MyLayout();
///
///   @override
///   String get languageCode => 'fr';
///
///   @override
///   String get displayName => 'Français';
///
///   @override
///   double get aspectRatio => 4 / 3;
///
///   @override
///   Map<String, KeyboardMode> get modes => { ... };
/// }
/// ```
abstract class LanguageKeyboardLayout extends KeyboardLayout {
  /// Creates a [LanguageKeyboardLayout].
  const LanguageKeyboardLayout();

  /// The BCP-47 language code for this layout (e.g., `'km'`, `'en'`, `'ar'`).
  String get languageCode;

  /// The language name written in its own script (e.g., `'ភាសាខ្មែរ'`, `'English'`).
  String get displayName;

  /// Whether this layout is right-to-left.
  ///
  /// Set to `true` for Arabic, Hebrew, Persian, etc. When `true`, the keyboard
  /// key rows are rendered right-to-left automatically.
  ///
  /// Defaults to `false`.
  bool get isRtl => false;
}
