---
name: bdd-widget-test-gherkin
description: Write `.feature` files and implement step definitions for the bdd_widget_test package, which generates Flutter widget tests from Gherkin. Use when the user is creating or changing feature files, scenarios or steps in a Flutter project that depends on bdd_widget_test, filling in generated step files, sharing steps between features, packages or integration tests, configuring `build.yaml` / `bdd_options.yaml` for bdd_widget_test, or setting up golden or Patrol tests with it.
---

# bdd_widget_test

## How generation works

1. Every `*.feature` file under `test/` (or `integration_test/`) is parsed with the official Gherkin
   parser (`cucumber_gherkin`), plus a few package extensions described below.
2. `dart run build_runner build --delete-conflicting-outputs` (or `watch`) writes a `*_test.dart`
   file next to each feature. **That file is regenerated on every build. Never edit it.** The build
   also validates the feature file: invalid Gherkin fails with file, line and column.
3. Every step becomes a call to a top-level function in a step file,
   `<step folder>/<snake_case_name>.dart`. For a step with no file yet, the build writes a stub that
   throws `UnimplementedError`, or a working implementation for a
   [predefined step](references/predefined-steps.md).
4. **Step files are never overwritten.** Once a file exists, the generator only imports it. The
   project owns it and edits it freely.
5. Run the tests with `flutter test` (or `flutter test integration_test`).

## Writing feature files

### Before writing a step

- **Always reuse an existing step before inventing one.** List the step folder first (`test/step/`
  next to the feature by default, or the folder set by `stepFolderName` in `build.yaml` /
  `bdd_options.yaml`), check `externalSteps` in the same config, and check the
  [predefined steps](references/predefined-steps.md). Phrase the new step so it maps to the same
  function name.
- A step is identified by its **function name only**. The name is built from the step text with
  `{}` parameters and `<placeholders>` removed, accents folded to ASCII, punctuation dropped, and
  the rest camel-cased. The keyword (`Given`/`When`/`Then`/`And`/`But`/`*`) is ignored.
  - `Then I see {'0'} text` → `iSeeText` in `i_see_text.dart`
  - `Then I don't see {'x'} text` → `iDontSeeText` (`'` is dropped)
  - `When I tap {Icons.add} icon <times> times` → `iTapIconTimes`
  - `Given I see text {'0'}` is the **same** step as `I see {'0'} text`, since both are `iSeeText`.
    So the parameters must line up with that function's signature.
- Two phrasings that differ only in articles or word order are **different** steps
  (`I see the text` → `iSeeTheText`). Don't write near-duplicates.
- Never write a step whose text, with parameters removed, has no ASCII letter or digit, starts with
  a digit (`2FA is on`), or starts with `_`. Never write a step made only of a parameter. All of
  these fail the build.

### Parameters: `{}` holds Dart code

- Whatever is inside `{...}` is copied into the generated test **verbatim as a Dart expression**.
  - Strings need quotes: `{'Login'}` or `{"Don't panic"}`. `{Login}` is an identifier, not a string.
  - Numbers, booleans, types and constants are used as-is: `{42}`, `{true}`, `{Icons.add}`,
    `{LoginButton}`.
- If a parameter references a symbol the default imports (`material.dart`, `flutter_test.dart`)
  don't cover, add the Dart `import` above `Feature:`, or configure `customHeaders`.
- Prefer domain-level parameters (`{'alice@example.com'}`) over implementation details such as keys
  or private widget types. Steps describe what a user does and sees.

### Structure

- Scenarios become `testWidgets`, and `Feature:` and `Rule:` become `group`s.
- `Given` arranges, `When` acts, `Then` asserts. The keyword doesn't change which function is called.
- `Background:` runs before each scenario of its feature. A `Background:` inside a `Rule:` runs
  after the feature's background, only for that rule's scenarios. Only one `Background:` is allowed
  per feature or rule.
- `Scenario Outline:` / `Scenario Template:` must have `Examples:` / `Scenarios:`. Example cells are
  Dart too. A `<placeholder>` outside `{}` is substituted as `{value}`, and one inside `{}` is
  substituted raw. So `| result |` with a cell `'0'` passes a String, and `0` passes a number.
- **Proofread the top of each block.** Gherkin reads every line between `Feature:`/`Rule:`/
  `Scenario:` and the block's first step as description text. A mistyped keyword there
  (`Scenrio:`, `Gven the app is running`) is silently dropped along with its steps. Below the first
  step, typos fail the build with file, line and column.

### Tables under a step: two meanings

Read [tables.md](references/tables.md) before putting a table under a step.

- **Repeat the step**: if the step contains `<placeholders>` and the table's header row names *all*
  of them, the step is generated once per row.
- **DataTable argument**: any other table is passed as a `bdd.DataTable` parameter. **Every cell is
  a Dart expression**, so quote strings in every row, the header included:
  `| 'artist' | 'name' |`.
- Doc strings (`"""`) are parsed but ignored, so don't use them to pass data.

### Tags

- Tags filter runs (`flutter test --tags important`) and are inherited from `Feature:` and `Rule:`
  by their scenarios. Plain tags may share a line: `@slow @integration`.
- The package's own value tags go **on their own line**, because their value runs to the end of the
  line and swallows any tag written after it: `@testMethodName: testGoldens`,
  `@testerType: PatrolIntegrationTester`, `@testerName: $`,
  `@scenarioParams: nativeAutomation: true`. Put them above `Feature:` to apply them to the whole
  file, or above one scenario to apply them to that scenario only.
  - `@testMethodName: testGoldens` makes the scenario call `testGoldens(...)` instead of
    `testWidgets(...)`.
  - `@testerType:` and `@testerName:` change the tester parameter's type and name, in both the test
    and newly generated step stubs.
  - `@scenarioParams:` takes comma-separated named arguments, which are appended to the test method
    call, e.g. `@scenarioParams: skip: true, timeout: Timeout(Duration(seconds: 5))`. The value is
    split into arguments at every `, ` (comma followed by a space), so no single argument may
    contain `, `. Write inner commas without the space: `size: Size(400,800)`.

### Package extensions

Use these freely:

- `After:` under `Feature:` lists steps that run after every scenario of that feature, inside a
  `finally`, so they run even when the scenario fails. Writing it inside a `Rule:` does not scope
  it to that rule. It still runs after every scenario of the feature.
- Dart lines above `Feature:` are copied to the top of the generated test. Use them for imports
  needed by `{}` parameters and for `// ignore_for_file:` lint suppressions.
- A file may hold several `Feature:`s.
- Value tags and tables that repeat a step, both described above.

### Languages

- To write keywords in another language, put `# language: xx` above the first feature keyword
  (below Dart header lines is fine). Step text stays free-form, but its function name is still built
  from its ASCII characters, so keep some ASCII words in every step. `After:` stays in English.

## Implementing steps

### Step files

- One step means one file and one top-level `Future<void>` function. The file name is the snake-case
  form of the function name: `iSeeText` lives in `i_see_text.dart`. **Keep both names.** The
  generator finds existing steps by file name and calls them by function name, so renaming either
  breaks the generated tests.
- You may move step files into subfolders of the step folder (`step/common/`, `step/login/`). The
  generator searches the step folder recursively and imports from the new location. Step file
  names must be unique across the whole step folder. Two files with the same name in different
  subfolders collide silently, and the last one found wins.
- Never delete a step file to "regenerate" it if it has an implementation. Edit it instead.
- The signature is `(WidgetTester tester, ...params)`. The generated test passes one argument per
  `{}` parameter and per `<placeholder>`, **in the order they appear in the step text**, then
  `bdd.DataTable dataTable` last if a DataTable is written under the step.
  - Stubs list the `{}` parameters first and the `<placeholder>` ones after them. When a placeholder
    comes before a `{}` parameter in the text (`I add <count> items to {'Cart'}`), the stub's
    parameter order doesn't match the call, so reorder the parameters to follow the text.
- Stubs type literal parameters as `String`, `num` or `bool`, and everything else as `dynamic`.
  **Tighten the types** (`int`, `IconData`, `Type`, a domain enum) when implementing the step. The
  generated test passes the raw Dart expression, so any type that expression satisfies works.
- Keep the doc comment at the top of a generated step (`/// Usage:` in stubs, `/// Example:` in
  predefined steps). It records the step text the function was made for.
- If the step's text in the `.feature` file changes, the generator creates a new stub for the new
  name. Rename the old file and function to match instead of keeping both.

### Implementing

- Steps drive the UI through the tester the way a user would: `tester.tap`, `tester.enterText`,
  `tester.drag`, then `tester.pump()` or `tester.pumpAndSettle()`. Assert with
  `expect(find..., matcher)`.
- After an action, pump. Use `pumpAndSettle()` for navigation and animations. Use `pump()` or
  `pump(duration)` when something animates forever (progress indicators), because
  `pumpAndSettle()` would time out.
- Keep steps small and reusable. A step may call another step function (`iTapIconTimes` calling
  `iTapIcon`). Put shared finders, fakes and setup code in plain helper files outside the step
  folder (e.g. `test/helpers/`) and import them. The generator treats every `.dart` file under the
  step folder as a step by its file name, so a helper there can shadow a step.
- `the app is running` is generated to pump `MyApp()` from `package:<app>/main.dart`. Change it to
  build the real root widget, inject fakes or mocks, and wrap it in whatever providers the app
  needs.
- Per-test state (fakes, repositories) can live in top-level variables in a helper file that is
  reset in a `Given` step or in `Hooks.beforeEach`.
- For DataTable steps, see [tables.md](references/tables.md).

### Configuration and recipes

Options go under `bdd_widget_test|featureBuilder` in `build.yaml`, or at the top level of
`bdd_options.yaml` in the package root. After changing them, rebuild with
`--delete-conflicting-outputs`.

- Read [configuration.md](references/configuration.md) for every option (step folder location,
  external steps, hooks, tester type and name, custom headers) and the step lookup order.
- Read [recipes.md](references/recipes.md) for hooks, golden tests, integration tests, Patrol, and
  steps shared between packages.

## Examples

A feature with a background, an `After:` block and an outline:

```gherkin
import 'package:my_app/cart/cart_icon.dart';

Feature: Shopping cart

  Background:
    Given the app is running
    And I am signed in as {'alice@example.com'}

  After:
    Then I clear the cart

  Scenario: Empty cart shows a hint
    When I tap {CartIcon} widget
    Then I see {'Your cart is empty'} text

  Scenario Outline: Adding items updates the badge
    When I add {'Coffee'} items <count> times
    Then I see {CartIcon} badge with <badge>

    Examples:
      | count | badge |
      | 1     | '1'   |
      | 12    | '9+'  |
```

Rules with their own background, and a scenario-level tag:

```gherkin
@checkout
Feature: Checkout

  Background:
    Given the app is running

  Rule: Payment requires an address

    Background:
      Given my cart contains {'Coffee'}

    Scenario: Pay button is disabled without an address
      Then I see disabled elevated button

    @testMethodName: testGoldens
    Scenario: Address form matches the golden
      When I tap {'Add address'} text
      Then the screen matches {'address_form'} golden
```

Data tables, one repeating a step and one passed as an argument:

```gherkin
import 'package:my_app/songs/song_tile.dart';

Feature: Search

  Scenario: Filling the form
    Given the app is running
    When I enter <text> into <index> input field
      | text      | index |
      | 'Doors'   | 0     |
      | 'Riders'  | 1     |
    Then I see {'2 results'} text

  Scenario: Results match the catalog
    Given available songs
      | 'artist'    | 'name'                |
      | 'The Doors' | 'Riders on the storm' |
      | 'Bob Dylan' | "Knockin' On Heaven's Door" |
    And the app is running
    When I search for {'door'}
    Then I see exactly {2} {SongTile} widgets
```

Common mistakes to avoid:

```gherkin
# BAD: unquoted string, so `Login` is read as a Dart identifier
When I tap {Login} text
# GOOD
When I tap {'Login'} text

# BAD: unquoted DataTable cells don't compile
Given available songs
  | artist    | name      |
  | The Doors | Riders    |

# BAD: value tag first, so `@slow` becomes part of the method name
@testMethodName: testGoldens @slow
# GOOD
@slow
@testMethodName: testGoldens
```

A stub as generated for `When I add {'Coffee'} items {3} times`:

```dart
import 'package:flutter_test/flutter_test.dart';

/// Usage: I add {'Coffee'} items {3} times
Future<void> iAddItemsTimes(WidgetTester tester, String param1, num param2) async {
  throw UnimplementedError();
}
```

The same step implemented, with types and names tightened:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Usage: I add {'Coffee'} items {3} times
Future<void> iAddItemsTimes(
  WidgetTester tester,
  String product,
  int count,
) async {
  final addButton = find.descendant(
    of: find.widgetWithText(ListTile, product),
    matching: find.byIcon(Icons.add),
  );
  for (var i = 0; i < count; i++) {
    await tester.tap(addButton);
    await tester.pump();
  }
}
```

`the app is running`, adapted to a real app:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/app.dart';

import '../helpers/fakes.dart';

Future<void> theAppIsRunning(WidgetTester tester) async {
  await tester.pumpWidget(App(songRepository: fakeSongRepository));
  await tester.pumpAndSettle();
}
```
