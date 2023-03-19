@slow
@ui
Feature: Counter
    @important
    @simple
    Scenario: Initial counter value is 0
        Given the app is running
        Then I see {'0'} text
