// TEMPORARY probe: prints Material-3 defaults for the app's exact theme.
// Used to confirm visual-identity facts; deleted after the check.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('probe M3 defaults', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: const Color(0xFF00897B)),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(title: const Text('X')),
          body: Builder(
            builder: (BuildContext context) {
              final TextTheme tt = Theme.of(context).textTheme;
              debugPrint('PROBE bodyMedium=${tt.bodyMedium}');
              debugPrint(
                  'PROBE onSurface=${Theme.of(context).colorScheme.onSurface}');
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    final RenderParagraph p =
        tester.renderObject<RenderParagraph>(find.text('X'));
    debugPrint('PROBE appBarTitleEffective=${p.text.style}');
  });
}
