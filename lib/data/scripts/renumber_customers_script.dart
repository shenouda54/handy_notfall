import 'package:cloud_firestore/cloud_firestore.dart';

class RenumberCustomersScript {
  static Future<void> renumberAllCustomers() async {
    print("🚀 بدء سكريبت إعادة ترقيم العملاء...");
    
    try {
      // 1. جلب جميع الأجهزة
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
        
        // 4. تجميع الأجهزة حسب العميل (الاسم + رقم الهاتف)
        Map<String, List<DocumentSnapshot>> customerDevices = {};
        
        for (final device in devices) {
          final data = device.data() as Map<String, dynamic>;
          final customerName = data['customerFirstName'] as String? ?? '';
          final phoneNumber = data['phoneNumber'] as String? ?? '';
          final customerKey = '$customerName|$phoneNumber';
          
          if (!customerDevices.containsKey(customerKey)) {
            customerDevices[customerKey] = [];
          }
          customerDevices[customerKey]!.add(device);
        }
        
        print("👥 عدد العملاء: ${customerDevices.length}");
        
        // 5. ترتيب العملاء حسب التاريخ الأقدم
        final sortedCustomers = customerDevices.entries.toList();
        sortedCustomers.sort((a, b) {
          // نأخذ أقدم تاريخ من أجهزة العميل
          final aDevices = a.value;
          final bDevices = b.value;
          
          final aOldestDate = _getOldestDate(aDevices);
          final bOldestDate = _getOldestDate(bDevices);
          
          if (aOldestDate == null && bOldestDate == null) return 0;
          if (aOldestDate == null) return 1; // العملاء بدون تاريخ في النهاية
          if (bOldestDate == null) return -1;
          
          return aOldestDate.compareTo(bOldestDate); // الأقدم أولاً
        });
        
        // 6. إعادة ترقيم العملاء
        for (int i = 0; i < sortedCustomers.length; i++) {
          final customerEntry = sortedCustomers[i];
          final customerKey = customerEntry.key;
          final customerDevices = customerEntry.value;
          final newKundennummer = i + 1;
          
          final customerName = customerKey.split('|')[0];
          final phoneNumber = customerKey.split('|')[1];
          final oldKundennummer = (customerDevices.first.data() as Map<String, dynamic>?)?['kundennummer']?.toString() ?? 'غير مرقم';
          
          print("  👤 $customerName ($phoneNumber): $oldKundennummer → $newKundennummer");
          
          // تحديث جميع أجهزة العميل
          for (final device in customerDevices) {
            await device.reference.update({
              'kundennummer': newKundennummer,
              // لا نغير auftragNr - نتركه كما هو
            });
          }
        }
        
        print("✅ تم إعادة ترقيم ${sortedCustomers.length} عميل للمستخدم: $userEmail");
      }
      
      print("\n🎉 تم إعادة ترقيم جميع العملاء بنجاح!");
      print("📊 إجمالي المستخدمين: ${userDevices.length}");
      print("📱 إجمالي الأجهزة: ${allDevices.docs.length}");
      
    } catch (e) {
      print("❌ خطأ في سكريبت إعادة ترقيم العملاء: $e");
      rethrow;
    }
  }
  
  // دالة للحصول على أقدم تاريخ من قائمة الأجهزة
  static Timestamp? _getOldestDate(List<DocumentSnapshot> devices) {
    Timestamp? oldestDate;
    
    for (final device in devices) {
      final data = device.data() as Map<String, dynamic>;
      final startDate = data['startDate'] as Timestamp?;
      
      if (startDate != null) {
        if (oldestDate == null || startDate.compareTo(oldestDate) < 0) {
          oldestDate = startDate;
        }
      }
    }
    
    return oldestDate;
  }
  
  // دالة لمعاينة التغييرات قبل التطبيق
  static Future<void> previewCustomerRenumbering() async {
    print("🔍 معاينة إعادة ترقيم العملاء...");
    
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
        
        // تجميع الأجهزة حسب العميل
        Map<String, List<DocumentSnapshot>> customerDevices = {};
        
        for (final device in devices) {
          final data = device.data() as Map<String, dynamic>;
          final customerName = data['customerFirstName'] as String? ?? '';
          final phoneNumber = data['phoneNumber'] as String? ?? '';
          final customerKey = '$customerName|$phoneNumber';
          
          if (!customerDevices.containsKey(customerKey)) {
            customerDevices[customerKey] = [];
          }
          customerDevices[customerKey]!.add(device);
        }
        
        print("👥 عدد العملاء: ${customerDevices.length}");
        
        // ترتيب العملاء حسب التاريخ الأقدم
        final sortedCustomers = customerDevices.entries.toList();
        sortedCustomers.sort((a, b) {
          final aOldestDate = _getOldestDate(a.value);
          final bOldestDate = _getOldestDate(b.value);
          
          if (aOldestDate == null && bOldestDate == null) return 0;
          if (aOldestDate == null) return 1;
          if (bOldestDate == null) return -1;
          
          return aOldestDate.compareTo(bOldestDate);
        });
        
        // معاينة الترقيم الجديد
        for (int i = 0; i < sortedCustomers.length; i++) {
          final customerEntry = sortedCustomers[i];
          final customerKey = customerEntry.key;
          final customerDevices = customerEntry.value;
          final newKundennummer = i + 1;
          
          final customerName = customerKey.split('|')[0];
          final phoneNumber = customerKey.split('|')[1];
          final oldKundennummer = (customerDevices.first.data() as Map<String, dynamic>?)?['kundennummer']?.toString() ?? 'غير مرقم';
          final oldestDate = _getOldestDate(customerDevices);
          final oldestDateStr = oldestDate != null 
              ? oldestDate.toDate().toString().substring(0, 10)
              : 'بدون تاريخ';
          final deviceCount = customerDevices.length;
          
          print("  👤 $customerName ($phoneNumber) - $deviceCount جهاز ($oldestDateStr): $oldKundennummer → $newKundennummer");
          
          // عرض auftragNr للأجهزة (للتأكد من عدم تغييرها)
          for (final device in customerDevices) {
            final deviceData = device.data() as Map<String, dynamic>;
            final deviceType = deviceData['deviceType']?.toString() ?? 'غير محدد';
            final auftragNr = deviceData['auftragNr']?.toString() ?? 'غير مرقم';
            print("    📱 $deviceType: $auftragNr (سيبقى كما هو)");
          }
        }
      }
      
      print("\n🔍 انتهت معاينة ترقيم العملاء. هل تريد تطبيق التغييرات؟");
      
    } catch (e) {
      print("❌ خطأ في معاينة إعادة ترقيم العملاء: $e");
      rethrow;
    }
  }
}
