import 'dart:io';
import 'dart:typed_data';

Future<bool> fileExists(String path) async {
  if (path.isEmpty) return false;
  return File(path).exists();
}

Future<Uint8List> readFileBytes(String path) async {
  return await File(path).readAsBytes();
}

Future<void> deleteFileIfExists(String path) async {
  final f = File(path);
  if (await f.exists()) await f.delete();
}
