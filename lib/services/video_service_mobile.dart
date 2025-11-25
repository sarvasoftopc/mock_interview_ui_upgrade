import 'dart:typed_data';

class VideoService {
  Future<void> initCamera() async {}
  Future<void> startRecording() async {}
  Future<Uint8List> stopRecording() async => Uint8List(0);
  Future<void> dispose() async {}
  Future<void> disposeCamera() async {}
  get webStream => null;
  get mobileController => null;
  String toWebDataUri(Uint8List bytes) => "";
}
