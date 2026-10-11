# bdd_widget_test recipes

## Hooks

```yaml
# build.yaml → bdd_widget_test|featureBuilder → options
addHooks: true
hookFolderName: bdd_hooks   # optional: one shared folder instead of ./hook per feature dir
```

This generates the following file once. The project owns it afterwards:

```dart
import 'dart:async';

abstract class Hooks {
  const Hooks._();
  static FutureOr<void> beforeEach(String title, [List<String>? tags]) {}
  static FutureOr<void> beforeAll() {}
  static FutureOr<void> afterEach(String title, bool success, [List<String>? tags]) {}
  static FutureOr<void> afterAll() {}
}
```

- `beforeAll` and `afterAll` run once per feature file (`setUpAll`/`tearDownAll`).
- `beforeEach` and `afterEach` run around every scenario. `afterEach` runs even on failure and
  receives `success`.
- For cleanup specific to one feature, an `After:` block in that feature file is simpler.

## Golden tests

Pick the narrowest scope:

- One scenario: put `@testMethodName: testGoldens` on its own line above `Scenario:`.
- A whole file (every `Feature:` in it): put the same tag above `Feature:`.
- Every test: set `testMethodName: testGoldens` in options.

Then implement a step such as `Then the screen matches {'name'} golden` with the golden package's
API, and add the golden package's import to that step file. Dart lines above `Feature:` reach only
the generated test, not step files. `customHeaders` also covers step stubs, but only ones generated
after it was configured.

## Integration tests

1. Add `integration_test: {sdk: flutter}` to `dev_dependencies`.
2. Let `build_runner` see the folder:

   ```yaml
   targets:
     $default:
       sources:
         - integration_test/**
         - test/**
         - lib/**
         - $package$
   ```

3. To share steps between widget and integration tests, use one bare step folder,
   `stepFolderName: step` (it resolves to `test/step` for both). To keep integration steps
   separate, use `relativeToTestFolder: false` with `stepFolderName: integration_test/steps`.
4. Put the `.feature` files in `integration_test/` and run `flutter test integration_test`.

## Patrol

```yaml
# build.yaml → bdd_widget_test|featureBuilder → options, or top level of bdd_options.yaml
testMethodName: patrolTest
testerName: $
testerType: PatrolIntegrationTester
includeIntegrationTestBinding: false   # Patrol 3+ must not call ensureInitialized
customHeaders:
  - "import 'package:flutter_test/flutter_test.dart';"
  - "import 'package:patrol/patrol.dart';"
```

- Steps then take `PatrolIntegrationTester $` and use Patrol finders (`await $('Login').tap();`).
- Turn on native automation per scenario with
  `@scenarioParams: nativeAutomation: true` on its own line.
- To use Patrol for only some feature files, put the `@testMethodName:`, `@testerType:` and
  `@testerName:` tags above `Feature:` in those files instead of using the global options. The
  tester tags apply to the whole file, so don't mix Patrol and widget-test features in one file.
- Predefined steps are always generated for `WidgetTester`, and they ignore `customHeaders`, so they
  never import Patrol. When `testerType` changes, rewrite them (or supply your own files first) for
  the new tester, and add the Patrol import yourself.

## Sharing steps across packages

In a shared package (e.g. `common_bdd_steps`), put step files under `lib/step/` and publish
`lib/bdd_options.yaml`. A `package:` URI resolves under `lib/`, so a `bdd_options.yaml` in the
package root (where a project's own local config lives) can't be included this way:

```yaml
externalSteps:
  - package:common_bdd_steps/step/i_see_text.dart
  - package:common_bdd_steps/step/i_wait.dart
```

In the consuming app's `bdd_options.yaml` (top-level keys):

```yaml
include: package:common_bdd_steps/bdd_options.yaml
```

or list the `externalSteps` directly. A local step file with the same name takes priority over an
external one.

