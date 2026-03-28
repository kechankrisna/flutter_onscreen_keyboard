import 'package:flutter/material.dart';
import 'package:flutter_onscreen_keyboard/src/widgets/suggestion_bar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SuggestionBar', () {
    Widget buildBar({
      List<String> suggestions = const [],
      void Function(String)? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SuggestionBar(
            suggestions: suggestions,
            onSuggestionTap: onTap ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('is not visible when suggestions list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildBar());
      // The bar renders nothing visible when empty (SizedBox.shrink).
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('renders chips for each suggestion', (tester) async {
      await tester.pumpWidget(
        buildBar(suggestions: ['hello', 'world']),
      );
      expect(find.text('hello'), findsOneWidget);
      expect(find.text('world'), findsOneWidget);
    });

    testWidgets('tapping a suggestion calls onSuggestionTap', (tester) async {
      String? tapped;
      await tester.pumpWidget(
        buildBar(
          suggestions: ['flutter'],
          onTap: (word) => tapped = word,
        ),
      );
      await tester.tap(find.text('flutter'));
      expect(tapped, 'flutter');
    });

    testWidgets('has a fixed height of 40 when non-empty', (tester) async {
      await tester.pumpWidget(
        buildBar(suggestions: ['test']),
      );
      final sizedBox = tester.widget<SizedBox>(
        find
            .descendant(
              of: find.byType(SuggestionBar),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(sizedBox.height, 40);
    });
  });
}
