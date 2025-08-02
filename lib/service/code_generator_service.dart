import 'package:cloud_firestore/cloud_firestore.dart';

class CodeGeneratorService {
  static final _sequencesRef =
  FirebaseFirestore.instance.collection('Sequences').doc('main');

  static Future<int> generateCustomerCode() async {
    return await _incrementField('lastCustomerCode');
  }

  static Future<int> generateDeviceCode() async {
    return await _incrementField('lastDeviceCode');
  }

  static Future<int> generateInvoiceCode() async {
    return await _incrementField('lastInvoiceCode');
  }

  static Future<int> _incrementField(String field) async {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(_sequencesRef);
      final current = snapshot.data()?[field] ?? 0;
      final next = current + 1;
      transaction.update(_sequencesRef, {field: next});
      return next;
    });
  }
}
