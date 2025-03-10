import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/util/constants.dart';
import 'package:bdd_widget_test/src/util/get_test_folder_name.dart';
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
      fileName: p.join(
        getPathToStepFolder(generatorOptions),
        generatorOptions.hookFolderName,
        fileName,
      ),
      import: p
          .join(
            p.relative(getPathToStepFolder(generatorOptions), from: featureDir),
            generatorOptions.hookFolderName,
            fileName,
          )
          .replaceAll(r'\', '/'),
    );
  }

  final String featureDir;
  final String fileName;
  final String package;
  final String import;
}

const String hookFileContent = '''
import 'dart:async';

abstract class Hooks {
  const Hooks._();
  
  static FutureOr<void> beforeEach(String title, [List<String>? tags]) {
    // Add logic for beforeEach
  }
  
  static FutureOr<void> beforeAll() {
    // Add logic for beforeAll
  }
  
  static FutureOr<void> afterEach(
    String title,
    bool success, [
    List<String>? tags,
  ]) {
    // Add logic for afterEach
  }
  
  static FutureOr<void> afterAll() {
    // Add logic for afterAll
  }
}
''';
