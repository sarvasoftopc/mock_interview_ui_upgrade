import 'dart:io';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sarvasoft_moc_interview/models/file_result.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

import '../../generated/l10n.dart';
// plus your other imports...

import '../providers/cv_jd_provider.dart';

class FileUtil {
  // === File readers ===
  static Future<String> readPdfFileFromBytes(List<int> bytes) async {
    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text;
  }

  /// Clears temporary files used by FilePicker
  static Future<void> clearFilePickerCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        final files = tempDir.listSync();
        for (final file in files) {
          // Only delete files that were likely created by FilePicker
          // Usually they start with "file_picker"
          if (file is File && file.path.contains('file_picker')) {
            try {
              await file.delete();
              debugPrint('Deleted cached file: ${file.path}');
            } catch (e) {
              debugPrint('Failed to delete cached file: $e');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error clearing FilePicker cache: $e');
    }
  }

  static Future<String> readDocxFileFromBytes(List<int> bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    String text = '';
    for (final file in archive) {
      if (file.name.toLowerCase() == 'word/document.xml') {
        final xmlString = String.fromCharCodes(file.content as List<int>);
        final xmlDoc = XmlDocument.parse(xmlString);
        final nodes = xmlDoc.findAllElements('w:t');
        for (final node in nodes) {
          text += '${node.text} ';
        }
      }
    }
    return text;
  }

  static Future<FileResult?> fileSelector(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'docx'],
        // ⚠️ don't use withData: true → causes Parcel crash
      );

      if (result == null || result.files.isEmpty) {
        debugPrint("FilePicker: No file selected.");
        return null;
      }

      final pickedFile = result.files.single;
      debugPrint(
        "FilePicker: Picked file -> "
        "name=${pickedFile.name}, "
        "path=${pickedFile.path}, "
        "size=${pickedFile.size}, "
        "bytesAvailable=${pickedFile.bytes != null}",
      );

      String text = "";
      try {
        // ✅ Case 1: file has a valid path (older Android, iOS, desktop)
        if (pickedFile.path != null) {
          final filePath = pickedFile.path!;
          if (filePath.endsWith('.txt')) {
            text = await File(filePath).readAsString();
          } else if (filePath.endsWith('.pdf')) {
            final bytes = await File(filePath).readAsBytes();
            text = await readPdfFileFromBytes(bytes);
          } else if (filePath.endsWith('.docx')) {
            final bytes = await File(filePath).readAsBytes();
            text = await readDocxFileFromBytes(bytes);
          } else {
            text = AppLocalizations.of(context).unsupportedFile;
          }
        }
        // ✅ Case 2: no path, but in-memory bytes available (Android 11+ SAF)
        else if (pickedFile.bytes != null) {
          if (pickedFile.name.endsWith('.txt')) {
            text = String.fromCharCodes(pickedFile.bytes!);
          } else if (pickedFile.name.endsWith('.pdf')) {
            text = await readPdfFileFromBytes(pickedFile.bytes!);
          } else if (pickedFile.name.endsWith('.docx')) {
            text = await readDocxFileFromBytes(pickedFile.bytes!);
          } else {
            text = AppLocalizations.of(context).unsupportedFile;
          }
        } else {
          text = AppLocalizations.of(context).unsupportedFile;
          debugPrint("FilePicker: Unsupported file source, no path or bytes.");
        }
      } catch (e, st) {
        text = '${AppLocalizations.of(context).errorReadingFile}: $e';
        debugPrint("FilePicker: Error while reading file -> $e\n$st");
      }

      // ✅ Clear FilePicker cache to save space
      await clearFilePickerCache();
      FileResult fileResult = FileResult();
      fileResult.fileName = pickedFile.name;
      fileResult.text = text;
      return fileResult;
    } catch (e, st) {
      debugPrint("FilePicker: Unexpected error -> $e\n$st");
    }
    return null;
  }

  // Add your file utility methods here
  static Future<void> selectFile(
    BuildContext context,
    bool isCv,
    CvJdProvider cvJdProvider,
  ) async {
    try {
      FileResult? fileResult = await fileSelector(context);
      if (fileResult != null) {
        String text = fileResult.text;
        // ✅ Update provider
        if (isCv) {
          cvJdProvider.updateCvText(text);
          debugPrint("FilePicker: CV text updated (length=${text.length}).");
        } else {
          cvJdProvider.updateJdText(text);
          debugPrint("FilePicker: JD text updated (length=${text.length}).");
        }
      }
      // ✅ Update provider
      // if (isCv) {
      //   cvJdProvider.updateCvText(text);
      //   debugPrint("FilePicker: CV text updated (length=${text.length}).");
      // } else {
      //   cvJdProvider.updateJdText(text);
      //   debugPrint("FilePicker: JD text updated (length=${text.length}).");
      // }
      //
      //
      // final result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['txt', 'pdf', 'docx'],
      //   // ⚠️ don't use withData: true → causes Parcel crash
      // );
      //
      // if (result == null || result.files.isEmpty) {
      //   debugPrint("FilePicker: No file selected.");
      //   return;
      // }
      //
      // final pickedFile = result.files.single;
      // debugPrint(
      //   "FilePicker: Picked file -> "
      //       "name=${pickedFile.name}, "
      //       "path=${pickedFile.path}, "
      //       "size=${pickedFile.size}, "
      //       "bytesAvailable=${pickedFile.bytes != null}",
      // );
      //
      // String text = "";
      // try {
      //   // ✅ Case 1: file has a valid path (older Android, iOS, desktop)
      //   if (pickedFile.path != null) {
      //     final filePath = pickedFile.path!;
      //     if (filePath.endsWith('.txt')) {
      //       text = await File(filePath).readAsString();
      //     } else if (filePath.endsWith('.pdf')) {
      //       final bytes = await File(filePath).readAsBytes();
      //       text = await readPdfFileFromBytes(bytes);
      //     } else if (filePath.endsWith('.docx')) {
      //       final bytes = await File(filePath).readAsBytes();
      //       text = await readDocxFileFromBytes(bytes);
      //     } else {
      //       text = AppLocalizations.of(context)!.unsupportedFile;
      //     }
      //   }
      //   // ✅ Case 2: no path, but in-memory bytes available (Android 11+ SAF)
      //   else if (pickedFile.bytes != null) {
      //     if (pickedFile.name.endsWith('.txt')) {
      //       text = String.fromCharCodes(pickedFile.bytes!);
      //     } else if (pickedFile.name.endsWith('.pdf')) {
      //       text = await readPdfFileFromBytes(pickedFile.bytes!);
      //     } else if (pickedFile.name.endsWith('.docx')) {
      //       text = await readDocxFileFromBytes(pickedFile.bytes!);
      //     } else {
      //       text = AppLocalizations.of(context)!.unsupportedFile;
      //     }
      //   } else {
      //     text = AppLocalizations.of(context)!.unsupportedFile;
      //     debugPrint("FilePicker: Unsupported file source, no path or bytes.");
      //   }
      // } catch (e, st) {
      //   text = '${AppLocalizations.of(context)!.errorReadingFile}: $e';
      //   debugPrint("FilePicker: Error while reading file -> $e\n$st");
      // }
      //
      // // ✅ Update provider
      // if (isCv) {
      //   cvJdProvider.updateCvText(text);
      //   debugPrint("FilePicker: CV text updated (length=${text.length}).");
      // } else {
      //   cvJdProvider.updateJdText(text);
      //   debugPrint("FilePicker: JD text updated (length=${text.length}).");
      // }
      // ✅ Clear FilePicker cache to save space
      await clearFilePickerCache();
    } catch (e, st) {
      debugPrint("FilePicker: Unexpected error -> $e\n$st");
    }
  }
}
