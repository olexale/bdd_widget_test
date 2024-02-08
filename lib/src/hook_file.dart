import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/util/constants.dart';
import 'package:path/path.dart' as p;

class HookFile {
  const HookFile._create({
    required this.featureDir,
    required this.package,
    required this.fileName,
    required this.import,
  });

  factory HookFile.create({
    required String featureDir,
    required String package,
    required GeneratorOptions generatorOptions,
  }) {
    const fileName = '$hookFileName.dart';
    if (generatorOptions.hookFolderName.startsWith('./') ||
        generatorOptions.hookFolderName.startsWith('../')) {
      return HookFile._create(
        featureDir: featureDir,
        package: package,
        fileName: p.join(featureDir, generatorOptions.hookFolderName, fileName),
        import: p
            .join(generatorOptions.hookFolderName, fileName)
            .replaceAll(r'\', '/'),
      );
    }

    return HookFile._create(
      featureDir: featureDir,
      package: package,
      fileName:
          p.join(testFolderName, generatorOptions.hookFolderName, fileName),
      import: p.join(
        p.relative(testFolderName, from: featureDir),
        generatorOptions.hookFolderName,
        fileName,
      ),
    );
  }

  final String featureDir;
  final String fileName;
  final String package;
  final String import;
}

String createHooksFileContent(bool addWorld) {
  return '''
import 'dart:async';
${addWorld ? "import 'package:bdd_widget_test/world.dart';\n" : ''}
abstract class Hooks {
  const Hooks._();
  
  static FutureOr<void> $setUpHookName(
    String title,${addWorld ? "\n    $worldParameter," : ""} [
    List<String>? tags,
    ]) {
    // Add logic for $setUpHookName
  }
  
  static FutureOr<void> $setUpAllHookName() {
    // Add logic for $setUpAllHookName
  }
  
  static FutureOr<void> $tearDownHookName(
    String title,
    bool success,${addWorld ? "\n    $worldParameter," : ""} [
    List<String>? tags,
  ]) {
    // Add logic for $tearDownHookName
  }
  
  static FutureOr<void> $tearDownAllHookName() {
    // Add logic for $tearDownAllHookName
  }
}
''';
}
