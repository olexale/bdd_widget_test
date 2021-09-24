Feature: Counter
    
    Background:
        Given the app is running
    
    Scenario: Initial counter value is 0
        Then I see {'0'} text

    Scenario: Add button increments the counter
        When I tap {Icons.add} icon
        Then I see {'1'} text
