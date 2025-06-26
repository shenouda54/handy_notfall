import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
Future<pw.Widget> buildPdfContent(
    Map<String, dynamic> data, int printId) async {
  final ByteData bytes = await rootBundle.load('assets/images/pdf.png');
  final Uint8List logoBytes = bytes.buffer.asUint8List();

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('Kostenmittlung Report',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 16),
      pw.Text('Kundendaten:', style: pw.TextStyle(fontSize: 14)),
      pw.SizedBox(height: 8),
      pw.Text('Stadt: ${data['city']}'),
      pw.Text('Adresse: ${data['address']}'),
      pw.Text('Telefon: ${data['phoneNumber']}'),
      pw.Text('E-Mail: ${data['emailAddress']}'),
      pw.SizedBox(height: 16),
      pw.Text('Gerätedaten:', style: pw.TextStyle(fontSize: 14)),
      pw.SizedBox(height: 8),
      pw.Text('Typ: ${data['deviceType']}'),
      pw.Text('Modell: ${data['deviceModel']}'),
      pw.Text('Seriennummer: ${data['serialNumber']}'),
    ],
  );
}