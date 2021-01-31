import 'dart:io';

import 'package:bdd_widget_test/src/constants.dart';
import 'package:path/path.dart' as p;

Map<String, String> getExistingStepSubfolders(String featureDir) {
  final stepFolder = p.join(featureDir, stepFolderName);
  final steps = Directory(stepFolder);
  if (!steps.existsSync()) {
    return {};
  }
  return steps.listSync(recursive: true).asMap().map(
        (key, value) => MapEntry<String, String>(
          p.basename(value.path),
          _getStepFolder(value.uri.pathSegments),
        ),
      );
}

String _getStepFolder(List<String> pathSegments) {
  final stepFolderIndex = pathSegments.indexOf(stepFolderName);
  final stepFolder =
      pathSegments.getRange(stepFolderIndex, pathSegments.length - 1);
  return p.joinAll(stepFolder);
}
