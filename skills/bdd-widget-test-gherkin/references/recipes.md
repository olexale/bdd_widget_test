# bdd_widget_test recipes

## Hooks

```yaml
# build.yaml → bdd_widget_test|featureBuilder → options
addHooks: true
hookFolderName: bdd_hooks   # optional: one shared folder instead of ./hook per feature dir
```

This generates the following file once. The project owns it afterwards:

```dart
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
- A whole feature: put the same tag above `Feature:`.
- Every test: set `testMethodName: testGoldens` in options.

Then import the golden package where the steps need it (`customHeaders`, or a Dart line above
`Feature:`). Implement a step such as `Then the screen matches {'name'} golden` with the golden
package's API.

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
options:
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
- To use Patrol for only some features, use the `@testMethodName:`, `@testerType:` and
  `@testerName:` tags on those features instead of the global options.
- Predefined steps are always generated for `WidgetTester`, and they ignore `customHeaders`, so they
  never import Patrol. When `testerType` changes, rewrite them (or supply your own files first) for
  the new tester, and add the Patrol import yourself.

## Sharing steps across packages

In a shared package (e.g. `common_bdd_steps`), put step files under `lib/step/` and publish a
`bdd_options.yaml`:

```yaml
externalSteps:
  - package:common_bdd_steps/step/i_see_text.dart
  - package:common_bdd_steps/step/i_wait.dart
```

In the consuming app:

```yaml
options:
  include: package:common_bdd_steps/bdd_options.yaml
```

or list the `externalSteps` directly. A local step file with the same name takes priority over an
external one.

