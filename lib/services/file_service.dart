// Conditional import pattern: delegate to platform-specific implementation
import 'file_service_io.dart' if (dart.library.html) 'file_service_web.dart' as impl;

class FileService {
  impl.FileServiceImpl _impl = impl.FileServiceImpl();

  Future<String> saveAudio(String sessionId, String questionId, List<int> bytes) {
    return _impl.saveAudio(sessionId, questionId, bytes);
  }

  Future<List<int>> readAudio(String path) {
    return _impl.readAudio(path);
  }

  Future<void> delete(String path) {
    return _impl.delete(path);
  }
}
