// lib/utils/file_util_impl_web.dart
// Web-specific FileUtil implementation

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:xml/xml.dart';

import '../../generated/l10n.dart';
// plus your other imports...

import '../models/file_result.dart';
import '../providers/cv_jd_provider.dart';

class FileUtil {
  // === File readers (same API as IO version) ===

  static Future<String> readPdfFileFromBytes(List<int> bytes) async {
    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText();
    document.dispose();
    return text;
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

  /// On web FilePicker doesn’t cache files in /tmp, so nothing to clear.
  static Future<void> clearFilePickerCache() async {
    return;
  }

  /// Helper: read a browser File into bytes with FileReader
  static Future<Uint8List> _readWebFileBytes(html.File webFile) {
    final reader = html.FileReader();
    final completer = Completer<Uint8List>();

    reader.onLoad.listen((_) {
      final result = reader.result;
      if (result is ByteBuffer) {
        completer.complete(Uint8List.view(result));
      } else if (result is Uint8List) {
        completer.complete(result);
      } else if (result is String) {
        completer.complete(Uint8List.fromList(utf8.encode(result)));
      } else {
        completer.completeError('Unknown FileReader result: $result');
      }
    });

    reader.onError.listen((err) => completer.completeError(err));
    reader.readAsArrayBuffer(webFile);

    return completer.future;
  }

  static Future<FileResult?> fileSelector(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'docx'],
        // note: withData:true would preload bytes but can be heavy for large files
      );

      if (result == null || result.files.isEmpty) {
        debugPrint("FilePicker (web): No file selected.");
        return null;
      }

      final pickedFile = result.files.single;
      debugPrint(
        "FilePicker (web): Picked file -> "
        "name=${pickedFile.name}, "
        "path=${pickedFile.path}, "
        "size=${pickedFile.size}, "
        "bytesAvailable=${pickedFile.bytes != null}",
      );

      String text = "";

      try {
        // ✅ Case 1: bytes already available (preferred)
        if (pickedFile.bytes != null) {
          final bytes = pickedFile.bytes!;
          final lower = pickedFile.name.toLowerCase();

          if (lower.endsWith('.txt')) {
            text = utf8.decode(bytes);
          } else if (lower.endsWith('.pdf')) {
            text = await readPdfFileFromBytes(bytes);
          } else if (lower.endsWith('.docx')) {
            text = await readDocxFileFromBytes(bytes);
          } else {
            text = AppLocalizations.of(context).unsupportedFile;
          }
        }
        // ✅ Case 2: no bytes, fallback to DOM File
        else {
          html.File? webFile;

          // try to locate the last file input element with files
          final inputs = html.document.getElementsByTagName('input');
          for (final node in inputs) {
            if (node is html.FileUploadInputElement &&
                node.files != null &&
                node.files!.isNotEmpty) {
              webFile = node.files!.last;
              break;
            }
          }

          if (webFile != null) {
            final bytes = await _readWebFileBytes(webFile);
            final lower = pickedFile.name.toLowerCase();

            if (lower.endsWith('.txt')) {
              text = utf8.decode(bytes);
            } else if (lower.endsWith('.pdf')) {
              text = await readPdfFileFromBytes(bytes);
            } else if (lower.endsWith('.docx')) {
              text = await readDocxFileFromBytes(bytes);
            } else {
              text = AppLocalizations.of(context).unsupportedFile;
            }
          } else {
            text = AppLocalizations.of(context).unsupportedFile;
            debugPrint("FilePicker (web): No File object available.");
          }
        }
      } catch (e, st) {
        text = '${AppLocalizations.of(context).errorReadingFile}: $e';
        debugPrint("FilePicker (web): Error while reading file -> $e\n$st");
      }

      var fileResult = FileResult();
      fileResult.text = text;
      fileResult.fileName = pickedFile.name;
      return fileResult;
      // // ✅ Update provider with CV/JD text
      // if (isCv) {
      //   cvJdProvider.updateCvText(text);
      //   debugPrint("FilePicker (web): CV text updated (length=${text.length}).");
      // } else {
      //   cvJdProvider.updateJdText(text);
      //   debugPrint("FilePicker (web): JD text updated (length=${text.length}).");
      // }

      // no cache to clear on web
    } catch (e, st) {
      debugPrint("FilePicker (web): Unexpected error -> $e\n$st");
    }
    return null;
  }

  // === File select (web) ===
  static Future<void> selectFile(
    BuildContext context,
    bool isCv,
    CvJdProvider cvJdProvider,
  ) async {
    try {
      FileResult? fileResult = await fileSelector(context);
      // final result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['txt', 'pdf', 'docx'],
      //   // note: withData:true would preload bytes but can be heavy for large files
      // );
      //
      // if (result == null || result.files.isEmpty) {
      //   debugPrint("FilePicker (web): No file selected.");
      //   return;
      // }
      //
      // final pickedFile = result.files.single;
      // debugPrint(
      //   "FilePicker (web): Picked file -> "
      //       "name=${pickedFile.name}, "
      //       "path=${pickedFile.path}, "
      //       "size=${pickedFile.size}, "
      //       "bytesAvailable=${pickedFile.bytes != null}",
      // );
      //
      // String text = "";
      //
      // try {
      //   // ✅ Case 1: bytes already available (preferred)
      //   if (pickedFile.bytes != null) {
      //     final bytes = pickedFile.bytes!;
      //     final lower = pickedFile.name.toLowerCase();
      //
      //     if (lower.endsWith('.txt')) {
      //       text = utf8.decode(bytes);
      //     } else if (lower.endsWith('.pdf')) {
      //       text = await readPdfFileFromBytes(bytes);
      //     } else if (lower.endsWith('.docx')) {
      //       text = await readDocxFileFromBytes(bytes);
      //     } else {
      //       text = AppLocalizations.of(context)!.unsupportedFile;
      //     }
      //   }
      //   // ✅ Case 2: no bytes, fallback to DOM File
      //   else {
      //     html.File? webFile;
      //
      //     // try to locate the last file input element with files
      //     final inputs = html.document.getElementsByTagName('input');
      //     for (final node in inputs) {
      //       if (node is html.FileUploadInputElement &&
      //           node.files != null &&
      //           node.files!.isNotEmpty) {
      //         webFile = node.files!.last;
      //         break;
      //       }
      //     }
      //
      //     if (webFile != null) {
      //       final bytes = await _readWebFileBytes(webFile);
      //       final lower = pickedFile.name.toLowerCase();
      //
      //       if (lower.endsWith('.txt')) {
      //         text = utf8.decode(bytes);
      //       } else if (lower.endsWith('.pdf')) {
      //         text = await readPdfFileFromBytes(bytes);
      //       } else if (lower.endsWith('.docx')) {
      //         text = await readDocxFileFromBytes(bytes);
      //       } else {
      //         text = AppLocalizations.of(context)!.unsupportedFile;
      //       }
      //     } else {
      //       text = AppLocalizations.of(context)!.unsupportedFile;
      //       debugPrint("FilePicker (web): No File object available.");
      //     }
      //   }
      // } catch (e, st) {
      //   text = '${AppLocalizations.of(context)!.errorReadingFile}: $e';
      //   debugPrint("FilePicker (web): Error while reading file -> $e\n$st");
      // }

      if (fileResult != null) {
        var text = fileResult.text;
        // ✅ Update provider with CV/JD text
        if (isCv) {
          cvJdProvider.updateCvText(text);
          debugPrint(
            "FilePicker (web): CV text updated (length=${text.length}).",
          );
        } else {
          cvJdProvider.updateJdText(text);
          debugPrint(
            "FilePicker (web): JD text updated (length=${text.length}).",
          );
        }
      }
      // no cache to clear on web
    } catch (e, st) {
      debugPrint("FilePicker (web): Unexpected error -> $e\n$st");
    }
  }
}
