const minimalFeatureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        Given the app is running
''';

const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        Given the app is running
        Then I see {0} and {1}
''';
