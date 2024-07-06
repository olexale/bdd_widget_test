import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/util/fs.dart';

const _testFolderName = 'test';

/// Returns the folder where step folder is located.
String getPathToStepFolder(GeneratorOptions options) {
  if (options.stepFolderIsUnderTestFolder) {
    return _testFolderName;
  }
  return fs.currentDirectory.path;
}
