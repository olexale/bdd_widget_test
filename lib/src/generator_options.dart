const defaultTestName = 'testWidgets';

class GeneratorOptions {
  const GeneratorOptions({
    String? testMethodName,
    List<String>? externalSteps,
  })  : testMethodName = testMethodName ?? defaultTestName,
        externalSteps = externalSteps ?? const [];

  factory GeneratorOptions.fromMap(Map<String, dynamic> json) =>
      GeneratorOptions(
        testMethodName: json['testMethodName'] as String?,
        externalSteps: (json['externalSteps'] as List?)?.cast<String>(),
      );

  final String testMethodName;
  final List<String> externalSteps;
}
