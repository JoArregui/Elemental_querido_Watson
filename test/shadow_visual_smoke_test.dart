import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elemental_querido_watson/features/book/presentation/widgets/map_exclusive_visual_widget.dart';

void main() {
  testWidgets('shadow_match builds cat reference + 4 shadows',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MapExclusiveVisualWidget(visualKind: 'shadow_match'),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Sombra del Gato'), findsOneWidget);
    // 4 numbered badges
    for (var n = 1; n <= 4; n++) {
      expect(find.text('$n'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
