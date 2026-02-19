import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_email_sender/flutter_email_sender.dart';

import '../../shared/storage_path.dart';
import '../view/pdf_ui_rechnung_handy_screen.dart';

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

Future<void> generatePdf(
    Map<String, dynamic> data, BuildContext context, String rechnungNr,
    {bool sendEmail = false, String? userEmail}) async {
  try {
    final pdf = pw.Document();
    final pdfPageContent = await buildPdfContent(data, rechnungNr);

    pdf.addPage(
      pw.Page(
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
    final fileName =
        'rechnung_handy_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.pdf';
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(await pdf.save());

    if (await file.exists()) {
      if (sendEmail) {
        final Email email = Email(
          body: '''Sehr geehrte Damen und Herren,

anbei erhalten Sie Ihre Rechnung.
Bei Rückfragen stehen wir Ihnen gerne zur Verfügung.

Mit freundlichen Grüßen
Bakhit
HandyNotfall

Breitscheider Straße 2
53547 Roßbach
Tel.: 0175 4111112''',
          subject: 'Rechnung Handy $rechnungNr',
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
          SnackBar(content: Text("✅ PDF gespeichert als $fileName")),
        );
        await OpenFile.open(file.path);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Fehler beim Speichern")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Error generating PDF: $e")),
    );
  }
}
