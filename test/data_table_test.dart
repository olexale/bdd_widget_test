import 'package:bdd_widget_test/data_table.dart';
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

  test('asMaps', () {
    final data = [
      ['id', 'isValid'],
      [1, false],
      [2, true],
    ];
    final expected = [
      {'id': 1, 'isValid': false},
      {'id': 2, 'isValid': true},
    ];
    final dataTable = DataTable(data);

    final result = dataTable.asMaps();

    expect(result, expected);
  });
}
