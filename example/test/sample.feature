Feature: Counter
    
    Background:
        Given the app is running
    
    After:
        # Just for the demo purpose, you may write "I don't see {'surprise'} text" to use built-in step instead.
        # See the list of built-in step below.
        And I do not see {'surprise'} text 
    
    Scenario: Initial counter value is 0
        Then I see {'0'} text

    # A golden test is just a built-in step. test/flutter_test_config.dart loads real fonts,
    # so goldens are OS-specific, and keeps one set per OS: test/goldens/<os>/initial_counter.png.
    # macOS and Linux sets are committed. On another OS, run `flutter test --update-goldens` first.
    Scenario: Initial counter screen
        Then the screen matches golden {'initial_counter'}

    Scenario: Add button increments the counter
        When I tap {Icons.add} icon
        Then I see {'1'} text

    Scenario Outline: Plus button increases the counter
        Given the app is running
        When I tap {Icons.add} icon <times> times
        Then I see <result> text

        Examples:
        | times | result |
        |    0  |   '0'  |
        |    1  |   '1'  |
        |   42  |  '42'  |

    # Scenario: Built-in steps
    #     And I don't see {Icons.add} icon
    #     And I don't see {'text'} rich text
    #     And I don't see {'text'} text
    #     And I don't see {Container} widget
    #     And I enter {'text'} into {1} input field
    #     And I see disabled elevated button
    #     And I see enabled elevated button
    #     And I see exactly {4} {Container} widgets
    #     And I see {Icons.add} icon
    #     And I see multiple {'text'} texts
    #     And I see multiple {Container} widgets
    #     And I see {'text'} rich text
    #     And I see {'text'} text
    #     And I tap {Icons.add} icon
    #     And I wait
    #     And I dismiss the page