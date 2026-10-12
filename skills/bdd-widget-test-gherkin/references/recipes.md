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

A golden check is an assertion, so use the predefined `Then` step built on Flutter's
`matchesGoldenFile`. The scenario stays a plain `testWidgets` test. Don't change `testMethodName`,
don't wrap the test, and don't add a golden package.

```gherkin
Scenario: Initial counter screen
  Given the app is running
  Then the screen matches golden {'initial_counter'}
```

- `Background:`, `After:` and hooks apply as in any other scenario. Steps before the golden step may
  pump, tap and navigate freely.
- The predefined step captures the whole app (`find.byType(WidgetsApp)`). The image is taken from
  the nearest `RepaintBoundary` at or above the found widget, so finding a smaller widget usually
  still captures the whole screen. To capture one widget, wrap it in a `RepaintBoundary` with a
  `Key` and write a project step that targets the boundary with `find.byKey`.
- The path is resolved relative to the generated `*_test.dart`, not the step file, so goldens land
  in `goldens/` next to the feature. Keep golden names unique among the features of one folder.
- Create or update the images with `flutter test --update-goldens`, then compare with
  `flutter test`. Mismatches write diff images to `failures/` next to the test. Keep that folder
  out of version control.
- By default tests draw every glyph as a box and load no icon fonts, which keeps goldens identical
  on every OS. For real text, load fonts in `test/flutter_test_config.dart`, which runs before
  every test below it. The Flutter SDK ships
  Roboto and Material Icons, which the default Material theme and `Icons` use:

  ```dart
  import 'dart:async';
  import 'dart:io';

  import 'package:flutter/services.dart';
  import 'package:flutter/widgets.dart';

  Future<void> testExecutable(FutureOr<void> Function() testMain) async {
    WidgetsApp.debugAllowBannerOverride = false; // no DEBUG ribbon in goldens
    final dir = '${Platform.environment['FLUTTER_ROOT']}/bin/cache/artifacts/material_fonts';
    final roboto = FontLoader('Roboto');
    final icons = FontLoader('MaterialIcons');
    for (final file in Directory(dir).listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last.toLowerCase();
      final font = Future.value(ByteData.sublistView(file.readAsBytesSync()));
      if (name.startsWith('roboto-')) roboto.addFont(font);
      if (name == 'materialicons-regular.otf') icons.addFont(font);
    }
    await Future.wait([roboto.load(), icons.load()]);
    await testMain();
  }
  ```

  Fonts the app declares in `pubspec.yaml` load the same way from their files. Don't create a
  custom test binding there: it replaces the binding for every test, and `patrolTest` then fails
  to load.
- Real fonts render slightly differently on each OS. Generate and compare goldens on one OS,
  usually the CI's (Linux; on Windows, run them in WSL), or keep one set per OS. For a set per OS,
  wrap the comparator in the same `testExecutable`, before `testMain()`, so every golden gets the OS
  in its path:

  ```dart
  goldenFileComparator = _PerOsComparator(goldenFileComparator);

  /// goldens/home.png -> goldens/macos/home.png
  class _PerOsComparator extends GoldenFileComparator {
    _PerOsComparator(this._delegate);

    final GoldenFileComparator _delegate;

    Uri _perOs(Uri golden) => golden.replace(pathSegments: [
          ...golden.pathSegments.take(golden.pathSegments.length - 1),
          Platform.operatingSystem,
          golden.pathSegments.last,
        ]);

    @override
    Future<bool> compare(Uint8List imageBytes, Uri golden) =>
        _delegate.compare(imageBytes, _perOs(golden));

    @override
    Future<void> update(Uri golden, Uint8List imageBytes) =>
        _delegate.update(_perOs(golden), imageBytes);

    @override
    Uri getTestUri(Uri key, int? version) => _delegate.getTestUri(key, version);
  }
  ```

  It needs `import 'package:flutter_test/flutter_test.dart';`. Wrap the existing comparator rather
  than creating a `LocalFileComparator`: `flutter test` sets one up per test file, relative to it.
  Use `Platform.operatingSystem` (the host), never `defaultTargetPlatform`, which is `android` in
  every widget test. Each OS needs its own `--update-goldens` run; an OS without its set fails with
  "Could not be compared against non-existent file".

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

