import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';

@visibleForTesting
FileSystem? fsInstance;

FileSystem get fs => fsInstance ??= const LocalFileSystem();
