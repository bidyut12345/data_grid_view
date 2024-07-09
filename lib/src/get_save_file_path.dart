import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';

bool sendToAllInDebugMode = false;
Future<String?> getSaveFilePath(String fileName) async {
  String? path;
  if (!kIsWeb && Platform.isAndroid) {
    try {
      var rr = await FilePicker.platform.getDirectoryPath();
      if (rr != null) {
        path = "$rr/$fileName";
      }
    } catch (_) {}
    if (kDebugMode) print(path);
  } else {
    path = (await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: [
        fileName.toUpperCase().endsWith(".XLSX")
            ? const XTypeGroup(extensions: ["xlsx"], label: "Excel File(XLSX)")
            : fileName.toUpperCase().endsWith(".PDF")
                ? const XTypeGroup(extensions: ["pdf"], label: "PDF File")
                : const XTypeGroup(extensions: ["*"], label: "All File")
      ],
    ))
        ?.path;
  }
  return path;
}
