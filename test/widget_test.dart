import 'package:flutter_test/flutter_test.dart';
import 'package:paedia/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('EmptyState shows title and message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            title: 'No group assigned',
            message: 'Contact your leader.',
          ),
        ),
      ),
    );

    expect(find.text('No group assigned'), findsOneWidget);
    expect(find.text('Contact your leader.'), findsOneWidget);
  });
}
