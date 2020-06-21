const minimalFeatureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        Given the app is running
''';

const featureFile = '''
Feature: Testing feature
    Scenario: Testing scenario
        Given the app is running
        Then I see {'nice param'} text

        And I see {Icons.add} icon
''';

const bigFeatureFile = '''
// some comment

Feature: First testing feature
    Scenario: First testing scenario
        Given the app is running

Feature: Second testing feature
    
    Scenario: First testing scenario
        Given the app is running
    

    Scenario: Second testing scenario
        Given the app is running

''';
