import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    
    // البحث عن آخر auftragNr للمستخدم الحالي فقط للسنة الحالية
    final currentYear = DateTime.now().year;
    final yearSuffix = currentYear.toString().substring(3); // أخذ آخر رقم واحد من السنة (مثل 2025 → 5)
    final auftragNrSnapshot = await FirebaseFirestore.instance
        .collection('Customers')
        .where('userEmail', isEqualTo: userEmail) // البحث فقط في أجهزة المستخدم الحالي
        .get();
    
    int newAuftragNr = 1;
    int maxAuftragNr = 0;
    
    print("🔍 البحث عن auftragNr للسنة: $yearSuffix للمستخدم: $userEmail");
    print("📊 عدد الأجهزة للمستخدم الحالي: ${auftragNrSnapshot.docs.length}");
    print("🔍 الإيميل الحالي: $userEmail");
    
    if (auftragNrSnapshot.docs.isNotEmpty) {
      for (final doc in auftragNrSnapshot.docs) {
        final data = doc.data();
        print("🔍 فحص جهاز - userEmail: ${data['userEmail']}, auftragNr: ${data['auftragNr']}");
        
        if (data.containsKey('auftragNr')) {
          final auftragNr = data['auftragNr'];
          print("🔍 وجد auftragNr: $auftragNr");
          
          if (auftragNr is String && auftragNr.startsWith('$yearSuffix/')) {
            // إذا كان auftragNr يبدأ بالسنة الحالية، نستخرج الرقم منه
            final match = RegExp(r'(\d+)$').firstMatch(auftragNr);
            if (match != null) {
              final num = int.parse(match.group(1)!);
              print("🔢 استخرج الرقم: $num من $auftragNr");
              if (num > maxAuftragNr) {
                maxAuftragNr = num;
                print("✅ تحديث maxAuftragNr إلى: $maxAuftragNr");
              }
            }
          }
        }
      }
      newAuftragNr = maxAuftragNr + 1;
    }
    
    print("🔍 آخر auftragNr موجود: $maxAuftragNr");
    print("🔢 الرقم الجديد سيبدأ من: $newAuftragNr");
    
    // تحديث كل الأجهزة مع الأرقام الجديدة
    List<Map<String, dynamic>> updatedDevices = [];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      String? existingAuftragNr;
      
      // فحص إذا كان الجهاز له auftragNr من قبل
      if (data.containsKey('auftragNr') && data['auftragNr'] != null && data['auftragNr'].toString().isNotEmpty) {
        existingAuftragNr = data['auftragNr'].toString();
        print("📱 الجهاز له auftragNr موجود: $existingAuftragNr");
      } else {
        print("📱 الجهاز بدون auftragNr");
      }
      
      String finalAuftragNr;
      // إذا كان الجهاز له auftragNr صحيح للسنة الحالية، نستخدمه
      if (existingAuftragNr != null && 
          existingAuftragNr.startsWith('$yearSuffix/') && 
          existingAuftragNr.isNotEmpty &&
          existingAuftragNr != '$yearSuffix/0') {
        // الجهاز له auftragNr صحيح، نستخدمه
        finalAuftragNr = existingAuftragNr;
        print("✅ استخدام auftragNr موجود: $finalAuftragNr");
      } else {
        // الجهاز جديد أو بدون auftragNr صحيح، نولد auftragNr جديد للسنة الحالية
        finalAuftragNr = '$yearSuffix/$newAuftragNr';
        print("🆕 جهاز جديد يحصل على auftragNr: $finalAuftragNr");
        newAuftragNr++; // زيادة الرقم للجهاز التالي
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

