# Development Guide

Setup, conventions, and workflows for contributing to `flutter_onscreen_keyboard`.

---

## Prerequisites

| Tool | Version |
|------|---------|
| Flutter | stable (use [fvm](https://fvm.app) — `fvm use stable`) |
| Dart | ≥ 3.8.1 |
| Melos | latest (`dart pub global activate melos`) |

---

## Repository Structure

This is a **melos monorepo**.

```
flutter_onscreen_keyboard/          ← repo root
├── pubspec.yaml                    ← workspace pubspec (no lib)
├── melos.yaml                      ← melos config
├── docs/                           ← development documentation (this folder)
└── packages/
    └── flutter_onscreen_keyboard/  ← the actual package
        ├── lib/                    ← all source code
        ├── test/                   ← all tests
        └── example/                ← runnable example app
```

---

## Setup

```bash
# 1. Clone
git clone https://github.com/albinpk/flutter_onscreen_keyboard.git
cd flutter_onscreen_keyboard

# 2. Bootstrap all packages
melos bootstrap
# This runs `flutter pub get` in each package and creates symlinks.

# 3. Open in VS Code
code .
```

---

## Running the Example App

```bash
cd packages/flutter_onscreen_keyboard/example
flutter run           # picks connected device automatically
flutter run -d macos  # target macOS
flutter run -d chrome # target web
```

The example demonstrates:
- `OnscreenKeyboard.builder()` integration
- Manual `open()` / `close()` via buttons
- `addRawKeyDownListener` for logging keystrokes
- `OnscreenKeyboardTextField` (enabled + disabled + multiline)
- `OnscreenKeyboardTextFormField` with validation

---

## Running Tests

```bash
# From the package root:
cd packages/flutter_onscreen_keyboard
flutter test

# Run a specific test file:
flutter test test/src/onscreen_keyboard_test.dart

# Run with coverage:
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Files

| File | What it covers |
|------|---------------|
| `test/src/onscreen_keyboard_test.dart` | Core widget: open/close, layout, controller, text input, modes |
| `test/src/onscreen_keyboard_text_field_test.dart` | `OnscreenKeyboardTextField`: focus, mode switch, enable/disable |
| `test/src/onscreen_keyboard_text_form_field_test.dart` | `OnscreenKeyboardTextFormField`: validation, initialValue |
| `test/src/models/keys_test.dart` | `OnscreenKeyboardKey` model: toString |
| `test/src/theme/onscreen_keyboard_theme_data_test.dart` | Theme data: copyWith correctness |

---

## Linting & Formatting

```bash
# Analyze (strict very_good_analysis rules)
dart analyze packages/flutter_onscreen_keyboard

# Format
dart format packages/flutter_onscreen_keyboard/lib packages/flutter_onscreen_keyboard/test

# Both via melos:
melos run analyze
melos run format
```

The project uses `very_good_analysis ^10.0.0` — zero lint warnings (`dart analyze` must exit 0).

---

## Adding a Feature

### Checklist

- [ ] Read the [Architecture Guide](architecture.md) first
- [ ] Add the new code in `lib/src/`
- [ ] Export public symbols from `lib/flutter_onscreen_keyboard.dart`
- [ ] Write widget tests in `test/src/`
- [ ] Run `dart analyze` — zero warnings
- [ ] Run `flutter test` — all tests pass
- [ ] Update [CHANGELOG.md](../packages/flutter_onscreen_keyboard/CHANGELOG.md)

### Adding a New Layout

1. Create `lib/src/layouts/my_layout.dart`:

```dart
import 'package:flutter/widgets.dart';
import '../models/keys.dart';
import '../models/layout.dart';
import '../constants/action_key_type.dart';

class MyKeyboardLayout extends KeyboardLayout {
  const MyKeyboardLayout();

  @override
  double get aspectRatio => 4 / 3;

  @override
  Map<String, KeyboardMode> get modes => {
    'default': KeyboardMode(
      rows: [
        KeyboardRow(keys: [
          const OnscreenKeyboardKey.text(primary: 'a', secondary: 'A'),
          const OnscreenKeyboardKey.text(primary: 'b', secondary: 'B'),
          const OnscreenKeyboardKey.action(
            name: ActionKeyType.backspace,
            child: Icon(Icons.backspace_outlined),
            flex: 30,
          ),
        ]),
      ],
    ),
  };
}
```

2. Export from `lib/src/layouts/layouts.dart`:

```dart
export 'my_layout.dart';
```

3. Re-export from the public barrel `lib/flutter_onscreen_keyboard.dart`:

```dart
export 'src/layouts/layouts.dart';
```

### Adding a New Theme Preset

Add a named factory constructor to `OnscreenKeyboardThemeData` in `lib/src/theme/onscreen_keyboard_theme_data.dart`:

```dart
factory OnscreenKeyboardThemeData.dark() => OnscreenKeyboardThemeData(
  color: const Color(0xFF1C1C1E),
  borderRadius: BorderRadius.circular(12),
  textKeyThemeData: const TextKeyThemeData(
    backgroundColor: Color(0xFF2C2C2E),
    textStyle: TextStyle(color: Colors.white),
  ),
  actionKeyThemeData: const ActionKeyThemeData(
    backgroundColor: Color(0xFF48484A),
    pressedBackgroundColor: Color(0xFF0A84FF),
  ),
);
```

### Adding a New Action Key Handler

To handle a custom action key in the controller (e.g., a `'paste'` key):

1. Add the constant to `ActionKeyType` if it's a standard action.
2. Add the case in `_OnscreenKeyboardState._handleKeyDown`:

```dart
case ActionKey(name: ActionKeyType.paste):
  final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
  _insertText(clipboard?.text ?? '');
```

---

## Writing Tests

Use the standard test scaffold:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_onscreen_keyboard/flutter_onscreen_keyboard.dart';

void main() {
  group('MyFeature', () {
    testWidgets('description of what is being tested', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          builder: OnscreenKeyboard.builder(
            layout: const DesktopKeyboardLayout(),
          ),
          home: Scaffold(
            body: OnscreenKeyboardTextField(
              controller: controller,
            ),
          ),
        ),
      );

      // Focus the text field to open keyboard
      await tester.tap(find.byType(OnscreenKeyboardTextField));
      await tester.pump();

      // Tap a key
      await tester.tap(find.text('a'));
      await tester.pump();

      expect(controller.text, equals('a'));
    });
  });
}
```

### Accessing the Controller in Tests

```dart
final keyboardController = OnscreenKeyboard.of(
  tester.element(find.byType(OnscreenKeyboard)),
);
```

---

## Release Process

1. Update version in `packages/flutter_onscreen_keyboard/pubspec.yaml`
2. Add entry to `packages/flutter_onscreen_keyboard/CHANGELOG.md`
3. Run full test suite: `melos run test`
4. Run analysis: `melos run analyze`
5. Publish dry run: `dart pub publish --dry-run`
6. Publish: `dart pub publish`
7. Tag the release: `git tag v<version> && git push --tags`

---

## Common Pitfalls

| Pitfall | Fix |
|---------|-----|
| `setState` called during build | Use `WidgetsBinding.instance.addPostFrameCallback((_) => setState(...))` (see `_safeSetState` pattern) |
| OS keyboard appears on `OnscreenKeyboardTextField` | Missing `keyboardType: TextInputType.none` — ensure `enableOnscreenKeyboard: true` |
| Keyboard closes when typing | Ensure both the keyboard overlay and text field are wrapped in `TextFieldTapRegion` |
| Multi-codepoint emoji deleted incorrectly | Use `String.characters` for grapheme-cluster-aware slicing |
| Lint error: `avoid_print` | Use `debugPrint` or remove logging before committing |
| `part` file not compiling | Ensure `part of` directive points to the correct library host file |
