import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<pw.Widget> buildPdfContent(
    Map<String, dynamic> data, int printId) async {
  final ByteData bytes = await rootBundle.load('assets/images/pdf.png');
  final Uint8List logoBytes = bytes.buffer.asUint8List();

  final double netAmount = double.tryParse(data['price'].toString()) ?? 0;
  final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'de_DE');



  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('HandyNotfall - Breitscheiderstr. 2 - 53547 Roßbach/Wied',
          style: const pw.TextStyle(fontSize: 11)),
      pw.SizedBox(height: 30),

      pw.Row(
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
                pw.Text("Kundennummer:", style: pw.TextStyle(
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
                    pw.Text('Geräte-Typ: ${data['deviceType']}',
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text(" , "),
                    pw.Text('${data['deviceModel']}',
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ), pw.Text('IMEL: ${data['serialNumber']}',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text('Sperre Code: ${data['pinCode']}',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Auftrag Nr: ${data['customerCode'] ?? data['printId'] ?? '??'}',
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
      ),

      pw.Container(
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
      ),
      pw.SizedBox(height: 6),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Container(
            width: 180,
            child: pw.Text(
              '${data['issue']} ${data['deviceType']} ${data['deviceModel']} inkl. Montage.',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              softWrap: true,
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(right: 90),
            child: pw.Text(
              '1',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.Text('${currencyFormat.format(netAmount)} ',
              style:
              pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
      pw.Divider(thickness: 1),

      pw.SizedBox(height: 5),

      // Netto, MwSt, Brutto
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 80),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Bruttobetrag EUR ',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text('${currencyFormat.format(netAmount)} ',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Divider(thickness: 1),
          ],
        ),
      ),

      pw.SizedBox(height: 50),

      pw.Text('Vielen Dank für ihren Auftrag.',
          style: const pw.TextStyle(fontSize: 10)),
      pw.Text('Mit freundlichen Grüßen',
          style: const pw.TextStyle(fontSize: 10)),
      pw.SizedBox(height: 10),
      pw.Text('HandyNotfall',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
      // pw.Image(
      //   pw.MemoryImage(logoBytes),
      //   width: 140,
      //   height: 140,
      //   fit: pw.BoxFit.fill,
      // ),
      pw.Spacer(),
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
