import 'dart:typed_data';

Future<bool> fileExists(String path) async => false;
Future<Uint8List> readFileBytes(String path) async =>
    throw UnsupportedError('Not available on web');
Future<void> deleteFileIfExists(String path) async {}
