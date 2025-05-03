import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';

Future<pw.Widget> buildPdfContent(
    Map<String, dynamic> data, int printId) async {
  final ByteData bytes = await rootBundle.load('assets/images/pdf.png');
  final Uint8List logoBytes = bytes.buffer.asUint8List();

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('HandyNotfall - Breitscheiderstr. 2 - 53547 Roßbach/Wied',
          style: const pw.TextStyle(fontSize: 11)),
      pw.SizedBox(height: 30),

      // ✅ معلومات العميل واللوجو
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start, // ✅ مهم جداً
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 4),
                pw.Text(
                  '${data['customerFirstName']}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 1),
                pw.Text(
                  '${data['city']}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 1),
                pw.Text(
                  '${data['address']}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 1),
                pw.Text(
                  '${data['phoneNumber']}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 1),
                pw.Text(
                  '${data['emailAddress']}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Datum: ${(data['startDate'] as Timestamp).toDate().toString().split(' ')[0]}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 1),
                pw.Row(
                  children: [
                    pw.Text(
                      'Geräte-Typ: ${data['deviceType']}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(" , "),
                    pw.SizedBox(width: 1),
                    pw.Text(
                      '${data['deviceModel']}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1),
                pw.Text(
                  'IMEL: ${data['serialNumber']}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 1),
                pw.Text(
                  'Sperre Code: ${data['pinCode']}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Auftrag Nr: $printId',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
          // ✅ اللوجو نطلعه فوق بالظبط
          pw.Container(
            width: 260,
            height: 260, // خلي الارتفاع زي ما تحب
            alignment: pw.Alignment.topRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              mainAxisAlignment: pw.MainAxisAlignment.start, // ✅ تبدأ من فوق
              children: [
                pw.Image(
                  pw.MemoryImage(logoBytes),
                  width: 260,
                  height: 240, // ممكن تتحكم في ارتفاع الصورة نفسها كمان
                  fit: pw.BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
      // ✅ الوصف والسعر
      pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(width: 1),
                  left: pw.BorderSide(width: 1),
                  bottom: pw.BorderSide(width: 1),
                ),
              ),
              child: pw.Text(
                'Beschreibung',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(width: 1),
                  right: pw.BorderSide(width: 1),
                  bottom: pw.BorderSide(width: 1),
                ),
              ),
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Betrag',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      pw.Text(
        'Wir haben Ihr Gerät geprüft und die Fehler festgestellt. Die Reparaturkosten setzen sich wie folgt zusammen:',
        style: const pw.TextStyle(
          fontSize: 9,
        ),
      ),
      pw.SizedBox(height: 3),
      pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 1)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${data['issue']}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 10), // ✅ سطر فاضي بعد النص
                ],
              ),
            ),
          ),

          pw.Expanded(
            flex: 1,
            child: pw.Container(
              padding: const pw.EdgeInsets.all(5),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(width: 1)),
              ),
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end, // عشان السعر يفضل يمين
                children: [
                  pw.Text(
                    '${data['price']},00',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10), // ✅ هنا السطر الفاضي
                ],
              ),
            ),
          ),

        ],

      ),

      pw.SizedBox(height: 5),

      // ✅ Bruttobetrag
      pw.Row(
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text('Bruttobetrag EUR',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text('${data['price']},00',
                style:
                    pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.right),
          ),
        ],
      ),

      pw.SizedBox(height: 50),

      // ✅ قسم الشكر والفوتر النهائي
      pw.Text('Vielen Dank für ihren Auftrag.',
          style: const pw.TextStyle(fontSize: 10)),
      pw.SizedBox(height: 5),
      pw.Text('Mit freundlichen Grüßen',
          style: const pw.TextStyle(fontSize: 10)),
      pw.SizedBox(height: 10),
      pw.Text(
          'HandyNotfall                                       '
          '                                                        '
          '                                                           '
          '                                                          '
          '                                                                  '
          '                                                     '
          '                                                                                                        '
          '                                                                                               '
          '                                                                                                                                                                           '
          '                                                                                                                                    '
          '                                                                                                                                                                    '
          '                                   '
              '                                                                                                     '
          '                                                                                             ',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),

      pw.SizedBox(height: 152),

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
                pw.SizedBox(height: 5),
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
