import 'package:bdd_widget_test/data_table.dart' as bdd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: I see result
Future<void> iSeeResult(WidgetTester tester, bdd.DataTable dataTable) async {
  final counter = dataTable.asMaps().first['counter'] as String;
  final color = _colorFromName(dataTable.asMaps().first['color'] as String);

  expect(find.text(counter), findsOneWidget);
  expect(
    (tester.firstWidget(find.byType(Scaffold)) as Scaffold).backgroundColor,
    color,
  );
}

Color _colorFromName(String colorName) {
  switch (colorName) {
    case 'blue':
      return Colors.blue;
    case 'green':
      return Colors.green;
    case 'yellow':
      return Colors.yellow;
    default:
      throw UnimplementedError('Unknown color: $colorName');
  }
}
