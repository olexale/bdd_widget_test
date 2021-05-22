import 'dart:io';

import 'package:path/path.dart' as p;

Map<String, String> getExistingStepSubfolders(
    String featureDir, String stepFolderName) {
  final stepFolder = p.join(featureDir, stepFolderName);
  final steps = Directory(stepFolder);
  if (!steps.existsSync()) {
    return {};
  }
  return steps.listSync(recursive: true).asMap().map(
        (key, value) => MapEntry<String, String>(
          p.basename(value.path),
          _getStepFolder(
            value.uri.pathSegments,
            stepFolderName,
          ),
        ),
      );
}

String _getStepFolder(List<String> pathSegments, String stepFolderName) {
  final stepFolderIndex = pathSegments.indexOf(stepFolderName);
  final stepFolder =
      pathSegments.getRange(stepFolderIndex, pathSegments.length - 1);
  return p.joinAll(stepFolder);
}
