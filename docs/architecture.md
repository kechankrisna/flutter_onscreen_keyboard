# Architecture Guide

## Overview

`flutter_onscreen_keyboard` is a zero-external-dependency virtual keyboard for Flutter. The package uses a set of deliberate architectural patterns to share state efficiently and keep the public API minimal.

---

## File Structure

```
lib/
├── flutter_onscreen_keyboard.dart       ← Public barrel (all exports)
└── src/
    ├── onscreen_keyboard.dart           ← Core StatefulWidget + part host
    ├── onscreen_keyboard_controller.dart  ← Part: controller interface + impl
    ├── onscreen_keyboard_field_state.dart ← Part: field state interface + impl
    ├── onscreen_keyboard_text_field.dart  ← Part: TextField wrapper
    ├── onscreen_keyboard_text_form_field.dart ← Part: TextFormField wrapper
    ├── raw_onscreen_keyboard.dart       ← Stateless low-level renderer
    ├── types.dart                       ← Typedefs
    ├── constants/
    │   └── action_key_type.dart         ← ActionKeyType string constants
    ├── models/
    │   ├── keys.dart                    ← OnscreenKeyboardKey sealed class
    │   └── layout.dart                  ← KeyboardLayout, KeyboardMode, KeyboardRow
    ├── layouts/
    │   ├── layouts.dart                 ← Layout barrel
    │   ├── mobile_layout.dart           ← MobileKeyboardLayout
    │   └── desktop_layout.dart          ← DesktopKeyboardLayout
    ├── theme/
    │   ├── onscreen_keyboard_theme.dart      ← InheritedWidget propagator
    │   └── onscreen_keyboard_theme_data.dart ← Theme data classes
    ├── utils/
    │   └── extensions.dart              ← BuildContext / Color / controller extensions
    └── widgets/
        └── keys.dart                    ← TextKeyWidget, ActionKeyWidget (internal)
```

---

## Core Pattern: Part-File Architecture

`onscreen_keyboard.dart` acts as a **library host**. The file declares the library and imports its parts:

```dart
// onscreen_keyboard.dart
part 'onscreen_keyboard_controller.dart';
part 'onscreen_keyboard_field_state.dart';
part 'onscreen_keyboard_text_field.dart';
part 'onscreen_keyboard_text_form_field.dart';
```

Each `part` file can access `_OnscreenKeyboardState`'s private members directly. This eliminates the need for callback references or public setters for internal coordination.

**Do not break these out into standalone files** — private-member access is intentional and part of the design.

---

## State & Lifecycle

```
MaterialApp.builder
  └─ OnscreenKeyboard (StatefulWidget)
       └─ _OnscreenKeyboardState
            ├─ _overlay: OverlayEntry    — renders the keyboard widget
            ├─ _position: ValueNotifier<(double, double)>  — normalized drag position
            ├─ _isVisible: bool          — keyboard shown/hidden
            ├─ _activeField: _OnscreenKeyboardFieldStateImpl?  — focused text field
            ├─ _showSecondary: bool      — Shift/CapsLock state
            ├─ _pressedActionKeys: Set<String>  — highlighted action keys
            └─ _currentMode: String      — active layout mode name
```

The `Overlay` is used so the keyboard floats above all content regardless of widget tree depth.

---

## Controller Access Pattern

```
_OnscreenKeyboardState
  └─ exposes itself to descendants via _OnscreenKeyboardProvider (InheritedWidget)
       └─ OnscreenKeyboard.of(context) → OnscreenKeyboardController
            ↕ (also available via context.controller extension)
```

`OnscreenKeyboardController` is an `abstract interface class`. The concrete implementation (`_OnscreenKeyboardControllerImpl`, inside the part file) holds a reference to `_OnscreenKeyboardState` and delegates to it.

---

## Theme Propagation

```
OnscreenKeyboard
  └─ OnscreenKeyboardTheme (InheritedWidget)
       └─ RawOnscreenKeyboard
            └─ KeyboardRow
                 └─ TextKeyWidget / ActionKeyWidget
                      └─ context.theme → OnscreenKeyboardThemeData
```

Per-mode theme overrides: `KeyboardMode.theme` is a `BuildContext → OnscreenKeyboardThemeData` function evaluated at build time. The `RawOnscreenKeyboard` wraps itself in an additional `OnscreenKeyboardTheme` if the active mode provides a theme override.

---

## Key Type Hierarchy

```
OnscreenKeyboardKey (sealed)
├── TextKey       — types a character (primary or secondary/shifted)
└── ActionKey     — triggers behavior (backspace, enter, shift, etc.)
```

Always use exhaustive pattern matching:
```dart
switch (key) {
  case TextKey(:final primary): print('typed $primary');
  case ActionKey(:final name): print('action $name');
}
```

---

## Input Processing Flow

```
User taps key
  → ActionKeyWidget / TextKeyWidget: onTapDown / onTap / onTapUp callbacks
  → _OnscreenKeyboardState._handleKeyDown / _handleKeyUp
       ├─ ActionKey(backspace) → remove grapheme cluster from selection
       ├─ ActionKey(enter)     → insertNewline or unfocus
       ├─ ActionKey(tab)       → insert '\t'
       ├─ ActionKey(shift)     → toggle _showSecondary, auto-release on keyUp
       ├─ ActionKey(capslock)  → toggle _showSecondary (stays until next press)
       ├─ ActionKey(custom)    → fire raw listeners only
       └─ TextKey              → insert character at selection,
                                  apply inputFormatters,
                                  call onChanged
```

**Emoji-safe backspace** uses `String.characters` (grapheme clusters) to correctly handle multi-codepoint emoji sequences.

---

## Positioning System

The keyboard position is stored as a normalized `(double x, double y)` pair in `[0..1] × [0..1]` space inside a `ValueNotifier`. At render time it maps to an `Alignment`:

```dart
Alignment(x * 2 - 1, y * 2 - 1)  // [0..1] → [-1..1]
```

Dragging updates the `ValueNotifier`; `Align` rebuilds only the positioned overlay entry.

---

## Keyboard Rendering (`RawOnscreenKeyboard`)

```
AspectRatio(aspectRatio)
  └─ Padding (keyboard padding)
       └─ Column
            └─ [for each KeyboardRow]
                 Expanded(flex: 1)
                   └─ Row
                        ├─ leading widget (if any)
                        ├─ [for each key] Expanded(flex: key.flex)
                        │    └─ TextKeyWidget or ActionKeyWidget
                        └─ trailing widget (if any)
```

Key width is proportional: `flex / sum(flex in row)`. Default flex is `20`; spacer keys use a proportionally smaller flex value.

---

## `TextFieldTapRegion`

Both text field wrappers and the keyboard overlay are wrapped in `TextFieldTapRegion`. This tells Flutter that taps on the keyboard do **not** count as "outside" the text field, preventing focus loss when a key is pressed.

---

## Adding a New Layout

1. Create `lib/src/layouts/my_layout.dart` extending `KeyboardLayout`.
2. Export it from `lib/src/layouts/layouts.dart`.
3. Re-export from the public barrel `lib/flutter_onscreen_keyboard.dart`.

```dart
class MyKeyboardLayout extends KeyboardLayout {
  const MyKeyboardLayout();

  @override
  double get aspectRatio => 4 / 3;

  @override
  Map<String, KeyboardMode> get modes => {
    'default': KeyboardMode(
      rows: [
        KeyboardRow(keys: [
          OnscreenKeyboardKey.text(primary: 'a'),
          OnscreenKeyboardKey.action(name: ActionKeyType.backspace),
        ]),
      ],
    ),
  };
}
```

---

## Adding a New Theme Preset

Add a named factory constructor to `OnscreenKeyboardThemeData` in `lib/src/theme/onscreen_keyboard_theme_data.dart`:

```dart
factory OnscreenKeyboardThemeData.dark() {
  return OnscreenKeyboardThemeData(
    color: const Color(0xFF1C1C1E),
    textKeyThemeData: TextKeyThemeData(
      backgroundColor: const Color(0xFF2C2C2E),
      textStyle: const TextStyle(color: Colors.white),
    ),
    actionKeyThemeData: ActionKeyThemeData(
      backgroundColor: const Color(0xFF48484A),
      pressedBackgroundColor: const Color(0xFF0A84FF),
    ),
  );
}
```

---

## Testing Conventions

- Widget tests only — no unit tests for widgets.
- Use `tester.pumpWidget(...)` wrapping with `MaterialApp(builder: OnscreenKeyboard.builder(...), home: ...)`.
- Access controller via `OnscreenKeyboard.of(tester.element(find.byType(OnscreenKeyboard)))`.
- Tap keys by finding their label text: `find.text('a')`, `find.text('⌫')`.
- Verify text field content after typing via `expect(controller.text, equals(...))`.
