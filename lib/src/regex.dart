final parametersRegExp = RegExp(r'\{(.*?)\}', caseSensitive: false);
final charactersAndNumbersRegExp = RegExp(r'[^\w\s\d]+');
final repeatingSpacesRegExp = RegExp(r'\s+');
final parametersValueRegExp = RegExp(r'(?<=\{).+?(?=\})', caseSensitive: false);
