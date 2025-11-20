import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

Future<void> main() async {
  // 👇 Change this to your WAV file path
  const inputPath = "/Users/sarabjeetsingh/Desktop/audios_test/session_7e7b2bf4-68d7-40f8-8807-6ec927b4d1dd_q_dd297a63-89ed-4c0b-97f3-8223bc2f922a.wav";
  const outputPath = "/Users/sarabjeetsingh/Desktop/audios_test/restored.wav";
  const base64Path = "/Users/sarabjeetsingh/Desktop/audios_test/restored.b64";
  // 1. Read original file as bytes
  Uint8List originalBytes = await File(inputPath).readAsBytes();
  print("Original file size: ${originalBytes.length} bytes");

  // 2. Convert bytes -> Base64 string
  String base64Str = base64Encode(originalBytes);

  // Save Base64 string to file
  await File(base64Path).writeAsString(base64Str);
  print("Base64 saved at $base64Path");


  print("Base64 length: ${base64Str.length}");

  // 3. Convert Base64 string -> bytes
  Uint8List decodedBytes = base64Decode(base64Str);
  print("Decoded size: ${decodedBytes.length} bytes");

  // 4. Write decoded bytes back to new WAV file
  await File(outputPath).writeAsBytes(decodedBytes);
  print("Restored file written: $outputPath");

  // 5. Verify equality
  bool isSame = originalBytes.length == decodedBytes.length &&
      _compareBytes(originalBytes, decodedBytes);
  print("Files identical? $isSame ✅");
}

/// Utility to compare two byte lists
bool _compareBytes(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
