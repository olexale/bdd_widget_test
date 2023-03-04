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
        '// ignore_for_file: unused_import, directives_ordering\n'
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
    final dummyStepPath =
        p.join(getStepFolderName(scenario), 'the_app_is_running.dart');
    const expectedFileContent = '// existing step';
    fs.file(dummyStepPath)
      ..createSync(recursive: true)
      ..writeAsStringSync(expectedFileContent);

    await generate(scenario);

    final content = fs.file(dummyStepPath).readAsStringSync();
    expect(content, expectedFileContent);
  });

  test('custom bdd_options', () async {
    const bddOptions = '''
stepFolderName: scenarios
testMethodName: customName
''';
    fs.file('bdd_options.yaml')
      ..createSync()
      ..writeAsStringSync(bddOptions);
    const expected = '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
        '// ignore_for_file: unused_import, directives_ordering\n'
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

  test('non-valid include', () async {
    // resolvePackageUriFactory = (_) => Future.value();

    const bddOptions = 'include: non-existing-file';
    fs.file('bdd_options.yaml')
      ..createSync()
      ..writeAsStringSync(bddOptions);

    const scenario = 'options';
    expect(
      () => generate(scenario),
      throwsException,
    );
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
stepFolderName: scenarios
''');

    const expected = '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
        '// ignore_for_file: unused_import, directives_ordering\n'
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
''');

    fs.file(externalYaml2)
      ..createSync()
      ..writeAsStringSync('''
include: $externalYaml3
''');

    fs.file(externalYaml3)
      ..createSync()
      ..writeAsStringSync('''
stepFolderName: scenarios
''');

    const expected = '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
        '// ignore_for_file: unused_import, directives_ordering\n'
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
      const BuilderOptions(<String, dynamic>{
        'include': externalYaml3,
      }),
    );
    expect(content, expected);
  });
}

// ----------------------------------------------------------------------------
const pkgName = 'pkg';

Future<String> generate(String scenario, [BuilderOptions? options]) async {
  final path = 'test/builder_scenarios/$scenario';

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
