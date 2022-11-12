import 'package:bdd_widget_test/src/util/fs.dart';
import 'package:bdd_widget_test/src/util/isolate_helper.dart';
import 'package:yaml/yaml.dart';

const _defaultTestName = 'testWidgets';
const _stepFolderName = 'step';

class GeneratorOptions {
  const GeneratorOptions({
    String? testMethodName,
    List<String>? externalSteps,
    String? stepFolderName,
    this.include,
  })  : stepFolder = stepFolderName ?? _stepFolderName,
        testMethodName = testMethodName ?? _defaultTestName,
        externalSteps = externalSteps ?? const [];

  factory GeneratorOptions.fromMap(Map<String, dynamic> json) =>
      GeneratorOptions(
        testMethodName: json['testMethodName'] as String?,
        externalSteps: (json['externalSteps'] as List?)?.cast<String>(),
        stepFolderName: json['stepFolderName'] as String?,
        include: json['include'] is String
            ? [(json['include'] as String)]
            : (json['include'] as List?)?.cast<String>(),
      );

  final String stepFolder;
  final String testMethodName;
  final List<String>? include;
  final List<String> externalSteps;
}

Future<GeneratorOptions> flattenOptions(GeneratorOptions options) async {
  if (options.include?.isEmpty ?? true) {
    return options;
  }
  var resultOptions = options;
  for (final include in resultOptions.include!) {
    final includedOptions = await _readFromPackage(include);
    final newOptions = merge(resultOptions, includedOptions);
    resultOptions = await flattenOptions(newOptions);
  }

  return resultOptions;
}

Future<GeneratorOptions> _readFromPackage(String packageUri) async {
  final uri = await resolvePackageUri(
    Uri.parse(packageUri),
  );
  if (uri == null) {
    throw Exception('Could not read $packageUri');
  }
  return readFromUri(uri);
}

GeneratorOptions readFromUri(Uri uri) {
  final rawYaml = fs.file(uri).readAsStringSync();
  final doc = loadYamlNode(rawYaml) as YamlMap;
  return GeneratorOptions(
    testMethodName: doc['testMethodName'] as String?,
    externalSteps: (doc['externalSteps'] as List?)?.cast<String>(),
    stepFolderName: doc['stepFolderName'] as String?,
    include: doc['include'] is String
        ? [(doc['include'] as String)]
        : (doc['include'] as YamlList?)?.value.cast<String>(),
  );
}

GeneratorOptions merge(GeneratorOptions a, GeneratorOptions b) =>
    GeneratorOptions(
      testMethodName: a.testMethodName != _defaultTestName
          ? a.testMethodName
          : b.testMethodName,
      stepFolderName:
          a.stepFolder != _stepFolderName ? a.stepFolder : b.stepFolder,
      externalSteps: [...a.externalSteps, ...b.externalSteps],
      include: b.include,
    );
