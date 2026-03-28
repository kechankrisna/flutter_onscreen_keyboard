import 'package:flutter/widgets.dart';
import 'package:flutter_onscreen_keyboard/src/models/keys.dart';

/// A function that returns the desired width for the keyboard widget.
typedef WidthGetter = double Function(BuildContext context);

/// A function that returns the desired height for the keyboard widget.
typedef HeightGetter = double Function(BuildContext context);

/// Signature for a listener function that responds to keyboard key events.
///
/// Called when a key is pressed on the on-screen keyboard.
typedef OnscreenKeyboardListener = void Function(OnscreenKeyboardKey key);

/// Signature for building a list of action widgets for the
/// keyboard control bar.
typedef ActionsBuilder = List<Widget> Function(BuildContext context);

/// A callback function that receives the current [BuildContext].
typedef CallbackWithContext = void Function(BuildContext context);

/// An async callback that returns word-prediction suggestions.
///
/// [currentWord] is the text fragment immediately before the cursor (from
/// the last whitespace to the cursor). [fullText] is the entire field content
/// for context-aware prediction.
///
/// Return an empty list when no suggestions are available.
typedef WordPredictionCallback =
    Future<List<String>> Function(String currentWord, String fullText);
