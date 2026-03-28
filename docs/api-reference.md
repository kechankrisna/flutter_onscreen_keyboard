# API Reference

Complete reference for the `flutter_onscreen_keyboard` package public API.

---

## Widgets

### `OnscreenKeyboard`

The root widget. Place it in `MaterialApp.builder` to enable the virtual keyboard throughout your app.

```dart
MaterialApp(
  builder: OnscreenKeyboard.builder(
    layout: DesktopKeyboardLayout(),
    theme: OnscreenKeyboardThemeData.gBoard(),
    width: (context) => MediaQuery.of(context).size.width * 0.6,
  ),
)
```

#### Constructor

```dart
OnscreenKeyboard({
  required Widget child,
  KeyboardLayout? layout,          // default: auto-select by platform
  OnscreenKeyboardThemeData? theme,
  WidthGetter? width,              // keyboard width at runtime
  Widget? dragHandle,              // custom drag handle widget
  double? aspectRatio,             // overrides layout's aspectRatio
  bool showControlBar = true,
  ActionsBuilder? buildControlBarActions,
})
```

#### Static Members

| Member | Description |
|--------|-------------|
| `OnscreenKeyboard.builder({...})` | Returns a `TransitionBuilder` for `MaterialApp.builder` |
| `OnscreenKeyboard.of(context)` | Returns the `OnscreenKeyboardController` from the nearest ancestor |

#### Platform Default Layouts

| Platform | Default Layout |
|----------|---------------|
| Android, iOS, Fuchsia | `MobileKeyboardLayout` |
| macOS, Windows, Linux | `DesktopKeyboardLayout` |

---

### `OnscreenKeyboardTextField`

Drop-in replacement for Flutter's `TextField`. Connects to the nearest `OnscreenKeyboard` automatically on focus.

```dart
OnscreenKeyboardTextField(
  controller: myController,
  enableOnscreenKeyboard: true,     // default: true
  onscreenKeyboardMode: 'symbols',  // optional: switch to this mode on focus
  decoration: InputDecoration(labelText: 'Name'),
)
```

#### Extra Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableOnscreenKeyboard` | `bool` | `true` | If `false`, acts as a regular `TextField` (uses OS keyboard) |
| `onscreenKeyboardMode` | `String?` | `null` | Mode name to activate when focused |

All standard `TextField` parameters are supported.

> **Note:** When enabled, `keyboardType` is forced to `TextInputType.none` to suppress the OS keyboard. Pass a different `keyboardType` only when `enableOnscreenKeyboard: false`.

---

### `OnscreenKeyboardTextFormField`

Drop-in replacement for Flutter's `TextFormField`.

```dart
final formFieldKey = GlobalKey<FormFieldState<String>>();

OnscreenKeyboardTextFormField(
  formFieldKey: formFieldKey,
  initialValue: 'Hello',
  validator: (value) => value!.isEmpty ? 'Required' : null,
  onChanged: (value) { ... },
  enableOnscreenKeyboard: true,
  onscreenKeyboardMode: 'alphabets',
)
```

#### Extra Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableOnscreenKeyboard` | `bool` | `true` | Same as `OnscreenKeyboardTextField` |
| `onscreenKeyboardMode` | `String?` | `null` | Mode name to activate when focused |
| `formFieldKey` | `Key?` | `null` | Exposes `FormFieldState` for external validation |
| `initialValue` | `String?` | `null` | Pre-populates text; **cannot** be combined with `controller` |

---

### `RawOnscreenKeyboard`

Stateless, low-level keyboard renderer. Use this when you want to embed a keyboard directly in your layout without the floating overlay or controller system.

```dart
RawOnscreenKeyboard(
  layout: MobileKeyboardLayout(),
  mode: 'alphabets',               // required: must match a mode name in layout
  onKeyDown: (key) { ... },
  onKeyUp: (key) { ... },
  aspectRatio: 4 / 3,             // optional override
  pressedActionKeys: {'shift'},    // visually highlight these action keys
  showSecondary: true,             // show secondary (shifted) character labels
)
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `layout` | `KeyboardLayout` | yes | The layout to render |
| `mode` | `String` | yes | Named mode from `layout.modes` |
| `onKeyDown` | `OnscreenKeyboardListener?` | no | Called when a key is pressed |
| `onKeyUp` | `OnscreenKeyboardListener?` | no | Called when a key is released |
| `aspectRatio` | `double?` | no | Overrides `layout.aspectRatio` |
| `pressedActionKeys` | `Set<String>?` | no | Action key names to show as "pressed" |
| `showSecondary` | `bool` | no | Show secondary/shifted characters |

---

## Controller

### `OnscreenKeyboardController`

Accessed via `OnscreenKeyboard.of(context)` or the `context.controller` extension.

```dart
final controller = OnscreenKeyboard.of(context);
```

#### Methods

| Method | Description |
|--------|-------------|
| `open()` | Shows the keyboard overlay |
| `close()` | Hides the keyboard and detaches the active text field |
| `setAlignment(Alignment alignment)` | Moves keyboard to an absolute alignment position |
| `moveToTop()` | Snaps keyboard to top-center |
| `moveToBottom()` | Snaps keyboard to bottom-center |
| `switchMode()` | Cycles to the next mode in the layout (wraps around) |
| `setModeNamed(String modeName)` | Jumps to a specific named mode |
| `attachTextField(OnscreenKeyboardFieldState field)` | Sets the active text field |
| `detachTextField([OnscreenKeyboardFieldState? field])` | Detaches the active text field |
| `addRawKeyDownListener(OnscreenKeyboardListener listener)` | Subscribes to raw key events |
| `removeRawKeyDownListener(OnscreenKeyboardListener listener)` | Unsubscribes from raw key events |

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `layout` | `KeyboardLayout` | The current active layout |

#### Raw Key Listener Example

```dart
controller.addRawKeyDownListener((key) {
  switch (key) {
    case TextKey(:final primary):
      print('Text key: $primary');
    case ActionKey(:final name):
      print('Action: $name');
  }
});
```

---

## Key Models

### `OnscreenKeyboardKey` (sealed)

Base sealed class for all keyboard keys.

#### `TextKey` factory

```dart
OnscreenKeyboardKey.text({
  required String primary,         // character to type (unshifted)
  String? secondary,               // shifted/alternate character
  Widget? child,                   // custom visual override
  int flex = 20,                   // proportional row width
  CallbackWithContext? onTap,
  CallbackWithContext? onTapDown,
  CallbackWithContext? onTapUp,
})
```

**`TextKey.getText({bool secondary = false})`** — returns the character to insert. If `secondary=true` and `secondary` is set, returns `secondary`; if `secondary=true` but no secondary defined, returns `primary.toUpperCase()`.

#### `ActionKey` factory

```dart
OnscreenKeyboardKey.action({
  required String name,            // ActionKeyType constant or custom string
  String? label,                   // display label (falls back to name)
  Widget? child,                   // custom visual override
  bool canHold = false,            // true = toggle (CapsLock), false = momentary (Shift)
  int flex = 20,
  CallbackWithContext? onTap,
  CallbackWithContext? onTapDown,
  CallbackWithContext? onTapUp,
})
```

---

### `ActionKeyType`

Abstract class with static `String` constants for standard action key names.

| Constant | Value | Behavior |
|----------|-------|---------|
| `ActionKeyType.backspace` | `'backspace'` | Deletes character before cursor (emoji-aware) |
| `ActionKeyType.tab` | `'tab'` | Inserts `\t` |
| `ActionKeyType.capslock` | `'capslock'` | Toggles shift lock (canHold = true) |
| `ActionKeyType.enter` | `'enter'` | Inserts newline (multiline) or unfocuses (single-line) |
| `ActionKeyType.shift` | `'shift'` | Momentary shift (auto-releases on key-up) |

---

## Layout System

### `KeyboardLayout`

Abstract base class for all layouts.

```dart
abstract class KeyboardLayout {
  double get aspectRatio;
  Map<String, KeyboardMode> get modes;

  // Factory for inline custom layouts:
  static KeyboardLayout custom({
    required double aspectRatio,
    required Map<String, KeyboardMode> modes,
  });
}
```

#### Built-in Layouts

| Class | Modes | Aspect Ratio |
|-------|-------|-------------|
| `MobileKeyboardLayout` | `alphabets`, `symbols`, `emojis` | `4/3` |
| `DesktopKeyboardLayout` | `default` | `5/2` |

---

### `KeyboardMode`

Represents a single mode (layer) in a layout.

```dart
KeyboardMode({
  required List<KeyboardRow> rows,
  double verticalSpacing = 0,
  OnscreenKeyboardThemeData Function(BuildContext)? theme,
})
```

| Parameter | Description |
|-----------|-------------|
| `rows` | List of key rows |
| `verticalSpacing` | Gap between rows in logical pixels |
| `theme` | Per-mode theme override (evaluated at build time) |

---

### `KeyboardRow`

A single row of keys.

```dart
KeyboardRow({
  required List<OnscreenKeyboardKey> keys,
  Widget? leading,    // widget rendered before the keys (e.g., for centering)
  Widget? trailing,   // widget rendered after the keys
})
```

Key widths are proportional: `key.flex / sum(all flex in row)`. Default flex is `20`.

---

## Theme

### `OnscreenKeyboardThemeData`

Controls the visual appearance of the keyboard.

```dart
OnscreenKeyboardThemeData({
  Color? color,                          // keyboard background
  BoxBorder? border,
  BorderRadiusGeometry? borderRadius,
  List<BoxShadow>? boxShadow,
  Gradient? gradient,
  EdgeInsetsGeometry? margin,            // outer margin
  EdgeInsetsGeometry? padding,           // inner padding around key rows
  TextKeyThemeData textKeyThemeData,
  ActionKeyThemeData actionKeyThemeData,
  Color? controlBarColor,
  bool? useSafeArea,                     // default: true
})
```

#### Named Factory Constructors

| Constructor | Description |
|-------------|-------------|
| `OnscreenKeyboardThemeData.gBoard({Color? primary})` | Google Gboard-inspired light theme with colored action keys |
| `OnscreenKeyboardThemeData.ios()` | iOS native keyboard appearance |

#### `copyWith`

All theme data classes support `copyWith` for partial updates.

---

### `KeyThemeData` (abstract)

Shared properties for both key types.

| Property | Type | Description |
|----------|------|-------------|
| `backgroundColor` | `Color?` | Key background |
| `foregroundColor` | `Color?` | Icon/label color |
| `margin` | `EdgeInsetsGeometry?` | Space around the key |
| `padding` | `EdgeInsetsGeometry?` | Space inside the key |
| `fitChild` | `bool` | Scale child to fit (default: `true`) |
| `borderRadius` | `BorderRadiusGeometry?` | |
| `border` | `BoxBorder?` | |
| `iconSize` | `double?` | Used when `child` is an `Icon` |
| `boxShadow` | `List<BoxShadow>?` | |
| `gradient` | `Gradient?` | Background gradient |

---

### `TextKeyThemeData` (extends `KeyThemeData`)

Adds `textStyle: TextStyle?` for the primary/secondary character label.

---

### `ActionKeyThemeData` (extends `KeyThemeData`)

Adds:

| Property | Type | Description |
|----------|------|-------------|
| `pressedBackgroundColor` | `Color?` | Background when the key is in the "pressed" (active) state |
| `pressedForegroundColor` | `Color?` | Foreground when pressed |

---

## Typedefs

| Typedef | Signature | Description |
|---------|-----------|-------------|
| `WidthGetter` | `double Function(BuildContext)` | Returns keyboard width at build time |
| `OnscreenKeyboardListener` | `void Function(OnscreenKeyboardKey)` | Raw key event callback |
| `ActionsBuilder` | `List<Widget> Function(BuildContext)` | Custom control-bar action widgets |
| `CallbackWithContext` | `void Function(BuildContext)` | Key-level tap callback |

---

## Utility Extensions (`src/utils/extensions.dart`)

| Extension | Property / Method | Description |
|-----------|-------------------|-------------|
| `BuildContext` | `.theme` | `OnscreenKeyboardThemeData` of nearest ancestor |
| `BuildContext` | `.controller` | `OnscreenKeyboardController` of nearest `OnscreenKeyboard` |
| `Color` | `.fade([double alpha = 0.5])` | Returns color with adjusted opacity |
| `TextEditingController` | `.start` | `selection.start` shorthand |
| `TextEditingController` | `.end` | `selection.end` shorthand |
