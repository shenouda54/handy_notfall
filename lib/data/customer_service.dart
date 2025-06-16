import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:handy_notfall/firebase_function.dart';
import 'package:handy_notfall/models/customer_model.dart';

class CustomerService {
  static Future<void> saveCustomer(CustomerModel model) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    model.userEmail = userEmail ?? '';

    final allowAutoNumbering = userEmail == "handynotfall@web.de";

    // ✅ التحقق هل العميل الحالي ليه printId قديم
    final snapshot = await FirebaseFirestore.instance
        .collection('Customers')
        .where('customerFirstName', isEqualTo: model.customerFirstName)
        .where('phoneNumber', isEqualTo: model.phoneNumber)
        .get();

    // ✅ لو العميل مرقّم بالفعل، ناخد نفس الـ printId
    if (snapshot.docs.isNotEmpty && snapshot.docs.first.data().containsKey('printId')) {
      final existingPrintId = snapshot.docs.first['printId'];
      model.printId = existingPrintId;
    }
    // ✅ لو مش مرقّم خالص و الحساب يسمح بالتلقائي
    else if (allowAutoNumbering) {
      final last = await FirebaseFirestore.instance
          .collection('Customers')
          .orderBy('printId', descending: true)
          .limit(1)
          .get();

      int newPrintId = 2025670;
      if (last.docs.isNotEmpty && last.docs.first.data().containsKey('printId')) {
        newPrintId = last.docs.first['printId'] + 1;
      }

      model.printId = newPrintId;
    }

    // ✅ الحفظ النهائي
    await FirebaseFireStore.addCustomer(model);
  }
}
