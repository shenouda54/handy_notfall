import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../shared/pdf_widgets.dart';

Future<pw.Widget> buildPdfContent(
    Map<String, dynamic> data, String auftragNr) async {
  final ByteData bytes = await rootBundle.load('assets/images/pdf.png');
  final Uint8List logoBytes = bytes.buffer.asUint8List();

  final double netAmount = double.tryParse(data['price'].toString()) ?? 0;
  final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'de_DE');

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
        if (data['items'] != null && (data['items'] as List).isNotEmpty)
          ...(data['items'] as List).map((item) {
            final double itemPrice = double.tryParse(item['price'].toString()) ?? 0;
            final double itemNet = double.parse((itemPrice / 1.19).toStringAsFixed(2));
            final String itemIssues = (item['issues'] as List<dynamic>?)?.join(', ') ?? '';
            final String itemQty = (item['quantity'] ?? 1).toString();

            return pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      width: 180,
                      child: pw.Text(
                        '$itemIssues ${data['deviceType']} ${data['deviceModel']} inkl. Montage',
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold),
                        softWrap: true,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 90),
                      child: pw.Text(
                        itemQty,
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                    ),

                    pw.Text('${currencyFormat.format(itemNet)} ',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 5),
              ],
            );
          }).toList()
        else
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                width: 180,
                child: pw.Text(
                  '${data['issue']} ${data['deviceType']} ${data['deviceModel']} inkl. Montage',
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                  softWrap: true,
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(right: 90),
                child: pw.Text(
                  '${data['quantity'] ?? 1}', // Use dynamic quantity
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

      PdfWidgets.buildClosingText(),
      
      pw.Spacer(),
      PdfWidgets.buildFooter(),
    ],
  );
}
