import 'package:collection/collection.dart';

class DataTable {
  const DataTable(this._data);

  final List<List<dynamic>> _data;

  List<List<dynamic>> asLists({bool ignoreFirstRow = false}) =>
      _data.sublist(ignoreFirstRow ? 1 : 0, _data.length);

  List<Map<dynamic, dynamic>> asMaps() {
    final result = <Map<dynamic, dynamic>>[];
    final headers = _data.first;
    _data.skip(1).forEach((row) {
      final map = <dynamic, dynamic>{};
      headers.forEachIndexed((index, header) {
        map[header] = row[index];
      });
      result.add(map);
    });
    return result;
  }
}
