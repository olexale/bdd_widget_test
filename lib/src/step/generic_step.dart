import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/regex.dart';
import 'package:bdd_widget_test/src/step/bdd_step.dart';
import 'package:bdd_widget_test/src/util/dart_block.dart';

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
    return [
      ..._parametersInOrder(stepLine),
      if (hasDataTable) ', bdd.DataTable dataTable',
    ].join();
  }

  /// The step's parameters in the order they are written, which is the order
  /// the generated call passes them in: each `{}` block is a `paramN`, each
  /// `<placeholder>` outside one a parameter named after it. A placeholder
  /// inside a block (`{<name>}`, `{'<name>'}`) is part of that parameter.
  Iterable<String> _parametersInOrder(String stepLine) sync* {
    var blocks = 0;
    var i = 0;
    while (i < stepLine.length) {
      if (stepLine[i] == '{') {
        final end = readDartBlock(stepLine, i)?.end;
        if (end == null) {
          // As in parseRawStepLine: an unclosed block is no parameter.
          return;
        }
        final parameter = stepLine.substring(i + 1, end - 1);
        yield ', ${_getGenericParameterType(parameter)} param${++blocks}';
        i = end;
        continue;
      }
      final placeholder = examplesRegExp.matchAsPrefix(stepLine, i);
      if (placeholder != null) {
        yield ', dynamic ${placeholder.group(1)}';
        i = placeholder.end;
        continue;
      }
      i++;
    }
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
