import 'package:collection/collection.dart';

class DataTable {
  const DataTable(this._data);

  final List<List<dynamic>> _data;

  List<List<dynamic>> asLists() => _data;

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
