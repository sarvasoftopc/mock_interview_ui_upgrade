

class FileServiceImpl {
  Future<String> saveAudio(String sessionId, String questionId, List<int> bytes) async {
    throw UnimplementedError('FileService.saveAudio is not implemented on Web. Use server upload instead.');
  }

  Future<List<int>> readAudio(String path) async {
    throw UnimplementedError('FileService.readAudio is not implemented on Web.');
  }

  Future<void> delete(String path) async {
    throw UnimplementedError('FileService.delete is not implemented on Web.');
  }
}
