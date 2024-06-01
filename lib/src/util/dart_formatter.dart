import 'package:dart_style/dart_style.dart';

final _formatter = DartFormatter();

String formatDartCode(String input) => _formatter.format(input);
