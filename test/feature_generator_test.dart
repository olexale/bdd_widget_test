import 'package:bdd_widget_test/bdd_widget_test.dart';
import 'package:bdd_widget_test/src/util/fs.dart';
import 'package:bdd_widget_test/src/util/isolate_helper.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'util/testing_data.dart';

void main() {
  setUp(() {
    resolvePackageUriFactory = (uri) {
      if (uri.path == 'non-existing-file') {
        return Future.value();
      }
      return Future.value(uri);
    };
    fsInstance = MemoryFileSystem.test();
  });

  test('no customization', () async {
    const expected = '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
        '// ignore_for_file: type=lint, type=warning\n'
        '\n'
        "import 'package:flutter/material.dart';\n"
        "import 'package:flutter_test/flutter_test.dart';\n"
        '\n'
        "import './step/the_app_is_running.dart';\n"
        '\n'
        'void main() {\n'
        "  group('''Testing feature''', () {\n"
        "    testWidgets('''Testing scenario''', (tester) async {\n"
        '      await theAppIsRunning(tester);\n'
        '    });\n'
        '  });\n'
        '}\n';
    const scenario = 'simple';
    final content = await generate(scenario);
    expect(content, expected);
  });

  test('existing step should not regenerate', () async {
    const scenario = 'existing_step';
    final dummyStepPath = p.join(
      getStepFolderName(scenario),
      'the_app_is_running.dart',
    );
    const expectedFileContent = '// existing step';
    fs.file(dummyStepPath)
      ..createSync(recursive: true)
      ..writeAsStringSync(expectedFileContent);

    await generate(scenario);

    final content = fs.file(dummyStepPath).readAsStringSync();
    expect(content, expectedFileContent);
  });

  test('existing step outside test folder should be found', () async {
    const bddOptions = '''
stepFolderName: my_steps
relativeToTestFolder: false
''';
    fs.file('bdd_options.yaml')
      ..createSync()
      ..writeAsStringSync(bddOptions);

    const scenario = 'existing_step_outside_test_folder';
    final dummyStepPath = p.join(
      fs.currentDirectory.path,
      'my_steps',
      'the_app_is_running.dart',
    );
    fs.file(dummyStepPath)
      ..createSync(recursive: true)
      ..writeAsStringSync('dummy');

    // note: the import is so weird because p.relative() can not
    // find intersection between two paths (however, somehow it works)
    // not a problem in the real world
    const expected = '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
        '// ignore_for_file: type=lint, type=warning\n'
        '\n'
        "import 'package:flutter/material.dart';\n"
        "import 'package:flutter_test/flutter_test.dart';\n"
        '\n'
        "import './../../../../../../../../my_steps/the_app_is_running.dart';\n"
        '\n'
        'void main() {\n'
        "  group('''Testing feature''', () {\n"
        "    testWidgets('''Testing scenario''', (tester) async {\n"
        '      await theAppIsRunning(tester);\n'
        '    });\n'
        '  });\n'
        '}\n';

    final content = await generate(scenario);

    expect(content, expected);
  });

  test('custom bdd_options', () async {
    const bddOptions = '''
stepFolderName: ./scenarios
testMethodName: customName
addHooks: true
hookFolderName: hooksFolder
''';
    fs.file('bdd_options.yaml')
      ..createSync()
      ..writeAsStringSync(bddOptions);

    const expected = '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
        '// ignore_for_file: type=lint, type=warning\n'
        '\n'
        "import 'package:flutter/material.dart';\n"
        "import 'package:flutter_test/flutter_test.dart';\n"
        '\n'
        "import '../../hooksFolder/hooks.dart';\n"
        "import './scenarios/the_app_is_running.dart';\n"
        '\n'
        'void main() {\n'
        '  setUpAll(() async {\n'
        '    await Hooks.beforeAll();\n'
        '  });\n'
        '  tearDownAll(() async {\n'
        '    await Hooks.afterAll();\n'
        '  });\n'
        '\n'
        "  group('''Testing feature''', () {\n"
        '    Future<void> beforeEach(String title, [List<String>? tags]) async {\n'
        '      await Hooks.beforeEach(title, tags);\n'
        '    }\n'
        '\n'
        '    Future<void> afterEach(String title, bool success,\n'
        '        [List<String>? tags]) async {\n'
        '      await Hooks.afterEach(title, success, tags);\n'
        '    }\n'
        '\n'
        "    customName('''Testing scenario''', (tester) async {\n"
        '      var success = true;\n'
        '      try {\n'
        "        await beforeEach('''Testing scenario''');\n"
        '        await theAppIsRunning(tester);\n'
        '      } catch (_) {\n'
        '        success = false;\n'
        '        rethrow;\n'
        '      } finally {\n'
        '        await afterEach(\n'
        "          '''Testing scenario''',\n"
        '          success,\n'
        '        );\n'
        '      }\n'
        '    });\n'
        '  });\n'
        '}\n';

    const scenario = 'options';
    final content = await generate(scenario);
    expect(content, expected);
  });

  test('non-valid include', () async {
    const bddOptions = 'include: non-existing-file';
    fs.file('bdd_options.yaml')
      ..createSync()
      ..writeAsStringSync(bddOptions);

    const scenario = 'options';
    expect(() => generate(scenario), throwsException);
  });

  test('merge options', () async {
    const includeYaml = 'bdd_options.yaml';
    const externalYaml = 'external_options.yaml';

    fs.file(includeYaml)
      ..createSync()
      ..writeAsStringSync('''
include: $externalYaml
testMethodName: customName
''');

    fs.file(externalYaml)
      ..createSync()
      ..writeAsStringSync('''
stepFolderName: ./scenarios
''');

    const expected = '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
        '// ignore_for_file: type=lint, type=warning\n'
        '\n'
        "import 'package:flutter/material.dart';\n"
        "import 'package:flutter_test/flutter_test.dart';\n"
        '\n'
        "import './scenarios/the_app_is_running.dart';\n"
        '\n'
        'void main() {\n'
        "  group('''Testing feature''', () {\n"
        "    customName('''Testing scenario''', (tester) async {\n"
        '      await theAppIsRunning(tester);\n'
        '    });\n'
        '  });\n'
        '}\n';

    const scenario = 'options';
    final content = await generate(scenario);
    expect(content, expected);
  });

  test('nested includes', () async {
    const includeYaml = 'bdd_options.yaml';
    const externalYaml1 = 'external_options_1.yaml';
    const externalYaml2 = 'external_options_2.yaml';
    const externalYaml3 = 'external_options_3.yaml';

    fs.file(includeYaml)
      ..createSync()
      ..writeAsStringSync('''
include: 
  - $externalYaml1
  - $externalYaml2
''');

    fs.file(externalYaml1)
      ..createSync()
      ..writeAsStringSync('''
testMethodName: customName
hookFolderName: hooksFolder
''');

    fs.file(externalYaml2)
      ..createSync()
      ..writeAsStringSync('''
include: $externalYaml3
''');

    fs.file(externalYaml3)
      ..createSync()
      ..writeAsStringSync('''
stepFolderName: ./scenarios
''');

    const expected = '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
        '// ignore_for_file: type=lint, type=warning\n'
        '\n'
        "import 'package:flutter/material.dart';\n"
        "import 'package:flutter_test/flutter_test.dart';\n"
        '\n'
        "import './scenarios/the_app_is_running.dart';\n"
        '\n'
        'void main() {\n'
        "  group('''Testing feature''', () {\n"
        "    customName('''Testing scenario''', (tester) async {\n"
        '      await theAppIsRunning(tester);\n'
        '    });\n'
        '  });\n'
        '}\n';

    const scenario = 'options';
    final content = await generate(
      scenario,
      const BuilderOptions(<String, dynamic>{'include': externalYaml3}),
    );
    expect(content, expected);
  });

  test('Integration test with integration_test dependency', () async {
    fs.file('pubspec.yaml')
      ..createSync()
      ..writeAsStringSync('''
dev_dependencies:
  integration_test:
    sdk: flutter
''');

    const expected = '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
        '// ignore_for_file: type=lint, type=warning\n'
        '\n'
        "import 'package:flutter/material.dart';\n"
        "import 'package:flutter_test/flutter_test.dart';\n"
        "import 'package:integration_test/integration_test.dart';\n"
        '\n'
        "import './step/the_app_is_running.dart';\n"
        '\n'
        'void main() {\n'
        '  IntegrationTestWidgetsFlutterBinding.ensureInitialized();\n'
        '\n'
        "  group('''Testing feature''', () {\n"
        "    testWidgets('''Testing scenario''', (tester) async {\n"
        '      await theAppIsRunning(tester);\n'
        '    });\n'
        '  });\n'
        '}\n';

    const scenario = 'integration';
    final content = await generate(scenario, null, 'integration_test');
    expect(content, expected);
  });

  test('Integration test without integration_test dependency', () async {
    fs.file('pubspec.yaml')
      ..createSync()
      ..writeAsStringSync('''
dev_dependencies:
''');

    const expected = '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
        '// ignore_for_file: type=lint, type=warning\n'
        '\n'
        "import 'package:flutter/material.dart';\n"
        "import 'package:flutter_test/flutter_test.dart';\n"
        '\n'
        "import './step/the_app_is_running.dart';\n"
        '\n'
        'void main() {\n'
        "  group('''Testing feature''', () {\n"
        "    testWidgets('''Testing scenario''', (tester) async {\n"
        '      await theAppIsRunning(tester);\n'
        '    });\n'
        '  });\n'
        '}\n';

    const scenario = 'integration';
    final content = await generate(scenario, null, 'integration_test');
    expect(content, expected);
  });
}

// ----------------------------------------------------------------------------
const pkgName = 'pkg';

Future<String> generate(
  String scenario, [
  BuilderOptions? options,
  String testFolderName = 'test',
]) async {
  final path = '$testFolderName/builder_scenarios/$scenario';

  final srcs = <String, String>{
    '$pkgName|$path/sample.feature': minimalFeatureFile,
  };

  final writer = InMemoryAssetWriter();
  await testBuilder(
    featureBuilder(options ?? BuilderOptions.empty),
    srcs,
    rootPackage: pkgName,
    writer: writer,
  );
  return String.fromCharCodes(
    writer.assets[AssetId(pkgName, '$path/sample_test.dart')] ?? [],
  );
}

String getStepFolderName(String scenario) => p.joinAll([
      fs.currentDirectory.path,
      'test',
      'builder_scenarios',
      scenario,
      'step',
    ]);
