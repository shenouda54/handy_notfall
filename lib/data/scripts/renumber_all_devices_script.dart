import 'package:cloud_firestore/cloud_firestore.dart';

class RenumberAllDevicesScript {
  static Future<void> renumberAllDevices() async {
    print("🚀 بدء سكريبت إعادة ترقيم جميع الأجهزة...");
    
    try {
      // 1. جلب جميع المستخدمين الفريدين
      final allDevices = await FirebaseFirestore.instance
          .collection('Customers')
          .get();
      
      if (allDevices.docs.isEmpty) {
        print("❌ لا توجد أجهزة في قاعدة البيانات");
        return;
      }
      
      // 2. تجميع الأجهزة حسب المستخدم
      Map<String, List<DocumentSnapshot>> userDevices = {};
      
      for (final doc in allDevices.docs) {
        final data = doc.data();
        final userEmail = data['userEmail'] as String?;
        
        if (userEmail != null) {
          if (!userDevices.containsKey(userEmail)) {
            userDevices[userEmail] = [];
          }
          userDevices[userEmail]!.add(doc);
        }
      }
      
      print("📊 تم العثور على ${userDevices.length} مستخدم");
      
      // 3. معالجة كل مستخدم
      for (final entry in userDevices.entries) {
        final userEmail = entry.key;
        final devices = entry.value;
        
        print("\n👤 معالجة المستخدم: $userEmail");
        print("📱 عدد الأجهزة: ${devices.length}");
        
        // 4. ترتيب الأجهزة حسب startDate
        devices.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          
          final aStartDate = aData['startDate'] as Timestamp?;
          final bStartDate = bData['startDate'] as Timestamp?;
          
          if (aStartDate == null && bStartDate == null) return 0;
          if (aStartDate == null) return 1; // الأجهزة بدون تاريخ في النهاية
          if (bStartDate == null) return -1;
          
          return aStartDate.compareTo(bStartDate); // الأقدم أولاً
        });
        
        // 5. إعادة ترقيم الأجهزة
        final currentYear = DateTime.now().year;
        final yearSuffix = currentYear.toString().substring(3); // 2025 → 5
        
        for (int i = 0; i < devices.length; i++) {
          final device = devices[i];
          final newAuftragNr = '$yearSuffix/${i + 1}';
          
          final deviceData = device.data() as Map<String, dynamic>;
          final oldAuftragNr = deviceData['auftragNr']?.toString() ?? 'غير مرقم';
          final deviceName = deviceData['deviceType']?.toString() ?? 'غير محدد';
          
          print("  📱 $deviceName: $oldAuftragNr → $newAuftragNr");
          
          // تحديث الجهاز في قاعدة البيانات
          await device.reference.update({
            'auftragNr': newAuftragNr,
          });
        }
        
        print("✅ تم إعادة ترقيم ${devices.length} جهاز للمستخدم: $userEmail");
      }
      
      print("\n🎉 تم إعادة ترقيم جميع الأجهزة بنجاح!");
      print("📊 إجمالي المستخدمين: ${userDevices.length}");
      print("📱 إجمالي الأجهزة: ${allDevices.docs.length}");
      
    } catch (e) {
      print("❌ خطأ في سكريبت إعادة الترقيم: $e");
      rethrow;
    }
  }
  
  // دالة لمعاينة التغييرات قبل التطبيق
  static Future<void> previewRenumbering() async {
    print("🔍 معاينة إعادة الترقيم...");
    
    try {
      final allDevices = await FirebaseFirestore.instance
          .collection('Customers')
          .get();
      
      if (allDevices.docs.isEmpty) {
        print("❌ لا توجد أجهزة في قاعدة البيانات");
        return;
      }
      
      // تجميع الأجهزة حسب المستخدم
      Map<String, List<DocumentSnapshot>> userDevices = {};
      
      for (final doc in allDevices.docs) {
        final data = doc.data();
        final userEmail = data['userEmail'] as String?;
        
        if (userEmail != null) {
          if (!userDevices.containsKey(userEmail)) {
            userDevices[userEmail] = [];
          }
          userDevices[userEmail]!.add(doc);
        }
      }
      
      print("📊 سيتم معالجة ${userDevices.length} مستخدم");
      
      // معاينة كل مستخدم
      for (final entry in userDevices.entries) {
        final userEmail = entry.key;
        final devices = entry.value;
        
        print("\n👤 المستخدم: $userEmail");
        print("📱 عدد الأجهزة: ${devices.length}");
        
        // ترتيب الأجهزة حسب startDate
        devices.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          
          final aStartDate = aData['startDate'] as Timestamp?;
          final bStartDate = bData['startDate'] as Timestamp?;
          
          if (aStartDate == null && bStartDate == null) return 0;
          if (aStartDate == null) return 1;
          if (bStartDate == null) return -1;
          
          return aStartDate.compareTo(bStartDate);
        });
        
        // معاينة الترقيم الجديد
        final currentYear = DateTime.now().year;
        final yearSuffix = currentYear.toString().substring(3);
        
        for (int i = 0; i < devices.length; i++) {
          final device = devices[i];
          final newAuftragNr = '$yearSuffix/${i + 1}';
          
          final deviceData = device.data() as Map<String, dynamic>;
          final oldAuftragNr = deviceData['auftragNr']?.toString() ?? 'غير مرقم';
          final deviceName = deviceData['deviceType']?.toString() ?? 'غير محدد';
          final startDate = deviceData['startDate'] as Timestamp?;
          final startDateStr = startDate != null 
              ? startDate.toDate().toString().substring(0, 10)
              : 'بدون تاريخ';
          
          print("  📱 $deviceName ($startDateStr): $oldAuftragNr → $newAuftragNr");
        }
      }
      
      print("\n🔍 انتهت المعاينة. هل تريد تطبيق التغييرات؟");
      
    } catch (e) {
      print("❌ خطأ في معاينة إعادة الترقيم: $e");
      rethrow;
    }
  }
}
