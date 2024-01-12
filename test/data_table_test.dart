import 'package:bdd_widget_test/src/data_table.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('asLists with default ignoreFirstRow', () {
    final data = [
      ['Country', 'City'],
      ['England', 'London'],
      ['England', 'Manchester'],
    ];
    final dataTable = DataTable(data);

    final result = dataTable.asLists();

    expect(result, data);
  });

  test('asLists with ignoreFirstRow as true', () {
    final data = [
      ['Country', 'City'],
      ['England', 'London'],
      ['England', 'Manchester'],
    ];
    final dataTable = DataTable(data);

    final result = dataTable.asLists(ignoreFirstRow: true);

    expect(result, data.skip(1));
  });
}
