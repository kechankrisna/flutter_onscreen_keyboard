import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';

/// An internal widget that renders a horizontal strip of language buttons.
///
/// Shown inside the keyboard when [OnscreenKeyboard.supportedLanguages]
/// contains more than one entry. Tapping a button calls [setLayout] on the
/// nearest [OnscreenKeyboardController].
class LanguagePickerBar extends StatelessWidget {
  /// Creates a [LanguagePickerBar].
  const LanguagePickerBar({
    required this.supportedLanguages,
    required this.activeLanguageCode,
    super.key,
  });

  /// The list of language layouts to display as buttons.
  final List<LanguageKeyboardLayout> supportedLanguages;

  /// The BCP-47 code of the currently active language, used to highlight
  /// the active button. May be `null` if the active layout is not a
  /// [LanguageKeyboardLayout].
  final String? activeLanguageCode;

  @override
  Widget build(BuildContext context) {
    final controller = OnscreenKeyboard.of(context);
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 36,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            for (final lang in supportedLanguages)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: TextButton(
                  onPressed: () => controller.setLayout(lang),
                  style: lang.languageCode == activeLanguageCode
                      ? TextButton.styleFrom(
                          backgroundColor: colors.primaryContainer,
                          foregroundColor: colors.onPrimaryContainer,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(fontSize: 13),
                        )
                      : TextButton.styleFrom(
                          foregroundColor: colors.onSurface,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          textStyle: const TextStyle(fontSize: 13),
                        ),
                  child: Text(lang.displayName),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
