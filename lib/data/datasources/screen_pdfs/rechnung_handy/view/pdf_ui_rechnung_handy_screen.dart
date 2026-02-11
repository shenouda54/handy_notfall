import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../shared/pdf_widgets.dart';

Future<pw.Widget> buildPdfContent(
    Map<String, dynamic> data, String rechnungNr) async {
  final ByteData bytes = await rootBundle.load('assets/images/pdf.png');
  final Uint8List logoBytes = bytes.buffer.asUint8List();

  // Calculate totals from defects list
  double totalAmount = 0;
  final List<dynamic> defects = data['defects'] ?? [];

  // Fallback for old data structure
  if (defects.isEmpty && data['issue'] != null) {
      defects.add({
        'issue': data['issue'],
        'price': data['price'] ?? 0,
        'quantity': data['quantity'] ?? 1,
      });
  }

  for (var defect in defects) {
    double price = double.tryParse(defect['price'].toString()) ?? 0;
    int quantity = int.tryParse(defect['quantity'].toString()) ?? 1;
    totalAmount += price * quantity;
  }

  final double netAmount = totalAmount;
  final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'de_DE');

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      PdfWidgets.buildHeader(),
      pw.SizedBox(height: 30),

      PdfWidgets.buildCustomerInfo(
        data: data,
        title: 'Rechnung Nr',
        titleNumber: rechnungNr,
        logoBytes: logoBytes,
      ),

      PdfWidgets.buildTableHeader(),
      pw.SizedBox(height: 8),
      
      // Render defect items
      ...defects.asMap().entries.map((entry) {
        int index = entry.key;
        var defect = entry.value;
        bool isLast = (index == defects.length - 1);
        
        double price = double.tryParse(defect['price'].toString()) ?? 0;
        int quantity = int.tryParse(defect['quantity'].toString()) ?? 1;

        return pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  width: 180,
                  child: pw.Text(
                    ' Gebraucht ${defect['issue']} ${data['deviceType']} ${data['deviceModel']}${isLast ? '.' : ''}',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    softWrap: true,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(right: 90),
                  child: pw.Text(
                    '$quantity',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Text('${currencyFormat.format(price)} ',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 5),
          ],
        );
      }).toList(),
      pw.SizedBox(height: 10),

      pw.Divider(thickness: 1),

      pw.SizedBox(height: 5),

      //  Brutto
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // الكلمه في النص وتحتهااا خط
              pw.Text('     Gesamt:',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.Text('${currencyFormat.format(netAmount)} ',
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Text(
              'Gebrauchtgegenstände / Sonderregelung, Differenzbesteuerung nach §25a UStG, MwSt. nichtausweisbar',
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),

      pw.SizedBox(height: 50),

      PdfWidgets.buildClosingText(),
      pw.Spacer(),
      PdfWidgets.buildFooter(),
    ],
  );
}
