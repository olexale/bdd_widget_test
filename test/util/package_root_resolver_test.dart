import 'dart:io';

import 'package:bdd_widget_test/src/util/package_root_resolver.dart';
import 'package:test/test.dart';

void main() {
  // Real workspace resolution is covered end-to-end by workspace_e2e_test.dart,
  // which injects a `preloadedPackageConfig` and so exercises both the cached
  // early-return in `resolvePackageRoot` (repeated calls for the same package
  // name) and `_resolvePackageUri` for the happy `file:` case. This file only
  // covers the defensive fallback when the package config can't be parsed.
  //
  // NOT exercised by the suite (and not required by the coverage gate):
  //  - the real `findPackageConfig(Directory.current)` discovery, which would
  //    require a fixture workspace on the real filesystem;
  //  - `_resolvePackageUri` returning null for a non-`file` scheme root (the VM
  //    coverage instrumentation does not emit that branch as a coverable line).
  test('returns null when package_config.json cannot be parsed', () async {
    final tempDir = Directory.systemTemp.createTempSync('bdd_pkg_root_');
    final originalCwd = Directory.current;
    addTearDown(() {
      Directory.current = originalCwd;
      tempDir.deleteSync(recursive: true);
      packageRootCache.clear();
      preloadedPackageConfig = null;
    });

    // A malformed config makes findPackageConfig throw, exercising the catch.
    File('${tempDir.path}/.dart_tool/package_config.json')
      ..createSync(recursive: true)
      ..writeAsStringSync('{ not valid json');

    Directory.current = tempDir;
    packageRootCache.clear();
    preloadedPackageConfig = null;

    expect(await resolvePackageRoot('anything'), isNull);
  });
}
