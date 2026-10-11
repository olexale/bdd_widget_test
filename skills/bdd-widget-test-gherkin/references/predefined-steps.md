# Predefined steps

When one of these steps first appears in a feature file, `bdd_widget_test` generates it with a
working implementation, not an `UnimplementedError` stub. Write the step text so it maps to the same
function name, and pass parameters in the same order and of the same type.

The generated file then belongs to the project, and the project may have changed it. Before relying
on the behaviour described below, read the step file in the project's step folder.

| Step text | Function | Parameters | What it does |
| --- | --- | --- | --- |
| `the app is running` | `theAppIsRunning` | — | `tester.pumpWidget(MyApp())`, importing `package:<app>/main.dart` |
| `I see {'text'} text` | `iSeeText` | `String` | `find.text` → `findsOneWidget` |
| `I don't see {'text'} text` | `iDontSeeText` | `String` | `find.text` → `findsNothing` |
| `I see multiple {'text'} texts` | `iSeeMultipleTexts` | `String` | `find.text` → `findsWidgets` |
| `I tap {'text'} text` | `iTapText` | `String` | taps `find.text`, then `pump()` |
| `I see {'text'} rich text` | `iSeeRichText` | `String` | `RichText` whose plain text equals the value → one |
| `I don't see {'text'} rich text` | `iDontSeeRichText` | `String` | same finder → `findsNothing` |
| `I see {Icons.add} icon` | `iSeeIcon` | `IconData` | `find.byIcon` → `findsOneWidget` |
| `I don't see {Icons.add} icon` | `iDontSeeIcon` | `IconData` | `find.byIcon` → `findsNothing` |
| `I tap {Icons.add} icon` | `iTapIcon` | `IconData` | taps `find.byIcon`, then `pump()` |
| `I see {SomeWidget} widget` | `iSeeWidget` | `Type` | `find.byType` → `findsOneWidget` |
| `I don't see {SomeWidget} widget` | `iDontSeeWidget` | `Type` | `find.byType` → `findsNothing` |
| `I see multiple {SomeWidget} widgets` | `iSeeMultipleWidgets` | `Type` | `find.byType` → `findsWidgets` |
| `I see exactly {4} {SomeWidget} widgets` | `iSeeExactlyWidgets` | `int`, `Type` | `find.byType(skipOffstage: false)` → `findsNWidgets` |
| `I enter {'text'} into {0} input field` | `iEnterIntoInputField` | `String`, `int` | `enterText` into the n-th `TextField` (0-based) |
| `I see enabled elevated button` | `iSeeEnabledElevatedButton` | — | the first `ElevatedButton` is enabled |
| `I see disabled elevated button` | `iSeeDisabledElevatedButton` | — | the first `ElevatedButton` is disabled |
| `I wait` | `iWait` | — | `pumpAndSettle()` |
| `I dismiss the page` | `iDismissThePage` | — | `pageBack()`, then `pumpAndSettle()` |

Notes:

- `iTapText` and `iTapIcon` call `pump()` but not `pumpAndSettle()`. After a tap that starts an
  animation or navigation, follow with `And I wait` before asserting.
- `I see disabled elevated button` and `I see enabled elevated button` take no parameter and check
  only the first `ElevatedButton` on screen. With several buttons, write a project step that finds
  the button by label instead.
- Function names ignore parameter position and the keyword, so `Then I see text {'0'}` also calls
  `iSeeText`.
