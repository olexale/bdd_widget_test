import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;

/// Resolved package root per package name. Memoized to avoid repeated file
/// reads across build steps.
@visibleForTesting
final packageRootCache = <String, String?>{};

/// The workspace package config. Discovered lazily on first use and memoized;
/// tests may assign a fake config (and clear [packageRootCache]) to simulate a
/// pub workspace.
@visibleForTesting
PackageConfig? preloadedPackageConfig;

/// Resolves the absolute root directory path of the specified [packageName]
/// from the workspace's `.dart_tool/package_config.json`.
///
/// Returns `null` if the package is not found in the workspace or if
/// `package_config.json` cannot be read. The result is always either `null`
/// or a non-empty path, so callers only ever need a `!= null` check (never an
/// additional `.isNotEmpty` guard).
///
/// Results are cached per package name to avoid repeated file reads.
///
/// NOTE: package config discovery deliberately uses `dart:io`
/// ([Directory.current] + [findPackageConfig]) rather than the swappable `fs`
/// seam used by the rest of the generator. This couples resolution to the real
/// filesystem, so tests cannot exercise it through a `MemoryFileSystem`; they
/// inject [preloadedPackageConfig] (and clear [packageRootCache]) instead.
Future<String?> resolvePackageRoot(String packageName) async {
  if (packageRootCache.containsKey(packageName)) {
    return packageRootCache[packageName];
  }

  try {
    preloadedPackageConfig ??= await findPackageConfig(Directory.current);
  } on Exception {
    preloadedPackageConfig = null;
  }

  String? result;

  final config = preloadedPackageConfig;
  if (config != null) {
    final package = config[packageName];
    if (package != null) {
      result = _resolvePackageUri(package.root);
    }
  }

  packageRootCache[packageName] = result;
  return result;
}

String? _resolvePackageUri(Uri uri) {
  if (uri.scheme != 'file') {
    return null;
  }
  final path = p.normalize(uri.toFilePath());
  // Collapse a degenerate empty result to null so downstream code can rely on
  // a single `!= null` convention (see [resolvePackageRoot]).
  return path.isEmpty ? null : path;
}

extension PackageRootPath on String {
  /// Anchors this path under [packageRoot] for workspace builds, or returns it
  /// unchanged when [packageRoot] is `null` (a non-workspace build).
  String underPackageRoot(String? packageRoot) =>
      packageRoot != null ? p.join(packageRoot, this) : this;
}
