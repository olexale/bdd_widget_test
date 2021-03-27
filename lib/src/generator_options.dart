const defaultTestName = 'testWidgets';

class GeneratorOptions {
  const GeneratorOptions({
    this.testMethodName,
    this.externalSteps,
  });

  factory GeneratorOptions.fromMap(Map<String, dynamic> json) =>
      GeneratorOptions(
        testMethodName: json['testMethodName'] as String ?? defaultTestName,
        externalSteps: (json['externalSteps'] as List)?.cast<String>() ?? [],
      );

  final String testMethodName;
  final List<String> externalSteps;
}
