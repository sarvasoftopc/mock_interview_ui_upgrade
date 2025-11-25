// lib/utils/file_util.dart
library;

// Conditional export: use `file_util_impl_web.dart` when compiling for web,
// otherwise use `file_util_impl_io.dart`.
export 'file_util_impl_io.dart'
    if (dart.library.html) 'file_util_impl_web.dart';
