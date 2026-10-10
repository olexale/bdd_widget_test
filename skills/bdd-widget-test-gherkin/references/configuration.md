# bdd_widget_test configuration

Options can go in two places.

In `build.yaml`:

```yaml
targets:
  $default:
    builders:
      bdd_widget_test|featureBuilder:
        options:
          stepFolderName: step
```

Or at the top level of `bdd_options.yaml` in the package root:

```yaml
stepFolderName: step
```

If both exist, they are merged:

- String options: a non-default value in `build.yaml` wins over `bdd_options.yaml`, which wins over
  the files it includes.
- Boolean options: `addHooks: true` from any source wins, and `relativeToTestFolder: false` and
  `includeIntegrationTestBinding: false` from any source win. A shared options file can therefore
  turn these off, and `build.yaml` cannot turn them back on.
- List options (`externalSteps`, `customHeaders`) are concatenated. Rebuild with
`dart run build_runner build --delete-conflicting-outputs` after any change.

| Option | Default | Meaning |
| --- | --- | --- |
| `stepFolderName` | `./step` | Where step files are looked up and created. `./x` or `../x` is relative to each feature file. A bare name (`step`, `bdd_steps`) is one shared folder under `test/` (or under the package root, see below). |
| `relativeToTestFolder` | `true` | With `false`, a bare `stepFolderName` or `hookFolderName` is resolved from the package root, e.g. `integration_test/steps`. |
| `externalSteps` | `[]` | `package:` URIs of step files in other packages. A step whose file name matches is imported from there instead of being generated. |
| `include` | — | A `package:` URI or a path relative to the package root (or a list of them) of another `bdd_options.yaml` to merge in. Includes can be nested. |
| `addHooks` | `false` | Generate a `hooks.dart` file with a `Hooks` class and call it from every test. |
| `hookFolderName` | `./hook` | Where `hooks.dart` lives. Resolved the same way as `stepFolderName`. |
| `testMethodName` | `testWidgets` | The function each scenario is generated as, e.g. `testGoldens` or `patrolTest`. Overridden per feature or scenario by `@testMethodName:`. |
| `testerType` | `WidgetTester` | The tester parameter's type in tests and new stubs. Overridden by `@testerType:`. |
| `testerName` | `tester` | The tester parameter's name. Overridden by `@testerName:`. |
| `includeIntegrationTestBinding` | `true` | For features under `integration_test/` (when `integration_test` is a dev dependency), call `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`. Set it to `false` for Patrol 3+. A `false` from any source wins. |
| `customHeaders` | `[]` | Lines that replace the default imports at the top of generated tests and new generic step stubs (after the DataTable import). Include `flutter_test` yourself when you set this. Predefined step files ignore it and always import `flutter_test`. |

## Step lookup order

For each step, the generator:

1. uses a file with the step's name anywhere under the step folder (searched recursively),
2. otherwise uses an `externalSteps` entry whose path contains that file name,
3. otherwise creates a new file in the step folder: a predefined implementation or an
   `UnimplementedError` stub.
