import 'package:bdd_widget_test/bdd_widget_test.dart';
import 'package:bdd_widget_test/src/util/fs.dart';
import 'package:bdd_widget_test/src/util/package_root_resolver.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:file/memory.dart';
import 'package:package_config/package_config.dart';
import 'package:test/test.dart';

// End-to-end proof that, in a pub workspace, the builder resolves the owning
// package's root and writes generated files INSIDE that package — not at the
// workspace root (the bug from issue #121).
void main() {
  // The package "pkg" lives at /ws/app_a, which is NOT the current directory.
  const packageRoot = '/ws/app_a';

  setUp(() {
    fsInstance = MemoryFileSystem.test();
    // Pretend the workspace package_config maps `pkg` to /ws/app_a.
    packageRootCache.clear();
    preloadedPackageConfig = PackageConfig(
      [
        Package(
          'pkg',
          Uri.parse('file://$packageRoot/'),
          packageUriRoot: Uri.parse('file://$packageRoot/lib/'),
        ),
      ],
    );
    // bdd_options.yaml is read from the package root; force the test-relative
    // step folder so the resolved path is unmistakably workspace-aware.
    fs.file('$packageRoot/bdd_options.yaml')
      ..createSync(recursive: true)
      ..writeAsStringSync('''
stepFolderName: step
relativeToTestFolder: true
''');
  });

  tearDown(() {
    packageRootCache.clear();
    preloadedPackageConfig = null;
    fsInstance = null;
  });

  test('generated test imports the package-relative step path', () async {
    const feature = '''
Feature: Counter
    Scenario: Initial value
        Given the app is running
''';

    const expectedTest =
        '// GENERATED CODE - DO NOT MODIFY BY HAND\n'
        '// ignore_for_file: type=lint, type=warning\n'
        '\n'
        "import 'package:flutter/material.dart';\n"
        "import 'package:flutter_test/flutter_test.dart';\n"
        '\n'
        "import '../step/the_app_is_running.dart';\n"
        '\n'
        'void main() {\n'
        "  group('''Counter''', () {\n"
        "    testWidgets('''Initial value''', (tester) async {\n"
        '      await theAppIsRunning(tester);\n'
        '    });\n'
        '  });\n'
        '}\n';

    await testBuilder(
      featureBuilder(BuilderOptions.empty),
      {'pkg|test/features/counter.feature': feature},
      rootPackage: 'pkg',
      outputs: {
        'pkg|test/features/counter_test.dart': decodedMatches(expectedTest),
      },
    );

    // The step stub must be written INSIDE the package, under /ws/app_a.
    expect(
      fs.file('$packageRoot/test/step/the_app_is_running.dart').existsSync(),
      isTrue,
      reason: 'step file should be written under the package root',
    );
    // It must NOT be written at the workspace root / cwd.
    expect(
      fs.file('test/step/the_app_is_running.dart').existsSync(),
      isFalse,
      reason: 'step file must not escape to the workspace root',
    );
  });

  test(
    'integration test binding is detected from the package pubspec',
    () async {
      // The integration_test dev dependency lives ONLY in the package pubspec
      // under /ws/app_a, not at the cwd. Detecting it proves the builder reads
      // <packageRoot>/pubspec.yaml rather than the workspace-root pubspec.
      fs.file('$packageRoot/pubspec.yaml')
        ..createSync(recursive: true)
        ..writeAsStringSync('''
dev_dependencies:
  integration_test:
    sdk: flutter
''');

      const feature = '''
Feature: Counter
    Scenario: Initial value
        Given the app is running
''';

      await testBuilder(
        featureBuilder(BuilderOptions.empty),
        {'pkg|integration_test/counter.feature': feature},
        rootPackage: 'pkg',
        outputs: {
          'pkg|integration_test/counter_test.dart': decodedMatches(
            contains(
              "import 'package:integration_test/integration_test.dart';",
            ),
          ),
        },
      );
    },
  );

  test(
    'relative include in bdd_options resolves against the package root',
    () async {
      // Override the bdd_options written in setUp with one that pulls in a
      // sibling file via a RELATIVE include. Both live under the package root,
      // so resolution must join them against /ws/app_a (the workspace branch).
      fs.file('$packageRoot/bdd_options.yaml').writeAsStringSync('''
include: extra_options.yaml
''');
      fs.file('$packageRoot/extra_options.yaml')
        ..createSync(recursive: true)
        ..writeAsStringSync('''
testMethodName: customName
''');

      const feature = '''
Feature: Counter
    Scenario: Initial value
        Given the app is running
''';

      await testBuilder(
        featureBuilder(BuilderOptions.empty),
        {'pkg|test/features/counter.feature': feature},
        rootPackage: 'pkg',
        outputs: {
          // The included testMethodName must win, proving the relative include
          // was read from <packageRoot>/extra_options.yaml.
          'pkg|test/features/counter_test.dart': decodedMatches(
            contains("customName('''Initial value'''"),
          ),
        },
      );
    },
  );
}
