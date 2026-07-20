import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteai/widgets/summary_card.dart';

void main() {
  testWidgets('SummaryCard displays title and content correctly', (WidgetTester tester) async {
    const testTitle = 'Test Title';
    const testContent = 'Test Content';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SummaryCard(
            title: testTitle,
            content: testContent,
          ),
        ),
      ),
    );

    // Verify if title and content are displayed
    expect(find.text(testTitle), findsOneWidget);
    expect(find.text(testContent), findsOneWidget);
    
    // Verify if Copy button is displayed
    expect(find.text('คัดลอก'), findsOneWidget);
    
    // Export button should not be displayed if onExport is null
    expect(find.text('ส่งออก'), findsNothing);
  });

  testWidgets('SummaryCard displays Export button if onExport is provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SummaryCard(
            title: 'Test',
            content: 'Test',
            onExport: () {},
          ),
        ),
      ),
    );

    expect(find.text('ส่งออก'), findsOneWidget);
  });
}
