## [1.8.1] - Fix hook path on windows

* Fix hook path on windows
* Update README - Replace Ruby syntax with Gherkin syntax (by @lsaudon)

## [1.8.0] - Dependency updates

* Update `dart_style` constraint to `^3.0.0`

## [1.7.6] - Add relativeToTestFolder

* Add `relativeToTestFolder` option to control the generated step file location

## [1.7.5] - Generic step generation fix

* Fix generic step generation when parameters combined with data tables

## [1.7.4] - Code formatting

* Generated code is now properly formatted

## [1.7.3] - Integration test improvements

* Integration test imports will not be added if `integration_test` package is not added to `dev_dependencies`
* `IntegrationTestWidgetsFlutterBinding.ensureInitialized();` will not be added if `integration_test` package is not added to `dev_dependencies`

## [1.7.2] - Hotfix release for broken comments

* In the previous release, comments were broken. This release fixes the issue.

## [1.7.1] - Fix tags

* Fix tags when specified in the header
* Skip duplicated empty lines in the header

## [1.7.0] - Option to disable IntegrationTestBinding inclusion

* Update dependencies (by @lsaudon)
* Add includeIntegrationTestBinding option to control `IntegrationTestWidgetsFlutterBinding.ensureInitialized();` (by @eikebartels)
* Fix data tables in background/after

## [1.6.4] - Gherkin compliance

* Add hooks (by @daniel-deboeverie-lemon)
* Add Cucumber data table support (by @ron-brosh)

## [1.6.3] - Generic step usage comment (by @lsaudon)

* Add a comment to the generated step implementation to show how to use the generated step

## [1.6.2] - Generic step generation improvement (by @lsaudon)

* Automatically detect parameter names in scenario outlines
* Audomatically detect parameter types in regular scenarios

## [1.6.1] - Allow custom tester type, name and scenario parameters (by @mkhtradm01)

* Allow addition of custom tester type from other test packages using `@testerType:` tag the value can be like `PatrolIntegrationTester` instead of `WidgetTester`(default) 
* Allow addition of custom tester name using `@testerName:` tag, the value can be like `$`, `integrationTest` instead of `tester` leaving `tester`(default)
* Allow passing scenario parameters using `@scenarioParams:` tag, for example: `@scenarioParams: skip: false, timeout: Timeout(Duration(seconds: 1))` and many more. 
* Though these additions do not affect predefined steps.
  
## [1.6.0] - Change step folder destination

* **BREAKING CHANGE** - Introduce relative and absolute paths for step folder destination
If you didn't change the step folder name, you should not notice this change. However, if you changed it to a non-relative path (like `my_steps`), from now, the plugin will create a `test/my_steps` folder. To prevent this behavior - make the step folder name relative, i.e. to `./my_steps`.

## [1.5.1] - Bugfix

* Fix Background/After sections for files with multiple features defined

## [1.5.0] - Bugfix and new SDK constraints

* Fix bug for feature tags (by @GuillaumeMorinQc)
* Apply stricter linter
* Update Dart SDK constraints

## [1.4.3] - Multiple includes

* Add multiple includes to the config file

## [1.4.2] - Nested brackets

* Fix nested brackets bug

## [1.4.1] - Code coverage

* 100% code coverage

## [1.4.0] - 'After' block improvement

* BREAKING CHANGE - Make 'After' block execute even when the test fails (by @jamontes79)

## [1.3.2] - Add diacritics support

* Add diacritics support (thanks @vidibu)

## [1.3.1] - Add tags

* Add tags

## [1.3.0] - Add bdd_options.yaml

* Add possibility to store config outside of `build.yaml`. Now we may re-use the same config (for example `external_steps`) across different packages.

## [1.2.1] - Data Tables

* Add data tables support

## [1.2.0] - Scenario Outline

* Add scenario outline support

## [1.1.0] - Integration tests

* Add support for integration tests

## [1.0.3+1] - Custom step folder name hotix

* Hotfix for ".." in custom step names

## [1.0.3] - Custom step folder name

* Add `stepFolderName` parameter that changes the step folder name

## [1.0.2] - Update dependencies

* Update plugin's dependencies
* Fix the "I dismiss the page" step

## [1.0.1] - Tags

* Add `testMethodName` tag

## [1.0.0] - Null safety

* Migrate to null safety

## [0.7.1] - Hotfix

* External steps should have lower priority than local steps

## [0.7.0] - External steps and build.yaml settings

* Implement external steps
* Add a bunch of predefined external steps
* Add possibility to change `testMethodName` in `build.yaml`

## [0.6.1] - Background/After fix

* Fix paramteres in Background/After sections

## [0.6.0] - Background/After refactoring

* Before and After sections do not rely on default `setUp()` and `tearDown()` methods
* Add a `tester` parameter to Before and After sections

## [0.5.0] - Subfolders

* Now it's possible to have subfolders in the `step` folder

## [0.1.7] - Internal release

* Use `extra_pedantic` 
* Update dependencies

## [0.1.6] - 'After' keyword

* Add `After` keyword
* avoid avoid_types_on_closure_parameters (by @kentcb)

## [0.1.5] - Windows-friendly build

* Fix code generation on Windows (by @kentcb)

## [0.1.4] - More Gherkin keywords

* Minor bug fixes
* Add more Tap events
* Add 'I Wait' step

## [0.1.3] - More Gherkin keywords

* Add `Background` keyword
* Add `directives_ordering` linter exception

## [0.1.2] - More Gherkin keywords

* Add `Example` and `But` keywords

## [0.1.1] - Hotfix

* Fix regular expressions for parameters parsing

## [0.1.0] - First release

* Basic feature and steps generation
* A few most common pre-built steps added
