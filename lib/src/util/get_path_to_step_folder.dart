import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/util/fs.dart';
import 'package:path/path.dart' as p;

const _testFolderName = 'test';

/// Returns the folder where step folder is located.
///
/// When [packageRoot] is non-null it is the absolute owning-package root (never
/// an empty string, see `resolvePackageRoot`), and the returned path is
/// resolved relative to it — useful when running inside a pub workspace.
/// When [packageRoot] is `null`, falls back to the original behaviour
/// using `fs.currentDirectory.path`.
String getPathToStepFolder(GeneratorOptions options, {String? packageRoot}) {
  if (options.relativeToTestFolder) {
    if (packageRoot != null) {
      return p.join(packageRoot, _testFolderName);
    }
    return _testFolderName;
  }
  if (packageRoot != null) {
    return packageRoot;
  }
  return fs.currentDirectory.path;
}
