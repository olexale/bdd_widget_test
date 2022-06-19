import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/foundation.dart';

@visibleForTesting
FileSystem? fsInstance;

FileSystem get fs => fsInstance ??= const LocalFileSystem();
