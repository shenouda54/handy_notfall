import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RechnungNumberingService {
  /// يولّد كود Rechnung على شكل YY/00NNN...
  /// - الكود مرتبط بحساب المستخدم الحالي (userEmail) فقط - كل حساب منعزل تماماً.
  /// - كل سنة منعزلة تماماً - الترقيم يبدأ من 1 في كل سنة جديدة.
  /// - الصيغة: YY/00 + الرقم كما هو (بدون padding) - مثال: 26/001, 26/0010, 26/00100
  /// - إذا كان للسجل كود موجود، نعيده كما هو بلا زيادة.
  static Future<Map<String, dynamic>> assignRechnungCode({
    required String customerId,
  }) async {
    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) {
      return {
        "success": false,
        "message": "❌ لا يوجد مستخدم مسجّل دخول.",
      };
    }

    try {
      final customerRef =
          FirebaseFirestore.instance.collection('Customers').doc(customerId);
      final customerDoc = await customerRef.get();

      if (!customerDoc.exists) {
        return {
          "success": false,
          "message": "❌ لم يتم العثور على العميل المطلوب.",
        };
      }

      final customerData = customerDoc.data() ?? {};
      final auftragNr = customerData['auftragNr']?.toString();

      // شرط أساسي: لازم يكون فيه رقم طلب (AuftragNr) عشان نولد كود فاتورة
      if (auftragNr == null || auftragNr.isEmpty) {
        return {
          "success": false,
          "message": "❌ لا يمكن توليد كود فاتورة لهذا العميل لأنه لا يملك رقم طلب (AuftragNr).",
        };
      }

      final existingCode = customerData['rechnungCode']?.toString();

      // لو فيه كود جاهز، نرجعه كما هو
      if (existingCode != null && existingCode.isNotEmpty) {
        return {
          "success": true,
          "message": "ℹ️ تم استخدام الكود الحالي.",
          "rechnungCode": existingCode,
          "isNew": false,
        };
      }

      // تحديد أعلى رقم مستخدم لكل سجلات نفس المستخدم ونفس السنة فقط (كل حساب منعزل + كل سنة منعزلة)
      final yearSuffix = DateTime.now().year % 100; // 2025 -> 25
      final yearPrefix = yearSuffix.toString().padLeft(2, '0'); // "25"
      
      final userCustomers = await FirebaseFirestore.instance
          .collection('Customers')
          .where('userEmail', isEqualTo: userEmail)
          .get();

      int maxCounter = 0;
      for (final doc in userCustomers.docs) {
        final code = doc.data()['rechnungCode']?.toString();
        if (code == null || code.isEmpty) continue;

        // البحث عن الصيغة الجديدة: YY/00NNN أو الصيغة القديمة: YY/NNN (للتوافق)
        // لكن نتحقق إن الكود يبدأ بنفس السنة الحالية فقط
        final match = RegExp(r'^(\d{2})/00?(\d+)$').firstMatch(code);
        if (match != null) {
          final codeYear = match.group(1); // السنة من الكود
          final num = int.tryParse(match.group(2) ?? '0') ?? 0;
          
          // نضيف للـ maxCounter فقط لو الكود من نفس السنة الحالية
          if (codeYear == yearPrefix && num > maxCounter) {
            maxCounter = num;
          }
        }
      }

      final newCounter = maxCounter + 1;
      // الصيغة الجديدة: YY/00 + الرقم كما هو (بدون padding)
      // مثال: 26/001, 26/0010, 26/00100
      final rechnungCode =
          '${yearSuffix.toString().padLeft(2, '0')}/00$newCounter';

      await customerRef.update({
        "rechnungCode": rechnungCode,
        "endDate": Timestamp.now(),
      });

      return {
        "success": true,
        "message": "✅ تم إنشاء كود Rechnung جديد.",
        "rechnungCode": rechnungCode,
        "isNew": true,
      };
    } catch (e) {
      return {
        "success": false,
        "message": "❌ فشل في توليد الكود: $e",
      };
    }
  }
}



