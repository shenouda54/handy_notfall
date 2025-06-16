import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerNumberingService {
  static Future<Map<String, dynamic>> assignCustomerNumber(String customerName, String customerPhone) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) {
      return {"success": false, "message": "❌ Sie sind nicht eingeloggt.", "devices": []};
    }

    // if (userEmail != "handynotfall@web.de") {
    //   return {"success": false, "message": "Sie können diese Funktion nicht verwenden. ❌", "devices": []};
    // }

    final snapshot = await FirebaseFirestore.instance
        .collection('Customers')
        .where('customerFirstName', isEqualTo: customerName)
        .where('phoneNumber', isEqualTo: customerPhone)
        .get();

    if (snapshot.docs.isEmpty) {
      return {"success": false, "message": "❌ Für diesen Kunden wurden keine Geräte gefunden.", "devices": []};
    }

    // موجود فعلاً PrintId
    final existingPrintId = snapshot.docs.first.data()['printId'];
    if (existingPrintId != null) {
      List<Map<String, dynamic>> devices = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      return {
        "success": true,
        "message": "ℹ️ Der Kunde ist bereits mit der Nummer nummeriert. $existingPrintId",
        "printId": existingPrintId,
        "devices": devices
      };
    }

    // نولّد printId جديد
    final last = await FirebaseFirestore.instance
        .collection('Customers')
        .orderBy('printId', descending: true)
        .limit(1)
        .get();

    int newPrintId = 2025670;
    if (last.docs.isNotEmpty && last.docs.first.data().containsKey('printId')) {
      newPrintId = last.docs.first['printId'] + 1;
    }

    for (final doc in snapshot.docs) {
      await doc.reference.update({'printId': newPrintId});
    }

    List<Map<String, dynamic>> devices = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    return {
      "success": true,
      "message": "✅ Der Kunde wurde mit der Nummer nummeriert.$newPrintId",
      "printId": newPrintId,
      "devices": devices
    };
  }
}

