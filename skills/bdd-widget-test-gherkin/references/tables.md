# Tables in bdd_widget_test

A table under a step repeats the step when the step has `<placeholders>` and the header row names
all of them. Any other table is passed to the step as a `bdd.DataTable` argument.

## 1. Repeating a step

```gherkin
When I enter <input> into <field> input field
  | input      | field |
  | '42'       | 0     |
  | 'question' | 1     |
```

generates the same calls as:

```gherkin
When I enter {'42'} into {0} input field
And I enter {'question'} into {1} input field
```

- Header cells are plain names that match the placeholders. Body cells are Dart expressions.

## 2. DataTable argument

```gherkin
Given available songs
  | 'artist'      | 'name'                      |
  | 'The Doors'   | 'Riders on the storm'       |
  | 'Bob Dylan'   | "Knockin' On Heaven's Door" |
```

- The table is emitted as `const bdd.DataTable([['artist', 'name'], ['The Doors', ...], ...])`.
  **Every cell, header included, is a Dart expression inside a `const` list.** Quote strings, and
  use only constant expressions (literals, `const` values, enum values).
- The step function gets a trailing `bdd.DataTable dataTable` parameter, after any `{}`
  parameters. `dataTable.asLists()` returns every row, header included. `dataTable.asMaps()` uses
  the first row as keys and returns the remaining rows:

  ```dart
  import 'package:bdd_widget_test/data_table.dart' as bdd;
  import 'package:flutter_test/flutter_test.dart';
  import 'package:my_app/songs/song.dart';

  import '../helpers/fakes.dart';

  /// Usage: available songs
  Future<void> availableSongs(WidgetTester tester, bdd.DataTable dataTable) async {
    fakeSongRepository.songs = [
      for (final row in dataTable.asMaps())
        Song(artist: row['artist'] as String, name: row['name'] as String),
    ];
  }
  ```

- Inside a `Scenario Outline`, `<placeholders>` in data table cells are replaced by the raw example
  value.

## Choosing between them

- Same action with different inputs → repeat the step (or use a `Scenario Outline` when the whole
  scenario repeats).
- Domain data to set up or compare (a list of records) → DataTable.
