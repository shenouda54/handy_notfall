import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;


Future<void> generatePdf(Map<String, dynamic> data) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Customer Details', style: const pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 20),
          pw.Text('Name: ${data['customerFirstName']}'),
          pw.Text('Phone: ${data['phoneNumber']}'),
          pw.Text('Address: ${data['address']}'),
          pw.Text('City: ${data['city']}'),
          pw.Text('Device Type: ${data['deviceType']}'),
          pw.Text('Device Model: ${data['deviceModel']}'),
          pw.Text('Serial Number: ${data['serialNumber']}'),
          pw.Text('Pin Code: ${data['pinCode']}'),
          pw.Text('Issue: ${data['issue']}'),
          pw.Text('Price: ${data['price']} €'),
          pw.Text('Start Date: ${(data['startDate'] as Timestamp).toDate().toString().split(' ')[0]}'),
          pw.Text('End Date: ${(data['endDate'] as Timestamp).toDate().toString().split(' ')[0]}'),
          pw.Text('Status: ${data['isDone'] ? 'Done' : 'In Progress'}'),
        ],
      ),
    ),
  );

  // Optional save to file
  // final output = Directory('/storage/emulated/0/Download');
  // final file = File("${output?.path}/customer_details.pdf");
  // await file.writeAsBytes(await pdf.save());
  final output = Directory('/storage/emulated/0/Download');
  final file = File("${output.path}/customer_details.pdf");
  await file.writeAsBytes(await pdf.save());
  // Preview or print

  print("PDF Saved at: ${file.path}");
  // await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
