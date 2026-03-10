import 'package:cloud_firestore/cloud_firestore.dart';

class AuftragMigrationService {
  /// يقوم بتصحيح أرقام الطلبات لكل المستخدمين دفعة واحدة
  /// - يقسم العملاء لمجموعات حسب الإيميل
  /// - لكل إيميل: يجد أكبر رقم في 2025، ويكمل العد منه لطلبات 2026
  static Future<Map<String, dynamic>> migrateAllUsersData() async {
    try {
      print('🚀 Starting Global Migration...');
      
      final firestore = FirebaseFirestore.instance;
      final QuerySnapshot allCustomers = await firestore.collection('Customers').get();

      if (allCustomers.docs.isEmpty) {
        print('⚠️ No customers found in database.');
        return {"success": true, "message": "لا يوجد عملاء في قاعدة البيانات.", "count": 0};
      }

      print('📊 Found ${allCustomers.docs.length} total customer documents.');

      // 2. تقسيم العملاء حسب الإيميل
      Map<String, List<QueryDocumentSnapshot>> usersMap = {};
      
      for (var doc in allCustomers.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final email = data['userEmail']?.toString() ?? 'unknown_user';
        
        if (!usersMap.containsKey(email)) {
          usersMap[email] = [];
        }
        usersMap[email]!.add(doc);
      }
      
      print('👥 Found ${usersMap.length} unique user groups.');

      int totalUpdatedDocs = 0;
      WriteBatch batch = firestore.batch();
      int batchCount = 0; 

      for (String email in usersMap.keys) {
        print('\n--- Processing User: $email ---');
        List<QueryDocumentSnapshot> userDocs = usersMap[email]!;
        print('   > Total docs for user: ${userDocs.length}');
        
        // DEBUG: Print first 10 auftragNrs to see their format
        print('   --- DEBUG: First 10 AuftragNrs ---');
        for (var i = 0; i < userDocs.length && i < 10; i++) {
           final da = userDocs[i].data() as Map<String, dynamic>;
           print('      [$i] auftragNr: "${da['auftragNr']}", startDate: ${da['startDate']}');
        }
        print('   ----------------------------------');


        // --- خطوة أ: إيجاد أكبر رقم في 2025 ---
        int maxCounter2025 = 0;
        
        // نبحث عن أي صيغة تشبه 25/xxx أو 5/xxx (لأن الداتا القديمة فيها 5/...)
        for (var doc in userDocs) {
          final data = doc.data() as Map<String, dynamic>;
          final code = data['auftragNr']?.toString(); 
          
          if (code != null) {
             // Check for '25/' OR '5/'
             if (code.startsWith('25/') || code.startsWith('5/')) {
               final parts = code.split('/');
               if (parts.length == 2) {
                 final num = int.tryParse(parts[1]) ?? 0;
                 if (num > maxCounter2025) maxCounter2025 = num;
               }
             }
          }
        }
        print('   > Max Counter for 2025: $maxCounter2025');

        // --- خطوة ب: تحديد وتحديث طلبات 2026 ---
        // نجمع كل من يبدأ بـ 26/ أو 6/ 
        // ونحولهم كلهم للصيغة الجديدة 26/xxx
        
        List<QueryDocumentSnapshot> docs2026 = userDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final code = data['auftragNr']?.toString();
          // Target '26/' OR '6/'
          return code != null && (code.startsWith('26/') || code.startsWith('6/'));
        }).toList();

        print('   > Found ${docs2026.length} docs for 2026 to update.');

        docs2026.sort((a, b) {
           final dataA = a.data() as Map<String, dynamic>;
           final dataB = b.data() as Map<String, dynamic>;
           final timeA = dataA['startDate'] is Timestamp ? (dataA['startDate'] as Timestamp).toDate() : DateTime(2000);
           final timeB = dataB['startDate'] is Timestamp ? (dataB['startDate'] as Timestamp).toDate() : DateTime(2000);
           return timeA.compareTo(timeB);
        });

        int currentCounter = maxCounter2025 + 1; 
        
        for (var doc in docs2026) {
          final oldCode = (doc.data() as Map<String, dynamic>)['auftragNr'];
          final newCode = "26/$currentCounter";
          
          if (oldCode != newCode) {
             print('   > Updating Doc ID: ${doc.id} | Old: $oldCode -> New: $newCode');
             batch.update(doc.reference, {'auftragNr': newCode});
             
             totalUpdatedDocs++;
             batchCount++;
             currentCounter++;
          } else {
             print('   > Skipping Doc ID: ${doc.id} | Already correct: $newCode');
             currentCounter++; // Still increment counter to keep sequence
          }

          if (batchCount >= 450) {
            print('   > Batch full (450), committing...');
            await batch.commit();
            batch = firestore.batch();
            batchCount = 0;
          }
        }
      }

      if (batchCount > 0) {
        print('   > Committing final batch...');
        await batch.commit();
      }

      print('\n✅ Migration Complete. Updated $totalUpdatedDocs documents.');

      return {
        "success": true, 
        "message": "✅ تم تحديث $totalUpdatedDocs وثيقة لـ ${usersMap.length} مستخدمين. (شاهد الكونسول للتفاصيل)",
        "count": totalUpdatedDocs
      };

    } catch (e) {
      print('❌ ERROR during migration: $e');
      return {
        "success": false,
        "message": "❌ حدث خطأ: $e",
        "count": 0
      };
    }
  }
}
