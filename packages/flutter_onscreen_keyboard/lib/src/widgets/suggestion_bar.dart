import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart'
    show OnscreenKeyboard;
import 'package:flutter_onscreen_keyboard/src/onscreen_keyboard.dart'
    show OnscreenKeyboard;

/// An internal widget that renders a horizontal strip of word-prediction chips.
///
/// Shown above the key rows when [OnscreenKeyboard.wordPrediction] is set
/// and the current suggestion list is non-empty. Tapping a chip calls
/// [onSuggestionTap] with the selected word.
class SuggestionBar extends StatelessWidget {
  /// Creates a [SuggestionBar].
  const SuggestionBar({
    required this.suggestions,
    required this.onSuggestionTap,
    super.key,
  });

  /// The list of word suggestions to display.
  final List<String> suggestions;

  /// Called when the user taps a suggestion chip.
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            for (final word in suggestions)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
                child: InkWell(
                  onTap: () => onSuggestionTap(word),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      word,
                      style: TextStyle(
                        color: colors.onSecondaryContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
