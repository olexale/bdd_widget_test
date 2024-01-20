import 'package:collection/collection.dart';

class DataTable {
  const DataTable(this._data);

  final List<List<dynamic>> _data;

  List<List<dynamic>> asLists({bool ignoreFirstRow = false}) =>
      _data.sublist(ignoreFirstRow ? 1 : 0);

  List<Map<dynamic, dynamic>> asMaps() {
    final headers = _data.first;
    return _data.skip(1).map((row) {
      final map = <dynamic, dynamic>{};
      headers.forEachIndexed((index, header) {
        map[header] = row[index];
      });
      return map;
    }).toList();
  }
}
