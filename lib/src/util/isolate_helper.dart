import 'dart:isolate';
import 'package:meta/meta.dart';

@visibleForTesting
Future<Uri?> Function(Uri)? resolvePackageUriFactory;

Future<Uri?> Function(Uri) resolvePackageUri =
    resolvePackageUriFactory ??= Isolate.resolvePackageUri;
