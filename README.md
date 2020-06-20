# bdd_widget_test [![Build Status](https://travis-ci.org/olexale/bdd_widget_test.svg?branch=master)](https://travis-ci.org/olexale/bdd_widget_test) [![Coverage Status](https://coveralls.io/repos/github/olexale/bdd_widget_test/badge.svg?branch=master)](https://coveralls.io/github/olexale/bdd_widget_test?branch=master)

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
```
Feature: Counter app
    
    Scenario: Initial counter value is 0
        Given the app is running
        Then I see {0} text

    Scenario: Plus button increases the counter
        Given the app is running
        When I tap on {Icons.add} icon
        Then I see {1} text
```

Now ask `built_value` to generate Dart files for you. You may do this with the command:
```
flutter packages pub run build_runner watch --delete-conflicting-outputs
```
After that, the corresponding `dart` file will be generated for each of your `feature` files. Do not change the code inside these `dart` files as they will be recreated each time you change something in feature files.

During feature-to-dart generation additional `step` folder will be created. It will contain all steps required to run the scenario. These files will not be updated hence feel free to adapt the content according to your needs.

### Run tests

You're good to go! `bdd_widget_test` generated plain old Dart tests, so feel free to run you tests within your IDE or using the following command
```
flutter test
```

## Contributing

If you find a bug or would like to request a new feature, just [open an issue](https://github.com/olexale/bdd_widget_test/issues/new). Your contributions are always welcome!

## License
`bdd_widget_test` is released under a [MIT License](https://opensource.org/licenses/MIT). See `LICENSE` for details.
