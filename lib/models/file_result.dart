class FileResult {
  late String _fileName;

  late String _text;
  String get fileName => _fileName;

  set fileName(String value) {
    _fileName = value;
  }


  String get text => _text;

  set text(String value) {
    _text = value;
  }
}