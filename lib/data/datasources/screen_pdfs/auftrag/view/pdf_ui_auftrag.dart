import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../shared/pdf_widgets.dart';

Future<pw.Widget> buildPdfContent(
    Map<String, dynamic> data, String auftragNr) async {
  final ByteData bytes = await rootBundle.load('assets/images/pdf.png');
  final Uint8List logoBytes = bytes.buffer.asUint8List();

  final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'de_DE');

  // Helper to normalize defects list
  final List<dynamic> defects = [];
  if (data['defects'] != null && (data['defects'] as List).isNotEmpty) {
      defects.addAll(data['defects'] as List);
  } else if (data['issue'] != null) {
      // Fallback for old data or single item
      defects.add({
        'issue': data['issue'],
        'price': data['price'] ?? 0,
        'quantity': data['quantity'] ?? 1,
      });
  }

  // Calculate total amount from defects
  double totalAmount = 0;
  for (var defect in defects) {
    final double p = double.tryParse(defect['price'].toString()) ?? 0;
    final int q = int.tryParse(defect['quantity'].toString()) ?? 1;
    totalAmount += (p * q);
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      PdfWidgets.buildHeader(),
      pw.SizedBox(height: 30),

      PdfWidgets.buildCustomerInfo(
        data: data,
        title: 'Auftrag Nr',
        titleNumber: data['customerCode'] ?? auftragNr ?? '??',
        logoBytes: logoBytes,
        showImei: true,
        showPinCode: true,
        showAuftragNrInHeader: false,
      ),
      PdfWidgets.buildTableHeader(),
      pw.SizedBox(height: 6),
      
      // Render defects table
      pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(4), // Description column
          1: const pw.FixedColumnWidth(130), // Menge column
          2: const pw.FixedColumnWidth(140), // Betrag column
        },
        children: defects.asMap().entries.map((entry) {
            int index = entry.key;
            var defect = entry.value;
            bool isLast = (index == defects.length - 1);
            
            final double itemPrice = double.tryParse(defect['price'].toString()) ?? 0;
            // Removed tax calculation. Showing full price.
            final String itemIssue = defect['issue'] ?? '';
            final String itemQty = (defect['quantity'] ?? 1).toString();

            return pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Text(
                    '$itemIssue ${data['deviceType']} ${data['deviceModel']}${isLast ? ' inkl. Montage' : ''}',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                    softWrap: true,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Text(
                    itemQty,
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Text('${currencyFormat.format(itemPrice)} ',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.right),
                ),
              ],
            );
        }).toList(),
      ),
      pw.Divider(thickness: 1),

      pw.SizedBox(height: 5),

      // Total Amount
      pw.Padding(
        padding: const pw.EdgeInsets.only(left: 80),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Gesamtbetrag EUR ',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text('${currencyFormat.format(totalAmount)} ',
                    style: pw.TextStyle(
                        fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.Divider(thickness: 1),
          ],
        ),
      ),

      pw.SizedBox(height: 50),

      PdfWidgets.buildClosingText(),
      
      pw.Spacer(),
      PdfWidgets.buildFooter(),
    ],
  );
}
