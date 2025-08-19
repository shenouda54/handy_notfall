import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:handy_notfall/firebase_function.dart';
import 'package:handy_notfall/models/customer_model.dart';

class CustomerService {
  static Future<void> saveCustomer(CustomerModel model) async {
    try {
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) {
        throw Exception("User not authenticated");
      }
      
      model.userEmail = userEmail;

      final allowAutoNumbering = userEmail == "handynotfall@web.de";

      // Check if customer already has printId
      final snapshot = await FirebaseFirestore.instance
          .collection('Customers')
          .where('customerFirstName', isEqualTo: model.customerFirstName)
          .where('phoneNumber', isEqualTo: model.phoneNumber)
          .get();

      // If customer already has printId, use the same one
      if (snapshot.docs.isNotEmpty && snapshot.docs.first.data().containsKey('printId')) {
        final existingPrintId = snapshot.docs.first['printId'];
        model.printId = existingPrintId;
      }
      // If not numbered and account allows auto numbering
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

      // Final save
      await FirebaseFireStore.addCustomer(model);
    } catch (e) {
      print("❌ Error in saveCustomer: $e");
      throw Exception('Failed to save customer: $e');
    }
  }
}
