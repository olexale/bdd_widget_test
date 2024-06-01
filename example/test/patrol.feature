import 'package:patrol/patrol.dart';

@testMethodName: patrolTest
@testerName: $
@testerType: PatrolIntegrationTester
Feature: Counter
    
    Background:
        Given the patrol app is running
    
    @scenarioParams: semanticsEnabled: false
    Scenario: Initial counter value is 0
        Then I see {'0'} label