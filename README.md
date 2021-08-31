# bdd_widget_test [![Build Status](https://travis-ci.org/olexale/bdd_widget_test.svg?branch=master)](https://travis-ci.org/olexale/bdd_widget_test) [![Coverage Status](https://coveralls.io/repos/github/olexale/bdd_widget_test/badge.svg?branch=master)](https://coveralls.io/github/olexale/bdd_widget_test?branch=master) [![pub package](https://img.shields.io/pub/v/bdd_widget_test.svg)](https://pub.dartlang.org/packages/bdd_widget_test)

A BDD-style widget testing library

## Why?

Isn't it cool to develop mobile apps in natural language? A language each of your team members can read and understand so that it involves everyone working on the project productively. While Dart is on its way to this goal, for tests there is a language for that! It's called Gherkin.

The aim of this library is in combining two effective and easy-to-use techniques: BDD(Gherkin) and widget testing.

## Getting Started

### Add the dependency

Add `build_runner` and `bdd_widget_test` dependcies to `dev_dependencies` section of the `pubspec.yaml` file.
```yaml
dev_dependencies:
  build_runner:
  bdd_widget_test: <put the latest version here>
  ...
```

You may get the actual version from [installation instructions](https://pub.dartlang.org/packages/bdd_widget_test#-installing-tab-) on Pub site.

### Write features

Create `*.feature` file inside `test` folder. Let's say you're testing the default Flutter counter app, the content might be:
```ruby
Feature: Counter
    Scenario: Initial counter value is 0
        Given the app is running
        Then I see {'0'} text
```

Now ask `built_value` to generate Dart files for you. You may do this with the command:
```
flutter packages pub run build_runner watch --delete-conflicting-outputs
```
After that, the corresponding `dart` file will be generated for each of your `feature` files. Do not change the code inside these `dart` files as **they will be recreated** each time you change something in feature files.

During feature-to-dart generation additional `step` folder will be created. It will contain all steps required to run the scenario. **These files will not be updated** hence feel free to adapt the content according to your needs.

### Run tests

You're good to go! `bdd_widget_test` generated plain old Dart tests, so feel free to run you tests within your IDE or using the following command
```
flutter test
```

## Feature file syntax

Feature file sample:
```ruby
// comment here

Feature: Counter

  Background:
    Given the answer is {42}

  After:
    Then clean up after the test

  Scenario: Initial counter value is 0
    Given the app is running
    Then I see {'0'} text

  Scenario: Plus button increases the counter
    Given the app is running
    When I tap {Icons.add} icon
    Then I see {'1'} text
```

`Backround` and `After` keywords are optional. A `Background` allows you to add some context to the scenarios that follow it. It can contain one or more Given steps, which are run before each scenario. An `After` scenarion run even if a test fails, to ensure that it has a chance to clean up after itself. Most probably you don't need to use this keyword.

Each feature file must have one or more `Feature:`s. Features become test groups in Flutter tests.

Each feature group must have one or more `Scenario:`s (or `Example:`s). Scenario become widget tests.

Each scenario must have one or more lines with steps. Each of them must start with `Given`, `When`, `Then`, `And`, or `But` keywords. Conventionally `Given` steps are used for test arrangements, `When` — for interaction, `Then` — for asserts. Keywords are not taken into account when looking for a step definition.
You can have as many steps as you like, but it's recommended you keep the number at 3-5 per scenario. Having too many steps will cause it to lose it’s expressive power as specification and documentation. 

## Predefined steps

This library comes with a list of predefined steps. They will be auto-generated for you, but you may want to adjust their implementation according to your needs.

List of predefined steps:
* I dismiss the page
* I don't see {..} icon
* I don't see {..} rich text
* I don't see {..} text
* I don't see {..} widget
* I enter {..} into {..} input field
* I see disabled elevated button
* I see enabled elevated button
* I see exactly {..} {..} widgets
* I see {..} icon
* I see multiple {..} texts
* I see multiple {..} widgets
* I see {..} rich text
* I see {..} text
* I tap {..} icon
* I tap {..} text
* The app is running

If you want to use predefined steps without having them in your `steps` folder then you may create a `build.yaml` file in the root of your project with the following content (see the `example` folder):
```yaml
targets:
  $default:
    builders:
      bdd_widget_test|featureBuilder:
        options:
          externalSteps:
            - package:bdd_widget_test/step/i_see_text.dart
            - package:bdd_widget_test/step/i_dont_see_text.dart
            - package:bdd_widget_test/step/i_see_multiple_texts.dart
            - package:bdd_widget_test/step/i_tap_text.dart
            - package:bdd_widget_test/step/i_see_icon.dart
            - package:bdd_widget_test/step/i_dont_see_icon.dart
            - package:bdd_widget_test/step/i_tap_icon.dart
            - package:bdd_widget_test/step/i_see_rich_text.dart
            - package:bdd_widget_test/step/i_dont_see_rich_text.dart
            - package:bdd_widget_test/step/i_see_widget.dart
            - package:bdd_widget_test/step/i_dont_see_widget.dart
            - package:bdd_widget_test/step/i_see_exactly_widgets.dart
            - package:bdd_widget_test/step/i_see_multiple_widgets.dart
            - package:bdd_widget_test/step/i_enter_into_input_field.dart
            - package:bdd_widget_test/step/i_see_disabled_elevated_button.dart
            - package:bdd_widget_test/step/i_see_enabled_elevated_button.dart
            - package:bdd_widget_test/step/i_wait.dart
            - package:bdd_widget_test/step/i_dismiss_the_page.dart
```
That will tell the plugin to reuse steps from the plugin itself and do not put them into your code.

## FAQ

### How to pass a parameter?

You may use curly brackets to pass the parameter into a `step`. The syntax is following:
```ruby
  When I see {42} number
  And I see {Icons.add} icon
```
Notice, that the value inside brackets is copied to the Dart test file without changes hence it must be a valid Dart code. In the example above first step will have an `int` value. In order to pass a valid Dart string use `'42'` or `"42"`.

You may call methods in step parameters, but most probably it's not what you want.

### How to add additional imports to test files?

Most of the time you shouldn't do that, as the BDD tests simulate user's behavior and it's just not possible for users to know the implementation details. Nevertheless, sometimes it might be in hand, i.e. when you have custom domain models or components. For example, if you need to check Cupertino icons in the test, you may have:
```ruby
import 'package:flutter/cupertino.dart';

Feature: ...
  Then I see {CupertinoIcons.back} cupertino icon
```

### How to adjust linter for auto-generated tests?

Use the same trick as above, just write linter rules you wish to ignore at the beginning of the feature file:
```ruby
// ignore_for_file: avoid_as, prefer_is_not_empty

Feature: ...
```

### Any video tutorials on this?

Sure, you may find a [BDD in Flutter playlist](https://www.youtube.com/playlist?list=PLjaSBcAZ8TqFx51f30aRi_A2szelttOpq) on youtube with the basic showcase.

### How to test the UI? (golden tests)

BDD is UI agnostic, the main focus is on the requirements. If you need to test colors and layouts the simplest option would be to combine BDD widget tests with [golden_toolkit](https://pub.dev/packages/golden_toolkit) plugin.

Everything will stay pretty much the same, but you'll need to tell the plugin to name test methods `testGoldens` instead of `testWidgets`.
There are three ways on how you can do that:
1. If you have only few golden test scenarios per feature, you may mark them with the `testMethodName` tag like that:
```dart
@testMethodName: testGoldens
Scenario: My golden scenario
```
2. For features full of golden tests you may move the `testMethodName` tag above the `Feature` declaration like that:
```dart
@testMethodName: testGoldens
Feature: My golden feature
```
3. If you plan to have golden tests only, you may want to override `testMethodName` for the whole plugin. For that modify your `build.yaml` file like that:
```yaml
targets:
  $default:
    builders:
      bdd_widget_test|featureBuilder:
        options:
          testMethodName: testGoldens
```

You may refer to a video from [BDD in Flutter playlist](https://www.youtube.com/playlist?list=PLjaSBcAZ8TqFx51f30aRi_A2szelttOpq) for a live demo.

### How to reuse steps between projects?

You may reference any step using `build.yaml` file (see the `example` folder):
```yaml
targets:
  $default:
    builders:
      bdd_widget_test|featureBuilder:
        options:
          externalSteps:
            - package:<your_package>/<your_step>.dart
```

### How to group steps in a single project?

You may create sub-folders (like `common`, `login`, `home`, etc.) in the `step` folder and move generated steps there. The plugin is smart enough to find them (see the `example` folder).

### I don't like the `step` folder name, how can I change it?

By setting the `stepFolderName` parameter with any name you like in the `build.yaml` file (see the `example` folder):
```yaml
targets:
  $default:
    builders:
      bdd_widget_test|featureBuilder:
        options:
          stepFolderName: bdd_steps
```

You may set a relative path here (like `../../bdd_steps`), just be sure that the target folder is still somewhere under the `test` folder.

## Contributing

If you find a bug or would like to request a new feature, just [open an issue](https://github.com/olexale/bdd_widget_test/issues/new). Your contributions are always welcome!

## License
`bdd_widget_test` is released under a [MIT License](https://opensource.org/licenses/MIT). See `LICENSE` for details.
