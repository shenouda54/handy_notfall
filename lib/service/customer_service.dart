import 'package:firebase_auth/firebase_auth.dart';
import 'package:handy_notfall/firebase_function.dart';
import 'package:handy_notfall/models/customer_model.dart';

import '../data/datasources/print_pdf/customer_number/view_model/customer_numbering_logic.dart';

class CustomerService {
  static Future<void> saveCustomer(CustomerModel model) async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) {
        throw Exception("User not authenticated");
      }
      
      model.userEmail = userEmail;
      
      // أولاً: نحفظ الجهاز الجديد بدون auftragNr
      model.auftragNr = null;
      model.kundennummer = null;
      
      // حفظ الجهاز في قاعدة البيانات
      await FirebaseFireStore.addCustomer(model);
      
      // ثانياً: نستدعي نظام الترقيم لتحديث جميع أجهزة العميل
      final numberingResult = await CustomerNumberingService.assignCustomerNumber(
        model.customerFirstName, 
        model.phoneNumber
      );
      
      if (!numberingResult['success']) {
        print("⚠️ تحذير: فشل في الترقيم التلقائي");
      }
      
    } catch (e) {
      print("❌ Error in saveCustomer: $e");
      throw Exception('Failed to save customer: $e');
    }
  }

}
