import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart'; // Add this import

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

Future<File?> generatePdf(
    Map<String, dynamic> data, BuildContext context, String rechnungNr,
    {bool sendEmail = false, String? userEmail}) async {
  try {
    final pdf = pw.Document();
    final pdfPageContent = await buildPdfContent(data, rechnungNr);

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.only(
          right: 40,
          bottom: 40,
          left: 40,
          top: 40,
        ),
        build: (context) => pdfPageContent,
      ),
    );

    final granted = await requestStoragePermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "❌ Permission Denied - Please allow storage access in settings")),
      );
      return null;
    }

    final directory = await StorageHelper.getSafeStorageDirectory(context);
    if (directory == null) return null;

    final now = DateTime.now();
    final fileName =
        'Rechnung_${rechnungNr.replaceAll('/', '-')}_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.pdf';
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(await pdf.save());

    if (await file.exists()) {
      if (sendEmail) {
        final Email email = Email(
          body: 'Hier ist Ihre Rechnung Nr. $rechnungNr',
          subject: 'Rechnung $rechnungNr',
          recipients: userEmail != null ? [userEmail] : [],
          attachmentPaths: [file.path],
          isHTML: false,
        );

        try {
          await FlutterEmailSender.send(email);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Email-App geöffnet")),
          );
        } catch (e) {
          String errorMessage = "❌ Fehler beim Senden der E-Mail";
          if (e.toString().contains("not_available") ||
              e.toString().contains("No email clients found")) {
            errorMessage = "❌ Keine E-Mail-App gefunden! Bitte installieren Sie eine Mail-App.";
          } else {
            errorMessage = "$errorMessage: $e";
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ PDF saved as $fileName")),
        );
        await OpenFile.open(file.path);
      }
      return file;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to save PDF")),
      );
      return null;
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Error generating PDF: $e")),
    );
    return null;
  }
}
