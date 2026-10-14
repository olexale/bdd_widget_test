import 'package:patrol_finders/patrol_finders.dart';

@testMethodName: patrolWidgetTest
@testerName: $
@testerType: PatrolTester
Feature: Counter
    
    Background:
        Given the patrol app is running
    
    @scenarioParams: semanticsEnabled: false
    Scenario: Initial counter value is 0
        Then I see {'0'} label
