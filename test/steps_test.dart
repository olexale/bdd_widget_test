import 'package:bdd_widget_test/src/feature_file.dart';
import 'package:test/test.dart';

void main() {
  test('Empty feature file parses', () {
    const path = 'test';

    final feature = FeatureFile(
      featureDir: '$path.feature',
      package: path,
      input: '',
    );
    expect(feature.getStepFiles().length, 0);
  });
}
