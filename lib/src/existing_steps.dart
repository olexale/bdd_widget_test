import 'package:bdd_widget_test/src/util/constants.dart';
import 'package:bdd_widget_test/src/util/fs.dart';
import 'package:path/path.dart' as p;

/// key - step filename, value - path for import (ex: {'i_have_a_step.dart': 'step/common'})
Map<String, String> getExistingStepSubfolders(
  String featureDir,
  String stepFolderName,
) {
  final stepFolder = p.join(
    stepFolderName.startsWith('./') || stepFolderName.startsWith('../')
        ? featureDir
        : testFolderName,
    stepFolderName,
  );

  final steps = fs.directory(stepFolder);
  if (!steps.existsSync()) {
    return {};
  }
  return steps.listSync(recursive: true).asMap().map(
        (_, step) => MapEntry<String, String>(
          p.basename(step.path),
          p.dirname(
            p.relative(
              step.path,
              from: featureDir,
            ),
          ),
        ),
      );
}
