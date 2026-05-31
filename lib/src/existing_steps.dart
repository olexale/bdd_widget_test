import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/util/fs.dart';
import 'package:bdd_widget_test/src/util/get_path_to_step_folder.dart';
import 'package:bdd_widget_test/src/util/package_root_resolver.dart';
import 'package:path/path.dart' as p;

/// key - step filename, value - path for import (ex: {'i_have_a_step.dart': 'step/common'})
///
/// When [packageRoot] is provided, the step folder is resolved relative to
/// that root instead of using the filesystem current directory.
Map<String, String> getExistingStepSubfolders(
  String featureDir,
  GeneratorOptions options, [
  String? packageRoot,
]) {
  final stepFolderName = options.stepFolder;
  final absFeatureDir = featureDir.underPackageRoot(packageRoot);
  final basePath =
      stepFolderName.startsWith('./') || stepFolderName.startsWith('../')
          ? absFeatureDir
          : getPathToStepFolder(options, packageRoot: packageRoot);

  final stepFolder = p.join(basePath, stepFolderName);

  final steps = fs.directory(stepFolder);
  if (!steps.existsSync()) {
    return {};
  }
  return steps
      .listSync(recursive: true)
      .asMap()
      .map(
        (_, step) => MapEntry<String, String>(
          p.basename(step.path),
          p.dirname(
            p.relative(
              step.path,
              from: absFeatureDir,
            ),
          ),
        ),
      );
}
