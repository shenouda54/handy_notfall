import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import '../view/pdf_ui_rechnung_handy_screen.dart';
Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    if (await Permission.storage.isGranted) {
      return true;
    }
    final status = await Permission.storage.request();
    return status.isGranted;
  }
  return true;
}

Future<void> generatePdf(
    Map<String, dynamic> data, BuildContext context, int printId) async {
  final pdf = pw.Document();
  final pdfPageContent = await buildPdfContent(data, printId);

  pdf.addPage(
    pw.Page(
      build: (context) => pdfPageContent,
    ),
  );

  final granted = await requestStoragePermission();
  if (!granted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Permission Denied")),
    );
    return;
  }

  final directory = Directory('/storage/emulated/0/Download');
  final now = DateTime.now();
  final fileName =
      'rechnung_handy_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.pdf';
  final file = File('${directory.path}/$fileName');

  await file.writeAsBytes(await pdf.save());

  if (await file.exists()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ PDF gespeichert als $fileName")),
    );
    await OpenFile.open(file.path);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("❌ Fehler beim Speichern")),
    );
  }
}
