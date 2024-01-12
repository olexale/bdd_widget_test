class DataTable {
  const DataTable(this._data);

  final List<List<dynamic>> _data;

  List<List<dynamic>> asLists({bool ignoreFirstRow = false}) =>
      _data.sublist(ignoreFirstRow ? 1 : 0, _data.length);
}
