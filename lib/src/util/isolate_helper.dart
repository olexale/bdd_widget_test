import 'dart:isolate';

import 'package:flutter/foundation.dart';

@visibleForTesting
Future<Uri?> Function(Uri)? resolvePackageUriFactory;

Future<Uri?> Function(Uri) resolvePackageUri =
    resolvePackageUriFactory ??= Isolate.resolvePackageUri;
