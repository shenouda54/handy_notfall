import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';


/// طلب صلاحية التخزين (مناسبة لـ Android 8.1)
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

/// توليد ملف PDF من بيانات العميل وحفظه باسم مختلف في Downloads
Future<void> generatePdf(Map<String, dynamic> data, BuildContext context,int printId) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Customer Details', style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 20),
          pw.Text('Rechnung Nr.: $printId', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Text('Name: ${data['customerFirstName']}'),
          pw.Text('Phone: ${data['phoneNumber']}'),
          pw.Text('Address: ${data['address']}'),
          pw.Text('City: ${data['city']}'),
          pw.Text('Device Type: ${data['deviceType']}'),
          pw.Text('Device Model: ${data['deviceModel']}'),
          pw.Text('Serial Number: ${data['serialNumber']}'),
          pw.Text('Pin Code: ${data['pinCode']}'),
          pw.Text('Issue: ${data['issue']}'),
          pw.Text('Price: ${data['price']} '),
          pw.Text('Start Date: ${(data['startDate'] as Timestamp).toDate().toString().split(' ')[0]}'),
          pw.Text('End Date: ${(data['endDate'] as Timestamp).toDate().toString().split(' ')[0]}'),
        ],
      ),
    ),
  );

  final granted = await requestStoragePermission();
  if (!granted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Permission Denied")),
    );
    return;
  }

  final directory = Directory('/storage/emulated/0/Download');

  // ✅ اسم الملف يكون فيه التاريخ والوقت
  final now = DateTime.now();
  final fileName =
      'customer_details_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.pdf';
  final file = File('${directory.path}/$fileName');

  await file.writeAsBytes(await pdf.save());

  if (await file.exists()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ PDF saved as $fileName")),
    );

    // 📂 افتح الملف مباشرة بعد الحفظ
    await OpenFile.open(file.path);

  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Failed to save PDF")),
    );
  }
}