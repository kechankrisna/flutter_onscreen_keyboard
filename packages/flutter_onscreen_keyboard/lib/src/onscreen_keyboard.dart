import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';
import 'package:flutter_onscreen_keyboard/src/constants/action_key_type.dart';
import 'package:flutter_onscreen_keyboard/src/theme/onscreen_keyboard_theme.dart';
import 'package:flutter_onscreen_keyboard/src/types.dart';
import 'package:flutter_onscreen_keyboard/src/utils/extensions.dart';
import 'package:flutter_onscreen_keyboard/src/widgets/suggestion_bar.dart';

part 'onscreen_keyboard_controller.dart';
part 'onscreen_keyboard_field_state.dart';
part 'onscreen_keyboard_text_field.dart';
part 'onscreen_keyboard_text_form_field.dart';

/// A customizable on-screen keyboard widget.
///
/// Wrap your application with this widget to enable the
/// on-screen keyboard functionality.
class OnscreenKeyboard extends StatefulWidget {
  /// Creates an [OnscreenKeyboard].
  const OnscreenKeyboard({
    required this.child,
    super.key,
    this.layout,
    this.theme,
    this.width,
    this.height,
    this.dragHandle,
    this.aspectRatio,
    this.showControlBar = true,
    this.buildControlBarActions,
    this.supportedLanguages,
    this.wordPrediction,
    this.maxSuggestions = 5,
  });

  /// The main application child widget.
  final Widget child;

  /// The layout configuration for the keyboard.
  ///
  /// If not provided, a default layout will be selected automatically
  /// based on the current [defaultTargetPlatform] — a [MobileKeyboardLayout]
  /// for Android/iOS/Fuchsia and a [DesktopKeyboardLayout] for
  /// macOS/Windows/Linux.
  final KeyboardLayout? layout;

  /// Custom theme for the on-screen keyboard UI.
  ///
  /// If not provided, a default theme based on
  /// the current [ThemeData] will be used.
  final OnscreenKeyboardThemeData? theme;

  /// An optional width configuration function for the keyboard.
  final WidthGetter? width;

  /// An optional height configuration function for the keyboard.
  ///
  /// When provided, the keyboard height is fixed to the returned value and
  /// the width is derived automatically from the layout's aspect ratio
  /// (unless [width] is also set, in which case both are used as-is).
  final HeightGetter? height;

  /// A widget displayed as a drag handle to move the keyboard.
  final Widget? dragHandle;

  /// {@macro keyboardLayout.aspectRatio}
  final double? aspectRatio;

  /// Whether to show the control bar at the top of the keyboard.
  /// Defaults to `true`.
  final bool showControlBar;

  /// {@macro controlBar.actions}
  final ActionsBuilder? buildControlBarActions;

  /// The list of language layouts available in the built-in language picker.
  ///
  /// When more than one layout is provided, a language picker strip is shown
  /// between the control bar and the key rows. Tapping a language calls
  /// [OnscreenKeyboardController.setLayout] automatically.
  ///
  /// Set to `null` (default) to hide the picker entirely.
  final List<LanguageKeyboardLayout>? supportedLanguages;

  /// An optional callback for generating word-prediction suggestions.
  ///
  /// When provided, a suggestion bar is shown above the key rows. The callback
  /// receives the current word fragment before the cursor and the full field
  /// text, and should return a list of completions asynchronously.
  ///
  /// Tapping a suggestion replaces the current word and appends a space.
  final WordPredictionCallback? wordPrediction;

  /// Maximum number of word predictions to display. Defaults to `5`.
  final int maxSuggestions;

  /// A builder to wrap the app with [OnscreenKeyboard].
  ///
  /// This provides a convenient way to globally integrate the
  /// on-screen keyboard into your app by setting it as the
  /// `builder` of your [MaterialApp] or [WidgetsApp].
  ///
  /// ### Example
  /// ```dart
  /// MaterialApp(
  ///   builder: OnscreenKeyboard.builder(
  ///     width: (context) => 600,
  ///     aspectRatio: 5 / 2,
  ///     // ...more options
  ///   ),
  ///   home: const HomeScreen(),
  /// );
  /// ```
  ///
  /// - [theme]: Custom theme configuration for the keyboard, such as color,
  ///   shadow, border, margin, and shape. If null, defaults will be applied.
  /// - [layout]: Keyboard layout to render. Falls back to default layout
  ///   if not set.
  /// - [width]: A function that returns the keyboard's width.
  /// - [showControlBar]: Whether to show the control bar at the top of the
  ///   keyboard. Defaults to `true`.
  /// - [dragHandle]: A widget to show as the drag handle above the keyboard.
  ///   If null, a default handle is shown.
  /// - [aspectRatio]: Determines the width-to-height ratio of the
  ///   keyboard widget.
  /// - [buildControlBarActions]: A callback that builds trailing action widgets
  ///   (e.g., move, close) in the keyboard's control bar. If omitted, default
  ///   actions are shown.
  ///
  /// Returns a [TransitionBuilder] to be passed to [MaterialApp.builder].
  ///
  /// See also:
  ///  - [OnscreenKeyboard.new], which creates an [OnscreenKeyboard] widget.
  static TransitionBuilder builder({
    OnscreenKeyboardThemeData? theme,
    KeyboardLayout? layout,
    WidthGetter? width,
    HeightGetter? height,
    bool showControlBar = true,
    Widget? dragHandle,
    double? aspectRatio,
    ActionsBuilder? buildControlBarActions,
    List<LanguageKeyboardLayout>? supportedLanguages,
    WordPredictionCallback? wordPrediction,
    int maxSuggestions = 5,
  }) => (context, child) {
    return OnscreenKeyboard(
      theme: theme,
      layout: layout,
      width: width,
      height: height,
      showControlBar: showControlBar,
      dragHandle: dragHandle,
      aspectRatio: aspectRatio,
      buildControlBarActions: buildControlBarActions,
      supportedLanguages: supportedLanguages,
      wordPrediction: wordPrediction,
      maxSuggestions: maxSuggestions,
      child: child!,
    );
  };

  /// Gets the nearest [OnscreenKeyboardController] from the widget tree.
  static OnscreenKeyboardController of(BuildContext context) {
    final provider = context
        .getInheritedWidgetOfExactType<_OnscreenKeyboardProvider>();
    assert(
      provider != null,
      '''
No OnscreenKeyboard found in context. Did you wrap your app with OnscreenKeyboard?

    MaterialApp(
      builder: OnscreenKeyboard.builder(),  // <- add this line
      home: const App(),
    )
    ''',
    );
    return provider!.state;
  }

  @override
  State<OnscreenKeyboard> createState() => _OnscreenKeyboardState();
}

class _OnscreenKeyboardState extends State<OnscreenKeyboard>
    implements OnscreenKeyboardController {
  /// Whether to show the secondary keys.
  bool get _showSecondary =>
      _pressedActionKeys.contains(ActionKeyType.capslock) ^
      _pressedActionKeys.contains(ActionKeyType.shift);

  final _pressedActionKeys = <String>{};

  @override
  KeyboardLayout get layout => _layout;

  void _onKeyDown(OnscreenKeyboardKey key) {
    switch (key) {
      case TextKey():
        _handleTexTextKeyDown(key);
      case ActionKey():
        _handleActionKeyDown(key);
    }

    for (final listener in _rawKeyDownListeners) {
      listener(key);
    }
  }

  void _onKeyUp(OnscreenKeyboardKey key) {
    switch (key) {
      case TextKey():
        break;
      case ActionKey():
        _handleActionKeyUp(key);
    }
  }

  void _handleTexTextKeyDown(TextKey key) {
    if (activeTextField?.controller case final controller?
        when controller.selection.isValid) {
      final keyText = key.getText(secondary: _showSecondary);
      final currentText = controller.text;
      final selection = controller.selection;

      // Create the new text value by replacing the selected range
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        keyText,
      );

      // Calculate the new cursor position
      final newCursorPosition = selection.start + keyText.length;

      // Create a new TextEditingValue with the proposed changes
      var newValue = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newCursorPosition),
      );

      // Apply input formatters if they exist
      if (activeTextField!.inputFormatters != null) {
        final oldValue = controller.value;
        for (final formatter in activeTextField!.inputFormatters!) {
          newValue = formatter.formatEditUpdate(oldValue, newValue);
        }
      }

      // Only update if the formatters didn't reject the change
      if (newValue.text != controller.text ||
          newValue.selection != controller.selection) {
        controller.value = newValue;

        // Call the onChanged callback if the text actually changed
        if (newValue.text != currentText &&
            activeTextField!.onChanged != null) {
          activeTextField!.onChanged!(newValue.text);
        }
      }
    }
  }

  void _handleActionKeyDown(ActionKey key) {
    if (!key.canHold) {
      setState(() => _pressedActionKeys.add(key.name));
    }

    if (activeTextField?.controller case final controller?
        when controller.selection.isValid) {
      final originalText = controller.text;

      switch (key.name) {
        case ActionKeyType.backspace:
          if (controller.text.isEmpty) return;
          String? newText;
          int? offset;
          if (!controller.selection.isCollapsed) {
            newText = controller.text.replaceRange(
              controller.start,
              controller.end,
              '',
            );
            offset = controller.start;
          } else if (controller.start > 0) {
            // handling emojis
            final leftSide = controller.text
                .substring(0, controller.start)
                .characters
                .toList();
            final rightSide = controller.text.substring(controller.start);
            offset = controller.start - leftSide.removeLast().length;
            newText = leftSide.join() + rightSide;
          }
          if (newText != null && offset != null) {
            controller.value = TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(offset: offset),
            );

            // Call onChanged callback if text changed
            if (newText != originalText && activeTextField!.onChanged != null) {
              activeTextField!.onChanged!(newText);
            }
          }

        case ActionKeyType.tab:
          if (!controller.selection.isValid) return;
          final newText = controller.text.replaceRange(
            controller.start,
            controller.end,
            '\t',
          );
          controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: controller.start + 1),
          );

          // Call onChanged callback if text changed
          if (newText != originalText && activeTextField!.onChanged != null) {
            activeTextField!.onChanged!(newText);
          }

        case ActionKeyType.enter:
          if (!controller.selection.isValid) return;
          if (activeTextField!.maxLines == 1) {
            // if a single line field
            activeTextField!.focusNode.unfocus();
            // close();
          } else {
            // if a multi line field
            final newText = controller.text.replaceRange(
              controller.start,
              controller.end,
              '\n',
            );
            controller.value = TextEditingValue(
              text: newText,
              selection: TextSelection.collapsed(offset: controller.start + 1),
            );

            // Call onChanged callback if text changed
            if (newText != originalText && activeTextField!.onChanged != null) {
              activeTextField!.onChanged!(newText);
            }
          }

        case ActionKeyType.capslock:
          break;
        case ActionKeyType.shift:
          break;
      }
    }
  }

  void _handleActionKeyUp(ActionKey key) {
    _safeSetState(() {
      if (key.canHold && !_pressedActionKeys.contains(key.name)) {
        _pressedActionKeys.add(key.name);
      } else {
        _pressedActionKeys.remove(key.name);
      }
    });
  }

  /// Safely call [setState] after the current frame.
  void _safeSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(fn));
  }

  /// Whether the keyboard is currently visible.
  bool _visible = false;

  @override
  void open() => setState(() => _visible = true);

  @override
  void close() {
    detachTextField();
    setState(() => _visible = false);
  }

  @override
  void setAlignment(Alignment alignment) {
    _alignListener.value = ((alignment.x + 1) / 2, (alignment.y + 1) / 2);
  }

  @override
  void moveToTop() => setAlignment(Alignment.topCenter);

  @override
  void moveToBottom() => setAlignment(Alignment.bottomCenter);

  @override
  void attachTextField(OnscreenKeyboardFieldState state) {
    _removePredictionListener();
    _activeTextField.value = state;
    _addPredictionListener(state);
  }

  @override
  void detachTextField([OnscreenKeyboardFieldState? state]) {
    if (state == null || state == activeTextField) {
      _removePredictionListener();
      _activeTextField.value = null;
      if (_suggestions.isNotEmpty) setState(() => _suggestions = []);
    }
  }

  final _activeTextField = ValueNotifier<OnscreenKeyboardFieldState?>(null);

  OnscreenKeyboardFieldState? get activeTextField => _activeTextField.value;

  /// List of raw key down listeners.
  final _rawKeyDownListeners = ObserverList<OnscreenKeyboardListener>();

  @override
  void addRawKeyDownListener(OnscreenKeyboardListener listener) {
    _rawKeyDownListeners.add(listener);
  }

  @override
  void removeRawKeyDownListener(OnscreenKeyboardListener listener) {
    _rawKeyDownListeners.remove(listener);
  }

  /// Returns the default keyboard layout based on the current platform.
  KeyboardLayout _getDefaultLayout() => switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.fuchsia => const MobileKeyboardLayout(),
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux => const DesktopKeyboardLayout(),
  };

  /// The resolved layout used by the keyboard.
  late KeyboardLayout _layout =
      widget.layout ??
      widget.supportedLanguages?.firstOrNull ??
      _getDefaultLayout();

  /// The current active keyboard mode (e.g., "alphabetic", "symbols").
  ///
  /// This determines which layout mode from [KeyboardLayout.modes] is used.
  late String _mode = _layout.modes.keys.first;

  @override
  void switchMode() {
    final modes = _layout.modes.keys.toList();
    final i = modes.indexOf(_mode);
    setState(() => _mode = modes[(i + 1) % modes.length]);
  }

  @override
  void setModeNamed(String modeName) {
    if (_mode == modeName) return;

    if (_layout.modes.containsKey(modeName)) {
      setState(() {
        _mode = modeName;
      });
    } else {
      debugPrint(
        "OnScreenKeyboard: Keyboard mode '$modeName' "
        'not found on the KeyboardLayout.',
      );
    }
  }

  @override
  void setLayout(KeyboardLayout layout) {
    setState(() {
      _layout = layout;
      _mode = layout.modes.keys.first;
      _pressedActionKeys.clear();
    });
  }

  @override
  void switchLanguage() {
    final langs = widget.supportedLanguages;
    if (langs == null || langs.length < 2) return;
    final currentIndex = langs.indexWhere(
      (l) =>
          _layout is LanguageKeyboardLayout &&
          l.languageCode == (_layout as LanguageKeyboardLayout).languageCode,
    );
    final nextIndex = currentIndex < 0 ? 0 : (currentIndex + 1) % langs.length;
    setLayout(langs[nextIndex]);
  }

  // ── Word-prediction state ────────────────────────────────────────────────

  List<String> _suggestions = [];
  VoidCallback? _textFieldListener;

  void _addPredictionListener(OnscreenKeyboardFieldState state) {
    if (widget.wordPrediction == null) return;
    _textFieldListener = () => _onActiveTextChanged(state.controller);
    state.controller.addListener(_textFieldListener!);
  }

  void _removePredictionListener() {
    final field = activeTextField;
    if (field != null && _textFieldListener != null) {
      field.controller.removeListener(_textFieldListener!);
      _textFieldListener = null;
    }
  }

  Future<void> _onActiveTextChanged(TextEditingController controller) async {
    if (widget.wordPrediction == null || !mounted) return;
    final text = controller.text;
    final cursor = controller.selection.baseOffset;
    if (cursor < 0) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = []);
      return;
    }
    final before = text.substring(0, cursor);
    final currentWord = before.split(RegExp(r'[\s\n]+')).last;
    if (currentWord.isEmpty) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = []);
      return;
    }
    try {
      final results = await widget.wordPrediction!(currentWord, text);
      if (mounted) {
        setState(
          () => _suggestions = results.take(widget.maxSuggestions).toList(),
        );
      }
    } on Exception catch (_) {
      if (mounted && _suggestions.isNotEmpty) {
        setState(() => _suggestions = []);
      }
    }
  }

  void _applySuggestion(String word) {
    final field = activeTextField;
    if (field == null) return;
    final controller = field.controller;
    if (!controller.selection.isValid) return;
    final text = controller.text;
    final cursor = controller.selection.baseOffset;
    if (cursor < 0) return;
    final before = text.substring(0, cursor);
    final after = text.substring(cursor);
    final wordStart = before.lastIndexOf(RegExp(r'[\s\n]')) + 1;
    final newText = '${text.substring(0, wordStart)}$word $after';
    final newCursor = wordStart + word.length + 1;
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursor),
    );
    field.onChanged?.call(newText);
    setState(() => _suggestions = []);
  }

  final GlobalKey _keyboardKey = GlobalKey();

  /// Alignment of the keyboard
  final ValueNotifier<(double, double)> _alignListener = ValueNotifier((.5, 1));

  /// Whether the keyboard is currently being dragged.
  final ValueNotifier<bool> _draggingListener = ValueNotifier(false);

  @override
  void dispose() {
    _removePredictionListener();
    _alignListener.dispose();
    _draggingListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(
      _layout.modes.isNotEmpty,
      'Keyboard layout must have at least one mode defined.',
    );

    return _OnscreenKeyboardProvider(
      state: this,
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (context) => OnscreenKeyboardTheme(
              data: widget.theme ?? const OnscreenKeyboardThemeData(),
              child: Stack(
                children: [
                  // the app widget
                  widget.child,

                  // keyboard
                  if (_visible)
                    Positioned.fill(
                      child: Builder(
                        builder: (context) {
                          final useSaveArea = context.theme.useSafeArea ?? true;
                          return SafeArea(
                            top: useSaveArea,
                            right: useSaveArea,
                            bottom: useSaveArea,
                            left: useSaveArea,
                            child: Builder(
                              builder: (context) {
                                // drag handle keyboard widget
                                final dragHandle = GestureDetector(
                                  onPanStart: (_) =>
                                      _draggingListener.value = true,
                                  onPanCancel: () =>
                                      _draggingListener.value = false,
                                  onPanDown: (_) =>
                                      _draggingListener.value = true,
                                  onPanEnd: (_) =>
                                      _draggingListener.value = false,
                                  onPanUpdate: (details) {
                                    final keyboardSize =
                                        _keyboardKey.currentContext!.size!;
                                    _alignListener.value = (
                                      (_alignListener.value.$1 +
                                              details.delta.dx /
                                                  (context.size!.width -
                                                      keyboardSize.width))
                                          .clamp(0.0, 1.0),
                                      (_alignListener.value.$2 +
                                              details.delta.dy /
                                                  (context.size!.height -
                                                      keyboardSize.height))
                                          .clamp(0.0, 1.0),
                                    );
                                  },
                                  child: ValueListenableBuilder(
                                    valueListenable: _draggingListener,
                                    builder: (context, value, child) {
                                      // user defined drag handle
                                      if (child != null) return child;
                                      return IconButton(
                                        mouseCursor: value
                                            ? SystemMouseCursors.grabbing
                                            : SystemMouseCursors.grab,
                                        onPressed: null,
                                        icon: Icon(
                                          Icons.drag_handle_rounded,
                                          color: Theme.of(
                                            context,
                                          ).iconTheme.color,
                                        ),
                                      );
                                    },
                                    child: widget.dragHandle,
                                  ),
                                );

                                // keyboard widget
                                final keyboard = TextFieldTapRegion(
                                  // theme override for modes
                                  child: OnscreenKeyboardTheme(
                                    data:
                                        _layout.modes[_mode]!.theme?.call(
                                          context,
                                        ) ??
                                        context.theme,
                                    child: Builder(
                                      key: _keyboardKey,
                                      builder: (context) {
                                        final colors = Theme.of(
                                          context,
                                        ).colorScheme;
                                        final theme = context.theme;
                                        final borderRadius =
                                            theme.borderRadius ??
                                            BorderRadius.circular(6);
                                        return Material(
                                          type: MaterialType.transparency,
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              // Resolve keyboard dimensions.
                                              // Priority:
                                              //   1. Both width & height set → use both as-is
                                              //   2. Width only → height driven by AspectRatio inside RawOnscreenKeyboard
                                              //   3. Height only → derive width from height × aspectRatio
                                              //   4. Neither → 40%-of-height heuristic
                                              final effectiveAspectRatio =
                                                  widget.aspectRatio ??
                                                  _layout.aspectRatio;

                                              final double keyboardWidth;
                                              final double? keyboardHeight;

                                              if (widget.width != null &&
                                                  widget.height != null) {
                                                keyboardWidth = widget.width!
                                                    .call(context);
                                                keyboardHeight = widget.height!
                                                    .call(
                                                      context,
                                                    );
                                              } else if (widget.width != null) {
                                                keyboardWidth = widget.width!
                                                    .call(context);
                                                keyboardHeight = null;
                                              } else if (widget.height !=
                                                  null) {
                                                keyboardHeight = widget.height!
                                                    .call(
                                                      context,
                                                    );
                                                keyboardWidth =
                                                    keyboardHeight *
                                                    effectiveAspectRatio;
                                              } else {
                                                // Default: cap to 40 % of
                                                // available height, clamped
                                                // to available width.
                                                final maxByHeight =
                                                    constraints
                                                        .maxHeight
                                                        .isFinite
                                                    ? constraints.maxHeight *
                                                          0.4 *
                                                          effectiveAspectRatio
                                                    : double.infinity;
                                                final maxByWidth =
                                                    constraints
                                                        .maxWidth
                                                        .isFinite
                                                    ? constraints.maxWidth
                                                    : 500.0;
                                                keyboardWidth =
                                                    maxByHeight < maxByWidth
                                                    ? maxByHeight
                                                    : maxByWidth;
                                                keyboardHeight = null;
                                              }
                                              return Container(
                                                width: keyboardWidth,
                                                height: keyboardHeight,
                                                margin: theme.margin,
                                                padding: theme.padding,
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                  color: theme.color,
                                                  borderRadius: borderRadius,
                                                  gradient: theme.gradient,
                                                  boxShadow:
                                                      theme.boxShadow ??
                                                      [
                                                        BoxShadow(
                                                          color: colors.shadow
                                                              .fade(0.05),
                                                          spreadRadius: 5,
                                                          blurRadius: 5,
                                                        ),
                                                      ],
                                                ),
                                                foregroundDecoration:
                                                    BoxDecoration(
                                                      borderRadius:
                                                          borderRadius,
                                                      border:
                                                          theme.border ??
                                                          Border.all(
                                                            color: colors
                                                                .outline
                                                                .fade(),
                                                          ),
                                                    ),
                                                child: Builder(
                                                  builder: (context) {
                                                    final textDirection =
                                                        _layout
                                                                is LanguageKeyboardLayout &&
                                                            (_layout
                                                                    as LanguageKeyboardLayout)
                                                                .isRtl
                                                        ? TextDirection.rtl
                                                        : TextDirection.ltr;

                                                    final activeLanguageCode =
                                                        _layout
                                                            is LanguageKeyboardLayout
                                                        ? (_layout
                                                                  as LanguageKeyboardLayout)
                                                              .languageCode
                                                        : null;

                                                    return Column(
                                                      mainAxisSize:
                                                          keyboardHeight != null
                                                          ? MainAxisSize.max
                                                          : MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      children: [
                                                        if (widget
                                                            .showControlBar)
                                                          _ControlBar(
                                                            dragHandle:
                                                                dragHandle,
                                                            actions: widget
                                                                .buildControlBarActions
                                                                ?.call(context),
                                                          ),
                                                        SuggestionBar(
                                                          suggestions:
                                                              _suggestions,
                                                          onSuggestionTap:
                                                              _applySuggestion,
                                                        ),
                                                        // When height is
                                                        // explicit, Expanded
                                                        // makes the key rows
                                                        // fill the remaining
                                                        // space after the bars.
                                                        if (keyboardHeight !=
                                                            null)
                                                          Expanded(
                                                            child: RawOnscreenKeyboard(
                                                              aspectRatio: widget
                                                                  .aspectRatio,
                                                              onKeyDown:
                                                                  _onKeyDown,
                                                              onKeyUp: _onKeyUp,
                                                              layout: _layout,
                                                              mode: _mode,
                                                              pressedActionKeys:
                                                                  _pressedActionKeys,
                                                              showSecondary:
                                                                  _showSecondary,
                                                              textDirection:
                                                                  textDirection,
                                                            ),
                                                          )
                                                        else
                                                          RawOnscreenKeyboard(
                                                            aspectRatio: widget
                                                                .aspectRatio,
                                                            onKeyDown:
                                                                _onKeyDown,
                                                            onKeyUp: _onKeyUp,
                                                            layout: _layout,
                                                            mode: _mode,
                                                            pressedActionKeys:
                                                                _pressedActionKeys,
                                                            showSecondary:
                                                                _showSecondary,
                                                            textDirection:
                                                                textDirection,
                                                          ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );

                                return AnimatedBuilder(
                                  animation: _alignListener,
                                  builder: (context, child) {
                                    return Align(
                                      alignment: Alignment(
                                        _alignListener.value.$1 * 2 - 1,
                                        _alignListener.value.$2 * 2 - 1,
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: keyboard,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Default control bar widget used in the on-screen keyboard.
///
/// This bar typically appears at the top of the keyboard and provides:
class _ControlBar extends StatelessWidget {
  /// Creates a control bar for the on-screen keyboard.
  const _ControlBar({
    required this.dragHandle,
    this.actions,
  });

  /// A widget used for dragging the keyboard.
  final Widget dragHandle;

  /// {@template controlBar.actions}
  /// Optional custom action widgets shown on the right side of the control bar.
  ///
  /// If not provided or is empty, default actions are shown:
  /// - Move to bottom
  /// - Move to top
  /// - Close keyboard
  /// {@endtemplate}
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = context.theme;

    final Widget trailing;
    if (actions != null && actions!.isNotEmpty) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: actions!,
      );
    } else {
      trailing = Flexible(
        child: FittedBox(
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  OnscreenKeyboard.of(context).moveToBottom();
                },
                icon: const Icon(Icons.arrow_downward_rounded),
                tooltip: 'Move to bottom',
              ),
              IconButton(
                onPressed: () {
                  OnscreenKeyboard.of(context).moveToTop();
                },
                icon: const Icon(Icons.arrow_upward_rounded),
                tooltip: 'Move to top',
              ),
              IconButton(
                onPressed: () {
                  OnscreenKeyboard.of(context).close();
                },
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Close',
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: theme.controlBarColor ?? colors.surfaceContainer,
      child: IconButtonTheme(
        data: IconButtonThemeData(style: IconButton.styleFrom(iconSize: 16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            dragHandle,
            trailing,
          ],
        ),
      ),
    );
  }
}

/// An [InheritedWidget] that provides [OnscreenKeyboardController]
/// to its descendants.
class _OnscreenKeyboardProvider extends InheritedWidget {
  const _OnscreenKeyboardProvider({
    required this.state,
    required super.child,
  });

  /// The state of the nearest [OnscreenKeyboard] in the widget tree.
  final _OnscreenKeyboardState state;

  @override
  bool updateShouldNotify(_OnscreenKeyboardProvider oldWidget) =>
      oldWidget.state != state;
}
