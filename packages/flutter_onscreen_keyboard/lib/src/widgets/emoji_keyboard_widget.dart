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

  /// Drives the tab-strip highlight without rebuilding the entire widget.
  /// Only the [ValueListenableBuilder] wrapping the tab row will re-render.
  late final ValueNotifier<int> _activeCategoryNotifier;

  /// Pre-computed Y-offsets for each category section so the scroll listener
  /// can do an O(log n) binary search instead of O(n) linear scan.
  late List<double> _sectionOffsets;

  @override
  void initState() {
    super.initState();
    _activeCategoryNotifier = ValueNotifier(0);
    _precomputeOffsets();
    _scrollController.addListener(_syncTabFromScroll);
  }

  @override
  void didUpdateWidget(EmojiKeyboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Row height change means all offsets are stale — recompute.
    if (oldWidget.rowHeight != widget.rowHeight) _precomputeOffsets();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_syncTabFromScroll);
    _scrollController.dispose();
    _activeCategoryNotifier.dispose();
    super.dispose();
  }

  // ── Offset helpers ─────────────────────────────────────────────────────────

  /// Total scroll height of a single category section (header + rows).
  double _sectionHeight(EmojiCategory cat) =>
      _kHeaderHeight + (cat.emojis.length / _kCols).ceil() * widget.rowHeight;

  /// Builds [_sectionOffsets] once so all later look-ups are O(1)/O(log n).
  void _precomputeOffsets() {
    double y = 0;
    _sectionOffsets = List.generate(emojiCategories.length, (i) {
      final offset = y;
      y += _sectionHeight(emojiCategories[i]);
      return offset;
    });
  }

  // ── Sync active tab from scroll position ───────────────────────────────────

  /// Called on every scroll frame. Uses a binary search over [_sectionOffsets]
  /// (O(log n)) and writes to [ValueNotifier] — *no* setState, so the emoji
  /// grid is never rebuilt.
  void _syncTabFromScroll() {
    if (!_scrollController.hasClients) return;
    // Offset half a row ahead so the tab flips as the header enters the top.
    final offset = _scrollController.offset + widget.rowHeight / 2;

    // Binary search: find the last category whose start offset <= [offset].
    var lo = 0;
    var hi = emojiCategories.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      if (_sectionOffsets[mid] <= offset) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    if (_activeCategoryNotifier.value != lo) {
      _activeCategoryNotifier.value = lo;
    }
  }

  // ── Tab tap handler ─────────────────────────────────────────────────────────

  void _scrollToCategory(int index) {
    _activeCategoryNotifier.value = index;
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      math.min(
        _sectionOffsets[index],
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

    // ── Category tab strip ───────────────────────────────────────────────────
    // ValueListenableBuilder scopes re-renders to this sub-tree only.
    // The emoji grid and action row are *never* rebuilt when tabs change.
    final tabStrip = SizedBox(
      height: widget.rowHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ValueListenableBuilder<int>(
          valueListenable: _activeCategoryNotifier,
          builder: (context, activeIndex, _) => Row(
            children: [
              for (var i = 0; i < emojiCategories.length; i++)
                _Tab(
                  icon: emojiCategories[i].icon,
                  isActive: i == activeIndex,
                  size: widget.rowHeight,
                  onTap: () => _scrollToCategory(i),
                ),
            ],
          ),
        ),
      ),
    );

    // ── Emoji grid (lazy via slivers) ────────────────────────────────────────
    // CustomScrollView + SliverFixedExtentList builds only the visible rows,
    // versus the old Column approach which allocated all ~1 000 emoji widgets
    // at once.
    final emojiGrid = Expanded(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          for (final cat in emojiCategories) ...[
            // Section header — SliverToBoxAdapter keeps it in the flow.
            SliverToBoxAdapter(child: _CategoryHeader(name: cat.name)),
            // Rows are fixed-height, so SliverFixedExtentList skips per-item
            // layout measurement (one of the fastest sliver types).
            SliverFixedExtentList(
              itemExtent: widget.rowHeight,
              delegate: SliverChildBuilderDelegate(
                (context, r) => _EmojiRow(
                  emojis: cat.emojis,
                  rowIndex: r,
                  onTap: widget.insertText,
                ),
                childCount: (cat.emojis.length / _kCols).ceil(),
              ),
            ),
          ],
        ],
      ),
    );

    // ── Bottom action row ────────────────────────────────────────────────────
    final actionRow = SizedBox(
      height: widget.rowHeight,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _ActionKey(
              onTap: () => OnscreenKeyboard.of(
                context,
              ).setModeNamed(widget.backModeName),
              child: Text(
                widget.backModeLabel,
                style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
              ),
            ),
          ),
          const Expanded(flex: 7, child: SizedBox.shrink()),
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
}

// ── Private widgets ───────────────────────────────────────────────────────────
// Using StatelessWidgets instead of helper functions lets Flutter short-circuit
// rebuilds when the same widget instance is re-encountered in the tree.

/// One tab button in the category strip.
class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.isActive,
    required this.size,
    required this.onTap,
  });

  final String icon;
  final bool isActive;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isActive
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.5);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: isActive
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colorScheme.primary, width: 2),
                ),
              )
            : null,
        alignment: Alignment.center,
        child: Text(
          icon,
          style: TextStyle(fontSize: size * 0.45, color: color),
        ),
      ),
    );
  }
}

/// Category section header rendered as a sliver item.
class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);
    return SizedBox(
      height: _kHeaderHeight,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

/// One row of up to [_kCols] emoji buttons inside the lazy sliver list.
class _EmojiRow extends StatelessWidget {
  const _EmojiRow({
    required this.emojis,
    required this.rowIndex,
    required this.onTap,
  });

  final List<String> emojis;
  final int rowIndex;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final start = rowIndex * _kCols;
    return Row(
      children: [for (var c = 0; c < _kCols; c++) _buildCell(start + c)],
    );
  }

  Widget _buildCell(int idx) {
    if (idx >= emojis.length) return const Expanded(child: SizedBox.shrink());
    final emoji = emojis[idx];
    return Expanded(
      child: _EmojiButton(emoji: emoji, onTap: () => onTap(emoji)),
    );
  }
}

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
