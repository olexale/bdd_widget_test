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
