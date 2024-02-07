import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/step/bdd_step.dart';
import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:bdd_widget_test/src/util/constants.dart';
import 'package:collection/collection.dart';

class GenericStep implements BddStep {
  GenericStep(
    this.methodName,
    this.rawLine,
    this.testerType,
    this.customTesterName,
    this.hasDataTable,
    this.addWorld,
  );

  final String rawLine;
  final String methodName;
  final String testerType;
  final String customTesterName;
  final bool hasDataTable;
  final bool addWorld;

  @override
  String get content =>
      '${hasDataTable ? "import 'package:bdd_widget_test/data_table.dart' as bdd;\n" : ''}'
      '${addWorld ? "import 'package:bdd_widget_test/world.dart';\n" : ''}'
      '''
import 'package:flutter_test/flutter_test.dart';

/// Usage: $rawLine
Future<void> $methodName($testerType $customTesterName${_getMethodParameters(rawLine, hasDataTable)}${addWorld ? ", $worldParameter" : ""}) async {
  throw UnimplementedError();
}
''';

  String _getMethodParameters(String stepLine, bool hadDataTable) {
    if (hadDataTable) {
      return ', bdd.DataTable dataTable';
    }

    final params = parseRawStepLine(stepLine).skip(1);
    if (params.isNotEmpty) {
      return params
          .mapIndexed(
            (index, p) => ', ${_getGenericParameterType(p)} param${index + 1}',
          )
          .join();
    }

    final examples = examplesRegExp.allMatches(stepLine);
    if (examples.isNotEmpty) {
      return examples.map((p) => ', dynamic ${p.group(1)}').join();
    }

    return '';
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
