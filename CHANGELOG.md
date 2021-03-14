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
