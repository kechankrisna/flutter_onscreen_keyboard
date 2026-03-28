import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';

/// Number of emoji columns per row.
const _kCols = 10;

/// Height of a category section header.
const _kHeaderHeight = 24.0;

/// A fully-featured emoji picker used inside [OnscreenKeyboard].
///
/// Shows a horizontal category tab strip at the top, a scrollable emoji grid
/// in the middle, and a row of action keys (back to keyboard, backspace) at
/// the bottom.
///
/// Tapping a category tab scrolls the grid to that section and highlights the
/// tab. Scrolling the grid updates the highlighted tab automatically.
class EmojiKeyboardWidget extends StatefulWidget {
  /// Creates an [EmojiKeyboardWidget].
  const EmojiKeyboardWidget({
    required this.rowHeight,
    required this.insertText,
    required this.onBackspace,
    required this.backModeName,
    required this.backModeLabel,
    super.key,
  });

  /// Suggested height for each row, derived from the reference keyboard mode.
  final double rowHeight;

  /// Inserts [text] into the active text field at the cursor.
  final void Function(String text) insertText;

  /// Deletes the character before the cursor.
  final VoidCallback onBackspace;

  /// The [KeyboardLayout] mode name to return to when the back key is tapped
  /// (e.g. `'khmer'` or `'alphabets'`).
  final String backModeName;

  /// Label rendered on the back key (e.g. `'ក'` or `'ABC'`).
  final String backModeLabel;

  @override
  State<EmojiKeyboardWidget> createState() => _EmojiKeyboardWidgetState();
}

class _EmojiKeyboardWidgetState extends State<EmojiKeyboardWidget> {
  final _scrollController = ScrollController();
  int _activeCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncTabFromScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_syncTabFromScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // ── Offset helpers ─────────────────────────────────────────────────────────

  /// Total scroll height of a category section (header + rows).
  double _sectionHeight(EmojiCategory cat) {
    final rows = (cat.emojis.length / _kCols).ceil();
    return _kHeaderHeight + rows * widget.rowHeight;
  }

  /// Y offset of the start of [categoryIndex] in the scroll view.
  double _offsetOf(int categoryIndex) {
    double y = 0;
    for (var i = 0; i < categoryIndex; i++) {
      y += _sectionHeight(emojiCategories[i]);
    }
    return y;
  }

  // ── Sync active tab from scroll position ───────────────────────────────────

  void _syncTabFromScroll() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    double y = 0;
    for (var i = 0; i < emojiCategories.length; i++) {
      final h = _sectionHeight(emojiCategories[i]);
      if (offset < y + h - widget.rowHeight / 2) {
        if (_activeCategoryIndex != i) {
          setState(() => _activeCategoryIndex = i);
        }
        return;
      }
      y += h;
    }
    // Scrolled past the last category.
    final last = emojiCategories.length - 1;
    if (_activeCategoryIndex != last) {
      setState(() => _activeCategoryIndex = last);
    }
  }

  // ── Tab tap handler ─────────────────────────────────────────────────────────

  void _scrollToCategory(int index) {
    setState(() => _activeCategoryIndex = index);
    _scrollController.animateTo(
      math.min(
        _offsetOf(index),
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurface.withValues(alpha: 0.5);
    final headerStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface.withValues(alpha: 0.6),
    );

    // ── Category tab strip ───────────────────────────────────────────────────
    final tabStrip = SizedBox(
      height: widget.rowHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < emojiCategories.length; i++)
              _buildTab(
                emojiCategories[i].icon,
                isActive: i == _activeCategoryIndex,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
                onTap: () => _scrollToCategory(i),
                rowHeight: widget.rowHeight,
              ),
          ],
        ),
      ),
    );

    // ── Emoji grid (scrollable) ──────────────────────────────────────────────
    final emojiGrid = Expanded(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final cat in emojiCategories) ...[
              // Section header
              SizedBox(
                height: _kHeaderHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(cat.name, style: headerStyle),
                  ),
                ),
              ),
              // Emoji rows
              for (int r = 0; r < (cat.emojis.length / _kCols).ceil(); r++)
                SizedBox(
                  height: widget.rowHeight,
                  child: Row(
                    children: [
                      for (int c = 0; c < _kCols; c++)
                        () {
                          final idx = r * _kCols + c;
                          if (idx >= cat.emojis.length) {
                            return const Expanded(child: SizedBox.shrink());
                          }
                          final emoji = cat.emojis[idx];
                          return Expanded(
                            child: _EmojiButton(
                              emoji: emoji,
                              onTap: () => widget.insertText(emoji),
                            ),
                          );
                        }(),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );

    // ── Bottom action row ────────────────────────────────────────────────────
    final actionRow = SizedBox(
      height: widget.rowHeight,
      child: Row(
        children: [
          // Back to keyboard
          Expanded(
            flex: 3,
            child: _ActionKey(
              onTap: () => OnscreenKeyboard.of(
                context,
              ).setModeNamed(widget.backModeName),
              child: Text(
                widget.backModeLabel,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          // Space: just as fat as the emoji area allows
          const Expanded(flex: 7, child: SizedBox.shrink()),
          // Backspace
          Expanded(
            flex: 2,
            child: _ActionKey(
              onTap: widget.onBackspace,
              child: Icon(
                Icons.backspace_outlined,
                size: widget.rowHeight * 0.4,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [tabStrip, emojiGrid, actionRow],
      ),
    );
  }

  Widget _buildTab(
    String icon, {
    required bool isActive,
    required Color activeColor,
    required Color inactiveColor,
    required VoidCallback onTap,
    required double rowHeight,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: rowHeight,
        height: rowHeight,
        decoration: isActive
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: activeColor, width: 2),
                ),
              )
            : null,
        alignment: Alignment.center,
        child: Text(
          icon,
          style: TextStyle(
            fontSize: rowHeight * 0.45,
            color: isActive ? activeColor : inactiveColor,
          ),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _EmojiButton extends StatelessWidget {
  const _EmojiButton({required this.emoji, required this.onTap});

  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}

class _ActionKey extends StatelessWidget {
  const _ActionKey({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(child: child),
    );
  }
}
