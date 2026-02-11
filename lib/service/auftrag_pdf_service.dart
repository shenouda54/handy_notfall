import 'package:flutter/material.dart';
import 'package:handy_notfall/features/domain/entities/customer_data_telpone_entity.dart';

import '../data/datasources/print_pdf/customer_number/view_model/customer_numbering_logic.dart';
import '../data/datasources/screen_pdfs/auftrag/view_model/pdf_logic.dart';

/// Service class for generating and printing Auftrag PDF after saving customer data
/// Generates and opens Auftrag PDF with current customer data
/// Takes customer entity and generates PDF using entity data
///
class AuftragPdfService {

  static Future<void> generateAndPrintAuftrag({
    required BuildContext context,
    required CustomerDataEntity entity,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final numberingResult = await CustomerNumberingService.assignCustomerNumber(
        entity.customerFirstName.trim(),
        entity.phoneNumber.trim(),
      );

      String auftragNr = '';
      int? kundennummer;

      if (numberingResult['success'] == true && numberingResult['devices'] != null) {
        // البحث عن الجهاز الأخير في القائمة
        final List<dynamic> devices = numberingResult['devices'];
        if (devices.isNotEmpty) {
          // الحصول على آخر جهاز
          final latestDevice = devices.last;
          auftragNr = latestDevice['auftragNr']?.toString() ?? '';
          kundennummer = latestDevice['kundennummer'];
        }
        // إذا لم نجد، نحاول الحصول من القيمة العامة
        if (auftragNr.isEmpty && devices.isNotEmpty) {
          auftragNr = devices.first['auftragNr']?.toString() ?? '';
          kundennummer = devices.first['kundennummer'];
        }
      }


      final pdfData = {
        'defects': entity.defects.map((e) => e.toMap()).toList(),
        'customerFirstName': entity.customerFirstName.trim(),
        'address': entity.address.trim(),
        'city': entity.city.trim(),
        'phoneNumber': entity.phoneNumber.trim(),
        'emailAddress': entity.emailAddress.trim(),
        'deviceType': entity.deviceType,
        'deviceModel': entity.deviceModel.trim(),
        'serialNumber': entity.serialNumber.trim(),
        'pinCode': entity.pinCode.trim(),
        'startDate': entity.startDate,
        'endDate': entity.endDate,
        'kundennummer': kundennummer,
        'customerCode': null,
      };

      await generatePdf(pdfData, context, auftragNr);

      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      print("⚠️ تحذير: فشل في طباعة PDF: $e");
    }
  }
}
///

