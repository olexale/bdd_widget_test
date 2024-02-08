import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:bdd_widget_test/src/generator_options.dart';
import 'package:bdd_widget_test/src/hook_file.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Hook file generation ', () {
    final feature = FeatureFile(
      featureDir: 'test/sub-feature/feature',
      package: 'bdd_feature',
      input: '',
      generatorOptions: const GeneratorOptions(
        addHooks: true,
      ),
    );
    expect(feature.hookFile, isNotNull);
    expect(
      feature.hookFile?.fileName,
      'test/sub-feature/feature/./hook/hooks.dart',
    );
    expect(feature.hookFile?.import, './hook/hooks.dart');
  });

  test('Disable hook file generation ', () {
    final feature = FeatureFile(
      featureDir: 'test/sub-feature/feature',
      package: 'bdd_feature',
      input: '',
    );
    expect(feature.hookFile, isNull);
  });

  test('Hook file content generation ', () {
    const expectedFileContent = '''
import 'dart:async';

abstract class Hooks {
  const Hooks._();
  
  static FutureOr<void> beforeEach(
    String title, [
    List<String>? tags,
    ]) {
    // Add logic for beforeEach
  }
  
  static FutureOr<void> beforeAll() {
    // Add logic for beforeAll
  }
  
  static FutureOr<void> afterEach(
    String title,
    bool success, [
    List<String>? tags,
  ]) {
    // Add logic for afterEach
  }
  
  static FutureOr<void> afterAll() {
    // Add logic for afterAll
  }
}
''';

    final hookFileContent = createHooksFileContent(false);
    expect(hookFileContent, equals(expectedFileContent));
  });

  test('Hook file content generation with world ', () {
    const expectedFileContent = '''
import 'dart:async';
import 'package:bdd_widget_test/world.dart';

abstract class Hooks {
  const Hooks._();
  
  static FutureOr<void> beforeEach(
    String title,
    World world, [
    List<String>? tags,
    ]) {
    // Add logic for beforeEach
  }
  
  static FutureOr<void> beforeAll() {
    // Add logic for beforeAll
  }
  
  static FutureOr<void> afterEach(
    String title,
    bool success,
    World world, [
    List<String>? tags,
  ]) {
    // Add logic for afterEach
  }
  
  static FutureOr<void> afterAll() {
    // Add logic for afterAll
  }
}
''';

    final hookFileContent = createHooksFileContent(true);
    expect(hookFileContent, equals(expectedFileContent));
  });
}
