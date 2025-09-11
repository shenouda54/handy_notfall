import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import '../../shared/storage_path.dart';
import '../view/pdf_ui_builder.dart';

Future<bool> requestStoragePermission() async {
  if (Platform.isAndroid) {
    // للـ Android 11+ (API 30+)
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }
    final status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }
  return true;
}

Future<void> generatePdf(Map<String, dynamic> data, BuildContext context, int printId) async {
  try {
    final pdf = pw.Document();
    final pdfPageContent = await buildPdfContent(data, printId);

    pdf.addPage(
      pw.Page(
        margin: const  pw.EdgeInsets.only(right: 40,bottom: 40,left: 40,top:40 ,),
        build: (context) => pdfPageContent,
      ),
    );

    final granted = await requestStoragePermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Permission Denied - Please allow storage access in settings")),
      );
      return;
    }

    final directory = await StorageHelper.getSafeStorageDirectory(context);
    if (directory == null) return;

    final now = DateTime.now();
    final fileName = 'customer_details_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.pdf';
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(await pdf.save());

    if (await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ PDF saved as $fileName")),
      );
      await OpenFile.open(file.path); // إرجاع فتح الملف تلقائياً
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to save PDF")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Error generating PDF: $e")),
    );
  }
}
