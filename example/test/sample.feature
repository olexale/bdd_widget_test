Feature: Counter
    Background:
        Given the app is running
    After:
        And I do not see {'42'} text
    Scenario: Initial counter value is 0
        Given the app is running
        Then I see {'0'} text