import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class PdfWidgets {
  static pw.Widget buildHeader() {
    return pw.Text('HandyNotfall - Breitscheiderstr. 2 - 53547 Roßbach/Wied',
        style: const pw.TextStyle(fontSize: 11));
  }

  static pw.Widget buildCustomerInfo({
    required Map<String, dynamic> data,
    required String title, // 'Auftrag Nr', 'Rechnung', 'Kostenmittlung'
    required String titleNumber, // The actual number
    required Uint8List logoBytes,
    bool showImei = false,
    bool showPinCode = false,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 4),
              pw.Text('${data['customerFirstName']}',
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('${data['city']}',
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('${data['address']}',
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('${data['phoneNumber']}',
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text('${data['emailAddress']}',
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 40),
              pw.Text(
                  "Kundennummer: ${data.containsKey('kundennummer') ? data['kundennummer'].toString() : 'غير متوفر'}",
                  style: pw.TextStyle(
                      fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.Text(
                'Datum: ${DateFormat('dd.MM.yyyy').format((data['startDate'] as Timestamp).toDate())}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
                textDirection: pw.TextDirection.ltr,
              ),

              pw.Row(
                children: [
                  pw.Text('Geräte-Typ: ${data['deviceType']} ',
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${data['deviceModel']}',
                      style: pw.TextStyle(
                          fontSize: 12, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              if (showImei)
                pw.Text('IMEL: ${data['serialNumber']}',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
              if (showPinCode)
                pw.Text('Sperrcode: ${data['pinCode']}',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('$title: $titleNumber',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
        pw.Container(
          width: 260,
          height: 260,
          alignment: pw.Alignment.topRight,
          child: pw.Image(
            pw.MemoryImage(logoBytes),
            width: 140,
            height: 240,
            fit: pw.BoxFit.fill,
          ),
        ),
      ],
    );
  }

  // Helper to finish the customer info column with the title
  static pw.Widget buildTitleRow(String title, String titleNumber) {
     return pw.Text('$title: $titleNumber',
          style: pw.TextStyle(
              fontSize: 20, fontWeight: pw.FontWeight.bold)); // Some use 16, some 20.
     // auftrag: 20
     // rechnung: 20 (Auftrag Nr)
     // kostenmittlung: 16 (Kostenmittlung)
     // rechnung_handy: 16 (Rechnung)
     // verkaufe: 16 (Rechnung)
     // I will pass the style or fontSize as optional.
  }

  static pw.Widget buildTableHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(width: 1),
          left: pw.BorderSide(width: 1),
          bottom: pw.BorderSide(width: 1),
          right: pw.BorderSide(width: 1),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Beschreibung',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Text('Menge',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.Text('Betrag',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Zahlungskondition. 7 Tage',
                      style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(
                      'Bitte geben Sie bei Zahlung folgende Verwendungszweck an:',
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Steuer-Nr. 32/005/55663',
                      style: const pw.TextStyle(fontSize: 6)),
                  pw.Text('USt-idNr. DE359650128',
                      style: const pw.TextStyle(fontSize: 6)),
                  pw.SizedBox(height: 4),
                  pw.Text('Bankverbindung',
                      style: const pw.TextStyle(fontSize: 6)),
                  pw.Text('Sparkasse Neuwied',
                      style: const pw.TextStyle(fontSize: 6)),
                  pw.Text('BIC MALADE51NWD',
                      style: const pw.TextStyle(fontSize: 6)),
                  pw.Text('IBAN DE06 5745 0120 0030 5166 78',
                      style: const pw.TextStyle(fontSize: 6)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  static pw.Widget buildClosingText() {
     return pw.Column(
       crossAxisAlignment: pw.CrossAxisAlignment.start,
       children: [
          pw.Text('Vielen Dank für ihren Auftrag.',
              style: const pw.TextStyle(fontSize: 10)),
          pw.Text('Mit freundlichen Grüßen',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 10),
          pw.Text('HandyNotfall',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
       ]
     );
  }
}
