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
    bool? relativeToTestFolder,
    String? testerType,
    String? testerName,
    bool? addHooks,
    String? hookFolderName,
    this.include,
    bool? includeIntegrationTestBinding,
    List<String>? customHeaders,
  }) : stepFolder = stepFolderName ?? _stepFolderName,
       relativeToTestFolder = relativeToTestFolder ?? true,
       testMethodName = testMethodName ?? _defaultTestMethodName,
       testerType = testerType ?? _defaultTesterType,
       testerName = testerName ?? _defaultTesterName,
       addHooks = addHooks ?? false,
       hookFolderName = hookFolderName ?? _hookFolderName,
       externalSteps = externalSteps ?? const [],
       includeIntegrationTestBinding = includeIntegrationTestBinding ?? true,
       customHeaders = customHeaders ?? const [];

  factory GeneratorOptions.fromMap(Map<String, dynamic> json) =>
      GeneratorOptions(
        testMethodName: json['testMethodName'] as String?,
        testerType: json['testerType'] as String?,
        testerName: json['testerName'] as String?,
        externalSteps: (json['externalSteps'] as List?)?.cast<String>(),
        stepFolderName: json['stepFolderName'] as String?,
        relativeToTestFolder: json['relativeToTestFolder'] as bool?,
        addHooks: json['addHooks'] as bool?,
        hookFolderName: json['hookFolderName'] as String?,
        include:
            json['include'] is String
                ? [(json['include'] as String)]
                : (json['include'] as List?)?.cast<String>(),
        includeIntegrationTestBinding:
            json['includeIntegrationTestBinding'] as bool?,
        customHeaders: (json['customHeaders'] as List?)?.cast<String>() ?? [],
      );

  final String stepFolder;
  final bool relativeToTestFolder;
  final String testMethodName;
  final String testerType;
  final String testerName;
  final bool addHooks;
  final String hookFolderName;
  final List<String>? include;
  final List<String> externalSteps;
  final bool includeIntegrationTestBinding;
  final List<String> customHeaders;
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
  return GeneratorOptions.fromMap(doc.value.cast());
}

GeneratorOptions merge(
  GeneratorOptions a,
  GeneratorOptions b,
) => GeneratorOptions(
  testMethodName:
      a.testMethodName != _defaultTestMethodName
          ? a.testMethodName
          : b.testMethodName,
  testerType: a.testerType != _defaultTesterType ? a.testerType : b.testerType,
  testerName: a.testerName != _defaultTesterName ? a.testerName : b.testerName,
  stepFolderName: a.stepFolder != _stepFolderName ? a.stepFolder : b.stepFolder,
  relativeToTestFolder: a.relativeToTestFolder && b.relativeToTestFolder,
  externalSteps: [...a.externalSteps, ...b.externalSteps],
  addHooks: a.addHooks || b.addHooks,
  hookFolderName:
      a.hookFolderName != _hookFolderName ? a.hookFolderName : b.hookFolderName,
  include: b.include,
  includeIntegrationTestBinding:
      a.includeIntegrationTestBinding || b.includeIntegrationTestBinding,
  customHeaders: [...a.customHeaders, ...b.customHeaders],
);
