import 'package:characters/characters.dart';

const int _DIGIT = 1;
const int _LOWER = 2;
const int _UNDERSCORE = 4;
const int _UPPER = 8;
const int _ALPHA = _LOWER | _UPPER;
const int _ALPHA_NUM = _ALPHA | _DIGIT;
const int _ASCII_END = 127; // _ascii list length

/// "The app is running" => "the app is running"
/// "theAppIsRunning" => "the_app_is_running"
String underscore(String input) {
  final sb = StringBuffer();
  var separate = false;
  for (final s in Characters(input)) {
    final type = _getAsciiType(s.runes);

    if (separate && type & _UPPER != 0) {
      sb.write('_');
      sb.write(s.toLowerCase());
      separate = true;
    } else {
      sb.write(s.toLowerCase());
      separate = type & _ALPHA_NUM != 0 || type & _UNDERSCORE != 0 && separate;
    }
  }

  return sb.toString();
}

/// "The_app_is_running" => "theAppIsRunning"
String camelize(String input) {
  final string = input.toLowerCase();
  final sb = StringBuffer();

  var capitalize = true;
  var isBeginning = true;
  var remove = false;

  for (final s in Characters(string)) {
    final type = _getAsciiType(s.runes);

    if (capitalize && type & _ALPHA != 0) {
      sb.write(isBeginning ? s : s.toUpperCase());

      capitalize = false;
      remove = true;
      isBeginning = false;
    } else {
      if (type & _UNDERSCORE != 0) {
        if (!remove) {
          sb.write(s);
          remove = true;
        }

        capitalize = true;
      } else {
        if (type & _ALPHA_NUM != 0) {
          capitalize = false;
          remove = true;
        } else {
          capitalize = true;
          remove = false;
          isBeginning = true;
        }

        sb.write(s);
      }
    }
  }

  return sb.toString();
}

int _getAsciiType(Runes runes) {
  if (runes.length == 1) {
    final c = runes.first;
    if (c <= _ASCII_END) {
      return _ascii[c];
    }
  }
  return 0;
}

final List<int> _ascii = <int>[
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  8,
  0,
  0,
  0,
  0,
  4,
  0,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  0,
  0,
  0,
  0,
  0,
];
