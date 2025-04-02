import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/models/customer_list_tile.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String? selectedDeviceType;

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];

  final List<String> deviceTypes = [
    'Dell',
    'Apple',
    'Samsung',
    'HP',
    'Lenovo',
    'Sony',
    'LG',
    'Huawei',
    'Toshiba',
    'Asus',
    'Acer',
    'Microsoft',
    'Realme',
    'HTC',
    'Motorola',
    'Blackberry',
    'Xiaomi',
    'Oppo',
    'Google',
    'Oneplus'
  ];

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      String? userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) {
        print("❌ لم يتم العثور على المستخدم الحالي!");
        return;
      }
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Customers')
          .where('userEmail', isEqualTo: userEmail)
          .get();

      List<Map<String, dynamic>> customerList = querySnapshot.docs.map((doc) {
        return {
          "firstName": doc["customerFirstName"] ?? "",
          "phone": doc["phoneNumber"] ?? "",
          "deviceType": doc["deviceType"] ?? "",
          "deviceModel": doc["deviceModel"] ?? "",
          "pinCode": doc["pinCode"] ?? "",
          "startDate": doc["startDate"] != null
              ? (doc["startDate"] as Timestamp).toDate()
              : DateTime.now(),
          "price": doc["price"] ?? 0,
          "issue": doc["issue"] ?? "",
          "address": doc["address"] ?? "",
          "city": doc["city"] ?? "",
          "email": doc["emailAddress"] ?? "",
          "id": doc.id,
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

  void filterSearch() {
    String query = searchController.text.toLowerCase();
    String? selectedType = selectedDeviceType;
    String selectedDate = dateController.text.trim();

    setState(() {
      filteredCustomers = customers.where((customer) {
        bool matchesSearch =
            customer["firstName"].toLowerCase().contains(query) ||
                customer["phone"].contains(query);

        bool matchesDevice = selectedType == null || selectedType.isEmpty
            ? true
            : customer["deviceType"] == selectedType;

        bool matchesDate = selectedDate.isEmpty
            ? true
            : DateFormat('yyyy-MM-dd').format(customer["startDate"]) ==
                selectedDate;

        return matchesSearch && matchesDevice && matchesDate;
      }).toList();
    });
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      filterSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Suche Kunden")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Field
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Suche nach Name oder Telefonnummer...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => filterSearch(),
            ),
            const SizedBox(height: 12),

            // Device Type Dropdown
            DropdownButtonFormField<String>(
              value: selectedDeviceType,
              decoration: const InputDecoration(
                labelText: "Filter nach Gerätetyp",
                border: OutlineInputBorder(),
              ),
              items: deviceTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                selectedDeviceType = value;
                filterSearch();
              },
            ),
            const SizedBox(height: 12),

            // Date Filter
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Filtern nach Startdatum",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: pickDate,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Results
            Expanded(
              child: filteredCustomers.isEmpty
                  ? const Center(child: Text("Keine Ergebnisse gefunden"))
                  : ListView.builder(
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        return Card(
                            child: CustomerListTile(
                          customer: customer,
                          onEdit: fetchCustomers, //  عشان يعمل تحديث مباشرة
                        ));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
