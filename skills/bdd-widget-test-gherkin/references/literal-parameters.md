# Literal parameters (`literalParameters: true`)

With this option on, two more spellings are parameters, next to `{}`. The generator rewrites them
into `{}` before anything else reads the step, so they behave exactly like the `{}` form.

| Write | Same as | Call |
| --- | --- | --- |
| `Then I see "Hello" text` | `Then I see {'Hello'} text` | `iSeeText(tester, 'Hello')` |
| `Given the counter is 42` | `Given the counter is {42}` | `theCounterIs(tester, 42)` |

The option is off by default. Check `build.yaml` and `bdd_options.yaml` (and the files they include)
before writing steps this way. With it off, `"Hello"` and `42` are part of the step name
(`iSeeHelloText`, `theCounterIs42`).

## Rules

- **Strings**: only double quotes. The content is text, not Dart. `$`, `'`, `\`, `{` and `}`
  arrive as written. The two escapes are `\"` (a quote) and `\\` (a backslash). The stub infers
  `String`.
- **Numbers**: a whole word only, optionally with a leading `-` and one decimal part: `42`, `-3`,
  `1.5`. Not numbers: `2FA`, `v1`, `1.0.1`, `19-20`, `1,000`, `1,5`, `1:30`, `1/2`, `1'000`,
  `3’000`, `1e3`, `.5`, `+7`, `3.`. The stub infers `num`.
- `{}` is untouched, quotes inside it included. Use it for anything else: `{Icons.add}`, `{true}`,
  `{const Duration(seconds: 1)}`.
- An unclosed `"` fails the build with file, line and column.
- A step that is nothing but literals (`Then "Hello"`) has no name and fails the build.

## Outlines

`Then I see "<greeting>" text` passes each row's cell as a string, and the stub gets one
`String param1`. The cell is plain text, like the quoted string it sits in: `Don't panic`,
`cost $5` and `C:\temp` arrive as written. The same holds for a placeholder inside a string in `{}`
(`{'<greeting>'}`), but only with the option on. With it off, such a cell is copied into the Dart
literal unchanged, so `'` must be written `\'`. For a non-string value, use `{<greeting>}` and write
the cell as Dart (`{<count>}` with `3`, or `'it\'s'` for a string).

## Turning it on in an existing project

The option renames every step whose text contains a quoted string or a whole-word number. Step files
are never overwritten, so:

1. Rebuild with `--delete-conflicting-outputs`.
2. Steps that now match a predefined step (`iSeeText`, `iTapText`, …) get the predefined
   implementation. Other renamed steps get a new stub throwing `UnimplementedError`: move the old
   implementation into it.
3. Delete the old step files nothing imports any more (`i_see_hello_text.dart`).

## Compile errors to expect

The generator doesn't check signatures, so these surface as Dart errors in generated files, the same
as with `{}`:

- Two spellings that share a name with different parameter counts in one project: `I see text` and
  `I see "Hello" text` are both `iSeeText`. Rename one.
- A literal that turns a step into a predefined one with another signature: `I see 1 widget`
  becomes `iSeeWidget`, which takes a `Type`, and `I wait 2` becomes `iWait`, which takes nothing.
  Rephrase the step or write the value in `{}`.
