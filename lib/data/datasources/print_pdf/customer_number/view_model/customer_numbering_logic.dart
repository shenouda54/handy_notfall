import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerNumberingService {
  static Future<Map<String, dynamic>> assignCustomerNumber(String customerName, String customerPhone, {String? currentDocId}) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) {
      return {"success": false, "message": "❌ Sie sind nicht eingeloggt.", "devices": []};
    }

    // البحث عن أجهزة "أخرى" للعميل (Siblings)
    final snapshot = await FirebaseFirestore.instance
        .collection('Customers')
        .where('customerFirstName', isEqualTo: customerName)
        .where('phoneNumber', isEqualTo: customerPhone)
        .get();

    // لو مفيش أجهزة تانية، ومش باعتين ID الجهاز الحالي، يبقى مفيش حاجة نعملها
    if (snapshot.docs.isEmpty && currentDocId == null) {
      return {"success": false, "message": "❌ Für diesen Kunden wurden keine Geräte gefunden.", "devices": []};
    }

    // تحديد رقم العميل (Kundennummer)
    int? existingKundennummer;
    
    // دور في الأجهزة الموجودة (إن وجدت)
    if (snapshot.docs.isNotEmpty) {
       final firstDoc = snapshot.docs.first.data();
       if (firstDoc.containsKey('kundennummer')) {
         existingKundennummer = firstDoc['kundennummer'];
       }
    }
    
    int newKundennummer;
    if (existingKundennummer != null) {
      newKundennummer = existingKundennummer;
    } else {
      // عميل جديد تماماً (أو أجهزته القديمة ملهاش رقم لسه)
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
    
    // تجهيز رقم الطلب (AuftragNr)
    final currentYear = DateTime.now().year;
    final yearSuffix = currentYear.toString().substring(3); // e.g. "6" from 2026? Wait, code says substring(3) of 2025 is "5". 
    // Correction: substring(2) is last 2 digits. previous code was using substring(3) which is only the last digit? 
    // wait, existing logic says: final yearSuffix = currentYear.toString().substring(3); -> if 2025 -> "5".
    // But formats are like "25/...".
    // Let's look at previous code: `startsWith('$yearSuffix/')`. 
    // If yearSuffix was just "5", it matches "5/..." which is weird.
    // Let's stick to standard "YY".
    // Actually, looking at the previous file content (Step 30):
    // line 54: final yearSuffix = currentYear.toString().substring(3);
    // If 2025 -> returns "5". That looks wrong if we want "25". 
    // HOWEVER, the user said "26/..." so it must be 2 digits.
    // Let's fix it to be consistently 2 digits: substring(2).
    
    // UPDATED LOGIC: Continuous increment
    // 1. Get ALL customers for this user (to find the absolute max, regardless of year)
    final auftragNrSnapshot = await FirebaseFirestore.instance
        .collection('Customers')
        .where('userEmail', isEqualTo: userEmail)
        .get();
    
    int maxAuftragNr = 0;
    if (auftragNrSnapshot.docs.isNotEmpty) {
      for (final doc in auftragNrSnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('auftragNr')) {
          final String? auftragNr = data['auftragNr']?.toString();
          // Format expected: YY/Number (e.g. 25/500, 26/501) OR single digit Y/Number (5/500)
          if (auftragNr != null && auftragNr.contains('/')) {
             final parts = auftragNr.split('/');
             if (parts.length == 2) {
               final num = int.tryParse(parts[1]) ?? 0;
               // We take max from ANY valid format
               if (num > maxAuftragNr) maxAuftragNr = num;
             }
          }
        }
      }
    }
    
    int nextAuftragNr = maxAuftragNr + 1;
    final currentYearSuffix2Digits = DateTime.now().year.toString().substring(2); // "26"

    List<Map<String, dynamic>> updatedDevices = [];

    // دالة مساعدة لتحديث جهاز واحد
    Future<void> updateDevice(DocumentReference ref, Map<String, dynamic> data) async {
       String finalAuftragNr;
       String? existingAuftrag = data['auftragNr']?.toString();
       
       // الاحتفاظ بالرقم القديم لو موجود، بشرط يكون صالح (مش "/0")
       if (existingAuftrag != null && existingAuftrag.contains('/') && !existingAuftrag.endsWith('/0')) {
         finalAuftragNr = existingAuftrag;
       } else {
         // توليد رقم جديد مكمل للسلسلة
         finalAuftragNr = '$currentYearSuffix2Digits/$nextAuftragNr';
         nextAuftragNr++; // زيادة العداد للجهاز التالي
       }
       
       await ref.update({
         'kundennummer': newKundennummer,
         'auftragNr': finalAuftragNr,
       });
       
       data['kundennummer'] = newKundennummer;
       data['auftragNr'] = finalAuftragNr;
       updatedDevices.add(data);
    }

    // 1. تحديث الأجهزة القديمة (لو فيه)
    for (final doc in snapshot.docs) {
      // لو الجهاز القديم هو نفسه الحالي (ظهر في البحث)، هنحدثه هنا
      if (currentDocId != null && doc.id == currentDocId) continue; 
      await updateDevice(doc.reference, doc.data());
    }

    // 2. تحديث الجهاز الحالي (لو باعتين الـ ID بتاعه) - ده المهم!
    // بنعمل كده عشان لو السيرش لسه مش شايفه (Lag)، احنا شايفينه وعارفين الـ ID
    if (currentDocId != null) {
      final currentDocRef = FirebaseFirestore.instance.collection('Customers').doc(currentDocId);
      final currentDocHelp = await currentDocRef.get(); // Get Fresh Data Check
      if (currentDocHelp.exists) {
         // تأكد إننا مش بنحدثه مرتين (لو كان ظهر في اللوب فوق وعملنا continue)
         // اللوجيك فوق عمل skip لو الـ ID مطابق، فـ هنا أمان
         await updateDevice(currentDocRef, currentDocHelp.data()!);
      }
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

