import 'package:bdd_widget_test/src/util/fs.dart';
import 'package:bdd_widget_test/src/util/isolate_helper.dart';
import 'package:yaml/yaml.dart';

const _defaultTestMethodName = 'testWidgets';
const _defaultTesterType = 'WidgetTester';
const _defaultTesterName = 'tester';
const _stepFolderName = './step';
const _hookFolderName = './hook';

class GeneratorOptions {
  const GeneratorOptions({
    String? testMethodName,
    List<String>? externalSteps,
    String? stepFolderName,
    String? testerType,
    String? testerName,
    bool? addHooks,
    String? hookFolderName,
    bool? addWorld,
    this.include,
  })  : stepFolder = stepFolderName ?? _stepFolderName,
        testMethodName = testMethodName ?? _defaultTestMethodName,
        testerType = testerType ?? _defaultTesterType,
        testerName = testerName ?? _defaultTesterName,
        addHooks = addHooks ?? false,
        hookFolderName = hookFolderName ?? _hookFolderName,
        addWorld = addWorld ?? false,
        externalSteps = externalSteps ?? const [];

  factory GeneratorOptions.fromMap(Map<String, dynamic> json) =>
      GeneratorOptions(
        testMethodName: json['testMethodName'] as String?,
        testerType: json['testerType'] as String?,
        testerName: json['testerName'] as String?,
        externalSteps: (json['externalSteps'] as List?)?.cast<String>(),
        stepFolderName: json['stepFolderName'] as String?,
        addHooks: json['addHooks'] as bool?,
        hookFolderName: json['hookFolderName'] as String?,
        addWorld: json['addWorld'] as bool?,
        include: json['include'] is String
            ? [(json['include'] as String)]
            : (json['include'] as List?)?.cast<String>(),
      );

  final String stepFolder;
  final String testMethodName;
  final String testerType;
  final String testerName;
  final bool addHooks;
  final String hookFolderName;
  final bool addWorld;
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
    testerType: doc['testerType'] as String?,
    testerName: doc['testerName'] as String?,
    externalSteps: (doc['externalSteps'] as List?)?.cast<String>(),
    stepFolderName: doc['stepFolderName'] as String?,
    addHooks: doc['addHooks'] as bool?,
    hookFolderName: doc['hookFolderName'] as String?,
    addWorld: doc['addWorld'] as bool?,
    include: doc['include'] is String
        ? [(doc['include'] as String)]
        : (doc['include'] as YamlList?)?.value.cast<String>(),
  );
}

GeneratorOptions merge(GeneratorOptions a, GeneratorOptions b) =>
    GeneratorOptions(
      testMethodName: a.testMethodName != _defaultTestMethodName
          ? a.testMethodName
          : b.testMethodName,
      testerType:
          a.testerType != _defaultTesterType ? a.testerType : b.testerType,
      testerName:
          a.testerName != _defaultTesterName ? a.testerName : b.testerName,
      stepFolderName:
          a.stepFolder != _stepFolderName ? a.stepFolder : b.stepFolder,
      externalSteps: [...a.externalSteps, ...b.externalSteps],
      addHooks: a.addHooks || b.addHooks,
      hookFolderName: a.hookFolderName != _hookFolderName
          ? a.hookFolderName
          : b.hookFolderName,
      addWorld: a.addWorld || b.addWorld,
      include: b.include,
    );
