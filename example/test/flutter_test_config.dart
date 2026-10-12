import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Runs before every test under `test/`, and makes golden images show real
/// text and icons.
///
/// By default Flutter tests draw every glyph as a box and load no icon font,
/// so that goldens look the same on every operating system. This file loads
/// the Roboto and Material Icons fonts that ship with the Flutter SDK instead,
/// and hides the debug banner, which a release build doesn't show either. The
/// price is that goldens now depend on the OS, which is why the example's
/// goldens are generated and compared on Linux.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  WidgetsApp.debugAllowBannerOverride = false;
  await _loadMaterialFonts();
  await testMain();
}

Future<void> _loadMaterialFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) {
    throw StateError(
        'FLUTTER_ROOT is not set, run the tests with flutter test');
  }
  final fonts = Directory('$flutterRoot/bin/cache/artifacts/material_fonts');
  final roboto = FontLoader('Roboto');
  final materialIcons = FontLoader('MaterialIcons');
  for (final file in fonts.listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last.toLowerCase();
    final font = Future.value(ByteData.sublistView(file.readAsBytesSync()));
    if (name.startsWith('roboto-')) roboto.addFont(font);
    if (name == 'materialicons-regular.otf') materialIcons.addFont(font);
  }
  await Future.wait([roboto.load(), materialIcons.load()]);
}
