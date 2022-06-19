import 'package:bdd_widget_test/src/util/fs.dart';
import 'package:path/path.dart' as p;

/// key - step filename, value - path for import (ex: {'i_have_a_step.dart': 'step/common'})
Map<String, String> getExistingStepSubfolders(
  String featureDir,
  String stepFolderName,
) {
  final stepFolder = p.join(featureDir, stepFolderName);
  final steps = fs.directory(stepFolder);
  if (!steps.existsSync()) {
    return {};
  }
  return steps.listSync(recursive: true).asMap().map(
        (_, step) => MapEntry<String, String>(
          p.basename(step.path),
          _getStepSubfolders(
            steps.uri.pathSegments.length,
            step.uri.pathSegments,
            stepFolderName,
          ),
        ),
      );
}

String _getStepSubfolders(
  int stepFolderPathSegmentsLength,
  List<String> currentStepPath,
  String stepFolderName,
) {
  final pathDiff = currentStepPath.getRange(
      stepFolderPathSegmentsLength - 1, currentStepPath.length - 1);
  return p.joinAll([stepFolderName, ...pathDiff]);
}
