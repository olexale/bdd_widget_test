import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/step/bdd_step.dart';
import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:collection/collection.dart';

class GenericStep implements BddStep {
  GenericStep(
    this.methodName,
    this.rawLine,
    this.testerType,
    this.customTesterName,
    this.hasDataTable,
    this.generatorOptions,
  );

  final String rawLine;
  final String methodName;
  final String testerType;
  final String customTesterName;
  final bool hasDataTable;
  final GeneratorOptions generatorOptions;

  @override
  String get content {
    final hasCustomHeaders = generatorOptions.customHeaders.isNotEmpty;
    final headerSection = hasCustomHeaders
        ? generatorOptions.customHeaders.join('\n')
        : "import 'package:flutter_test/flutter_test.dart';";

    return '${hasDataTable ? "import 'package:bdd_widget_test/data_table.dart' as bdd;\n" : ''}'
        '''
$headerSection

/// Usage: $rawLine
Future<void> $methodName($testerType $customTesterName${_getMethodParameters(rawLine, hasDataTable)}) async {
  throw UnimplementedError();
}
''';
  }

  String _getMethodParameters(String stepLine, bool hadDataTable) {
    final [name, ...params] = parseRawStepLine(stepLine);
    // Only a placeholder outside `{}` is a parameter of its own: one inside a
    // `{}` block is part of that parameter (`{<name>}`, `{'<name>'}`), which
    // the generated call passes as one argument.
    final examples = examplesRegExp.allMatches(name);

    return [
      ...params.mapIndexed(
        (index, p) => ', ${_getGenericParameterType(p)} param${index + 1}',
      ),
      ...examples.map((p) => ', dynamic ${p.group(1)}'),
      if (hasDataTable) ', bdd.DataTable dataTable',
    ].join();
  }

  String _getGenericParameterType(String parameter) {
    if (parameter == 'true' || parameter == 'false') {
      return 'bool';
    }
    if (num.tryParse(parameter) != null) {
      return 'num';
    }
    if ((parameter.startsWith('"') && parameter.endsWith('"')) ||
        (parameter.startsWith("'") && parameter.endsWith("'"))) {
      return 'String';
    }
    return 'dynamic';
  }
}
