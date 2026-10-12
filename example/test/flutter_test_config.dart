import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs before every test under `test/`, and makes golden images show real
/// text and icons.
///
/// By default Flutter tests draw every glyph as a box and load no icon font,
/// so that goldens look the same on every operating system. This file loads
/// the Roboto and Material Icons fonts that ship with the Flutter SDK instead,
/// and hides the debug banner, which a release build doesn't show either. The
/// price is that goldens now depend on the OS, so every OS keeps its own set:
/// `goldens/initial_counter.png` is stored as
/// `goldens/macos/initial_counter.png`, `goldens/linux/initial_counter.png`
/// and so on. Run `flutter test --update-goldens` on an OS to create its set.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  WidgetsApp.debugAllowBannerOverride = false;
  await _loadMaterialFonts();
  goldenFileComparator = _PerOsComparator(goldenFileComparator);
  await testMain();
}

Future<void> _loadMaterialFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) {
    throw StateError(
      'FLUTTER_ROOT is not set, run the tests with flutter test',
    );
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

/// Stores every golden in a subfolder named after the OS running the test.
///
/// `flutter test` sets up a comparator for each test file before calling
/// [testExecutable], so this one only rewrites the path and leaves the rest to
/// it. The path is rewritten once, in [getTestUri]: `matchesGoldenFile` passes
/// its result to [compare] and [update], and shows it in failure messages.
class _PerOsComparator extends GoldenFileComparator {
  _PerOsComparator(this._delegate);

  final GoldenFileComparator _delegate;

  @override
  Uri getTestUri(Uri key, int? version) {
    final golden = _delegate.getTestUri(key, version);
    return golden.replace(
      pathSegments: [
        ...golden.pathSegments.take(golden.pathSegments.length - 1),
        Platform.operatingSystem,
        golden.pathSegments.last,
      ],
    );
  }

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) =>
      _delegate.compare(imageBytes, golden);

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) =>
      _delegate.update(golden, imageBytes);
}
