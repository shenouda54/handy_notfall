import 'package:cloud_firestore/cloud_firestore.dart';

class SequenceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final _ref = _firestore.collection('Sequences').doc('main');

  static Future<int> getNextCode(String field) async {
    final doc = await _ref.get();
    final current = doc.data()?[field] ?? 0;
    final next = current + 1;
    await _ref.update({field: next});
    return next;
  }

  static Future<int> getNextCustomerCode() => getNextCode('lastCustomerCode');
  static Future<int> getNextDeviceCode() => getNextCode('lastDeviceCode');
  static Future<int> getNextInvoiceCode() => getNextCode('lastInvoiceCode');
}
