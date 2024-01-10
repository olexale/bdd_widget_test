import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/util/constants.dart';
import 'package:path/path.dart' as p;

class HookFile {
  HookFile._create({
    required this.featureDir,
    required this.package,
    required this.fileName,
    required this.import,
  });

  static HookFile create({
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

const String hookFileContent = '''
class Hooks {
  static Function beforeEach = (String title, [List<String>? tags]) {
    // Add logic for beforeEach
  };
  static Function beforeAll = () {
    // Add logic for beforeAll
  };
  static Function afterEach = (
    String title,
    bool success, [
    List<String>? tags,
  ]) {
    // Add logic for afterEach
  };
  static Function afterAll = () {
    // Add logic for afterAll
  };
}
''';
