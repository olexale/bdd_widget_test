import 'dart:io';
import 'dart:isolate';

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
        include: json['include'] as String?,
      );

  final String stepFolder;
  final String testMethodName;
  final String? include;
  final List<String> externalSteps;
}

Future<GeneratorOptions> flattenOptions(GeneratorOptions options) async {
  if (options.include == null) {
    return options;
  }
  final includedOptions = await readFromPackage(options.include!);
  final newOptions = merge(options, includedOptions);
  return flattenOptions(newOptions);
}

Future<GeneratorOptions> readFromPackage(String packageUri) async {
  final uri = await Isolate.resolvePackageUri(
    Uri.parse(packageUri),
  );
  if (uri == null) {
    throw Exception('Could not read $packageUri');
  }
  return readFromUri(uri);
}

GeneratorOptions readFromUri(Uri uri) {
  final doc = loadYamlNode(File.fromUri(uri).readAsStringSync()) as YamlMap;
  return GeneratorOptions(
    testMethodName: doc['testMethodName'] as String?,
    externalSteps: (doc['externalSteps'] as List?)?.cast<String>(),
    stepFolderName: doc['stepFolderName'] as String?,
    include: doc['include'] as String?,
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
