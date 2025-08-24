import 'package:bdd_widget_test/data_table.dart';
import 'package:test/test.dart';

void main() {
  test('asLists', () {
    final data = [
      ['Country', 'City'],
      ['England', 'London'],
      ['England', 'Manchester'],
    ];
    final dataTable = DataTable(data);

    final result = dataTable.asLists();

    expect(result, data);
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
