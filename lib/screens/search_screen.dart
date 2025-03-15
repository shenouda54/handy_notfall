import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    fetchCustomers(); // تحميل البيانات عند فتح الشاشة
  }

  /// 🔥 **تحميل البيانات من Firestore**
  Future<void> fetchCustomers() async {
    try {
      String? userEmail = FirebaseAuth.instance.currentUser?.email; // 🔥 احصل على الإيميل الحالي

      if (userEmail == null) {
        print(" لم يتم العثور على المستخدم الحالي!");
        return;
      }
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Customers')
          .where('userEmail', isEqualTo: userEmail) // ✅ جلب البيانات المرتبطة فقط بالمستخدم الحالي
          .get();
      List<Map<String, dynamic>> customerList = querySnapshot.docs.map((doc) {
        return {
          "firstName": doc["customerFirstName"] ?? "",
          "lastName": doc["customerLastName"] ?? "",
          "phone": doc["phoneNumber"] ?? "",
          "id": doc.id, // تخزين الـ ID لو احتجنا تحديث أو حذف العميل
        };
      }).toList();

      setState(() {
        customers = customerList;
        filteredCustomers = customers;
      });
    } catch (e) {
      print("❌ خطأ في جلب البيانات: $e");
    }
  }

  ///  **البحث في البيانات**
  void filterSearchResults(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = customers;
      } else {
        filteredCustomers = customers.where((customer) {
          return customer["firstName"]
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              customer["lastName"]
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              customer["phone"].contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search customers...",
            border: InputBorder.none,
          ),
          onChanged: filterSearchResults,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 🔙 زر الرجوع للخلف
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              searchController.clear();
              filterSearchResults("");
            },
          ),
        ],
      ),
      body: filteredCustomers.isEmpty
          ? const Center(child: Text("No results found"))
          : ListView.builder(
              itemCount: filteredCustomers.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    "${filteredCustomers[index]['firstName']} ${filteredCustomers[index]['lastName']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Phone: ${filteredCustomers[index]['phone']}"),
                  leading: const Icon(Icons.person),
                );
              },
            ),
    );
  }
}
