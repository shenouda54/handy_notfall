import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:handy_notfall/service/customer_number_service.dart' as CustomerService;
import 'package:handy_notfall/service/auftrag_number_service.dart';

class CustomerNumberingService {
  static Future<Map<String, dynamic>> assignCustomerNumber(String customerName, String customerPhone) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) {
      return {"success": false, "message": "❌ Sie sind nicht eingeloggt.", "devices": []};
    }

    // البحث عن العميل في قاعدة البيانات
    final snapshot = await FirebaseFirestore.instance
        .collection('Customers')
        .where('customerFirstName', isEqualTo: customerName)
        .where('phoneNumber', isEqualTo: customerPhone)
        .get();

    if (snapshot.docs.isEmpty) {
      return {"success": false, "message": "❌ Für diesen Kunden wurden keine Geräte gefunden.", "devices": []};
    }

    // فحص إذا كان العميل (نفس الاسم ورقم الهاتف) له kundennummer من قبل
    final firstDoc = snapshot.docs.first.data();
    int? existingKundennummer;
    
    if (firstDoc.containsKey('kundennummer')) {
      existingKundennummer = firstDoc['kundennummer'];
    }
    
    int newKundennummer;
    if (existingKundennummer != null) {
      // العميل موجود من قبل، نستخدم نفس kundennummer
      newKundennummer = existingKundennummer;
    } else {
      // العميل جديد، نولد kundennummer جديد
      final kundennummerSnapshot = await FirebaseFirestore.instance
          .collection('Customers')
          .where('userEmail', isEqualTo: userEmail)
          .orderBy('kundennummer', descending: true)
          .limit(1)
          .get();
      
      newKundennummer = 1;
      if (kundennummerSnapshot.docs.isNotEmpty && kundennummerSnapshot.docs.first.data().containsKey('kundennummer')) {
        newKundennummer = (kundennummerSnapshot.docs.first.data()['kundennummer'] ?? 0) + 1;
      }
    }
    
    // البحث عن آخر auftragNr للمستخدم الحالي (بدون orderBy لتجنب الحاجة لفهرس)
    final auftragNrSnapshot = await FirebaseFirestore.instance
        .collection('Customers')
        .where('userEmail', isEqualTo: userEmail)
        .get();
    
    int newAuftragNr = 1;
    if (auftragNrSnapshot.docs.isNotEmpty) {
      int maxAuftragNr = 0;
      for (final doc in auftragNrSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('auftragNr')) {
          final auftragNr = data['auftragNr'];
          if (auftragNr is String) {
            // إذا كان auftragNr نص، نستخرج الرقم منه
            final match = RegExp(r'(\d+)$').firstMatch(auftragNr);
            if (match != null) {
              final num = int.parse(match.group(1)!);
              if (num > maxAuftragNr) maxAuftragNr = num;
            }
          } else if (auftragNr is int) {
            if (auftragNr > maxAuftragNr) maxAuftragNr = auftragNr;
          }
        }
      }
      newAuftragNr = maxAuftragNr + 1;
    }
    
    // تحديث كل الأجهزة مع الأرقام الجديدة
    List<Map<String, dynamic>> updatedDevices = [];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      String? existingAuftragNr;
      
      // فحص إذا كان الجهاز له auftragNr من قبل
      if (data.containsKey('auftragNr') && data['auftragNr'] != null && data['auftragNr'].toString().isNotEmpty) {
        existingAuftragNr = data['auftragNr'].toString();
      }
      
      String finalAuftragNr;
      if (existingAuftragNr != null) {
        // الجهاز موجود من قبل، نستخدم نفس auftragNr
        finalAuftragNr = existingAuftragNr;
      } else {
        // الجهاز جديد، نولد auftragNr جديد
        finalAuftragNr = newAuftragNr.toString();
        newAuftragNr++;
      }
      
      // تحديث الجهاز في قاعدة البيانات
      await doc.reference.update({
        'kundennummer': newKundennummer,
        'auftragNr': finalAuftragNr,
      });
      
      // إضافة البيانات المحدثة للقائمة
      data['id'] = doc.id;
      data['kundennummer'] = newKundennummer;
      data['auftragNr'] = finalAuftragNr;
      updatedDevices.add(data);
    }

    String message;
    if (existingKundennummer != null) {
      message = "ℹ️ Der Kunde hat bereits die Kundennummer: $newKundennummer. Neue Geräte wurden hinzugefügt.";
    } else {
      message = "✅ Der Kunde wurde mit der Kundennummer nummeriert: $newKundennummer";
    }

    return {
      "success": true,
      "message": message,
      "kundennummer": newKundennummer,
      "devices": updatedDevices
    };
  }
}

