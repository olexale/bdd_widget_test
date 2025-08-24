import 'package:bdd_widget_test/src/existing_steps.dart';
import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/hook_file.dart';
import 'package:bdd_widget_test/src/step_file.dart';
import 'package:bdd_widget_test/src/util/dart_formatter.dart';
import 'package:bdd_widget_test/src/util/fs.dart';
import 'package:build/build.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Creates a [FeatureBuilder] instance with the provided build options.
///
/// This function is the main entry point for the BDD Widget Test code
/// generation system. It's used by the build system to create a builder
/// that processes `.feature` files and generates corresponding Dart test files.
///
/// The [options] parameter contains configuration settings from `build.yaml`
/// and/or `bdd_options.yaml` files, which are converted to [GeneratorOptions]
/// and used to customize the code generation behavior.
///
/// Example usage in `build.yaml`:
/// ```yaml
/// targets:
///   $default:
///     builders:
///       bdd_widget_test|featureBuilder:
///         options:
///           testMethodName: testGoldens
///           stepFolderName: ./custom_steps
/// ```
///
/// Returns a [FeatureBuilder] instance configured with the specified options.
Builder featureBuilder(BuilderOptions options) => FeatureBuilder(
      GeneratorOptions.fromMap(options.config),
    );

/// A code generator builder that transforms BDD feature files into Dart test files.
///
/// [FeatureBuilder] is responsible for parsing Gherkin feature files (`.feature`)
/// and generating corresponding Dart test files (`_test.dart`) that can be executed
/// as Flutter widget tests. It handles the complete transformation process including:
///
/// - Parsing feature files written in Gherkin syntax
/// - Generating executable Dart test code with proper test structure
/// - Creating step definition files for new steps
/// - Managing existing step definitions and imports
/// - Handling hooks for setup and teardown operations
/// - Supporting integration test configurations
/// - Applying customizable generation options
///
/// The builder processes files with the `.feature` extension and outputs
/// corresponding `_test.dart` files in the same directory structure.
///
/// Features supported:
/// - Scenarios and Scenario Outlines
/// - Data Tables and Examples
/// - Tags for conditional execution
/// - Background steps
/// - Hooks (Before/After)
/// - Custom test method names
/// - Custom tester types and names
/// - Integration test binding
/// - External step definitions
///
/// Example feature file:
/// ```gherkin
/// Feature: Counter App
///   Scenario: Initial counter value is 0
///     Given the app is running
///     Then I see {'0'} text
/// ```
///
/// Generated test file:
/// ```dart
/// void main() {
///   group('''Counter App''', () {
///     testWidgets('''Initial counter value is 0''', (tester) async {
///       await theAppIsRunning(tester);
///       await iSeeText(tester, '0');
///     });
///   });
/// }
/// ```
class FeatureBuilder implements Builder {
  /// Creates a new [FeatureBuilder] with the specified generator options.
  ///
  /// The [generatorOptions] parameter defines how the builder should generate
  /// test code, including:
  /// - Test method names (e.g., `testWidgets`, `testGoldens`)
  /// - Tester types and names (e.g., `WidgetTester`, `PatrolIntegrationTester`)
  /// - Step folder locations and naming conventions
  /// - Hook configurations for setup and teardown
  /// - Integration test settings
  /// - External step definitions
  ///
  /// This constructor is typically called by the [featureBuilder] function
  /// rather than being invoked directly.
  ///
  /// Example:
  /// ```dart
  /// final builder = FeatureBuilder(
  ///   GeneratorOptions(
  ///     testMethodName: 'testGoldens',
  ///     stepFolderName: './custom_steps',
  ///     testerType: 'PatrolIntegrationTester',
  ///   ),
  /// );
  /// ```
  FeatureBuilder(this.generatorOptions);

  /// Configuration options that control how feature files are processed and
  /// what kind of Dart test code is generated.
  ///
  /// These options can be customized through:
  /// - `build.yaml` builder configuration
  /// - `bdd_options.yaml` project-specific settings
  /// - Included external configuration files
  ///
  /// The options are merged in priority order, with builder options taking
  /// precedence over file-based options.
  ///
  /// Common configuration properties:
  /// - `testMethodName`: The Flutter test method to use (default: 'testWidgets')
  /// - `testerType`: The type of tester parameter (default: 'WidgetTester')
  /// - `testerName`: The name of the tester parameter (default: 'tester')
  /// - `stepFolderName`: Directory for step definition files (default: './step')
  /// - `addHooks`: Whether to generate hook files (default: false)
  /// - `includeIntegrationTestBinding`: Integration test support (default: true)
  final GeneratorOptions generatorOptions;

  @override
  Future<void> build(BuildStep buildStep) async {
    final options = await _prepareOptions();

    final inputId = buildStep.inputId;
    final contents = await buildStep.readAsString(inputId);

    final featureDir = p.dirname(inputId.path);
    final isIntegrationTest =
        inputId.pathSegments.contains('integration_test') &&
            _hasIntegrationTestDevDependency();

    final feature = FeatureFile(
      featureDir: featureDir,
      package: inputId.package,
      existingSteps: getExistingStepSubfolders(featureDir, options),
      input: contents,
      generatorOptions: options,
      includeIntegrationTestImport: isIntegrationTest,
      includeIntegrationTestBinding:
          isIntegrationTest && generatorOptions.includeIntegrationTestBinding,
    );

    final featureDart = inputId.changeExtension('_test.dart');
    await buildStep.writeAsString(
      featureDart,
      formatDartCode(feature.dartContent),
    );

    final steps = feature.getStepFiles().whereType<NewStepFile>().map(
          (e) =>
              _createFileRecursively(e.filename, formatDartCode(e.dartContent)),
        );
    await Future.wait(steps);

    final hookFile = feature.hookFile;
    if (hookFile != null) {
      await _createFileRecursively(hookFile.fileName, hookFileContent);
    }
  }

  Future<GeneratorOptions> _prepareOptions() async {
    final fileOptions = fs.file('bdd_options.yaml').existsSync()
        ? readFromUri(Uri.file('bdd_options.yaml'))
        : null;
    final mergedOptions = fileOptions != null
        ? merge(generatorOptions, fileOptions)
        : generatorOptions;
    final options = await flattenOptions(mergedOptions);
    return options;
  }

  Future<void> _createFileRecursively(String filename, String content) async {
    final f = fs.file(filename);
    if (f.existsSync()) {
      return;
    }
    final file = await f.create(recursive: true);
    await file.writeAsString(content);
  }

  bool _hasIntegrationTestDevDependency() {
    if (fs.file('pubspec.yaml').existsSync()) {
      final fileContent = fs.file('pubspec.yaml').readAsStringSync();
      final pubspec = loadYaml(fileContent) as YamlMap;
      final devDependencies = pubspec['dev_dependencies'] as YamlMap?;
      return devDependencies?.containsKey('integration_test') ?? false;
    }
    return false;
  }

  @override
  final buildExtensions = const {
    '.feature': ['_test.dart'],
  };
}
