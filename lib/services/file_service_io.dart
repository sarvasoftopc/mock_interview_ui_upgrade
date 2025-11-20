import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileServiceImpl {
  Future<String> saveAudio(String sessionId, String questionId, List<int> bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final filename = 'session_${sessionId}_q_${questionId}.wav';
    print("stored file name:"+filename);
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<List<int>> readAudio(String path) async {
    final file = File(path);
    return await file.readAsBytes();
  }

  Future<void> delete(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
