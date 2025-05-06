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
  final TextEditingController modelController = TextEditingController();

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];

  int currentPage = 0;
  final int itemsPerPage = 10;

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
        filteredCustomers = customerList;
        currentPage = 0;
      });
    } catch (e) {
      print("❌ خطأ في جلب البيانات: $e");
    }
  }

  void filterSearch() {
    String query = searchController.text.toLowerCase();
    String selectedDate = dateController.text.trim();
    String modelText = modelController.text.toLowerCase();

    setState(() {
      filteredCustomers = customers.where((customer) {
        bool matchesSearch =
            customer["firstName"].toLowerCase().contains(query) ||
                customer["phone"].contains(query);

        bool matchesDeviceText = modelText.isEmpty ||
            customer["deviceType"].toLowerCase().contains(modelText) ||
            customer["deviceModel"].toLowerCase().contains(modelText);

        bool matchesDate = selectedDate.isEmpty
            ? true
            : DateFormat('yyyy-MM-dd').format(customer["startDate"]) ==
                selectedDate;

        return matchesSearch && matchesDeviceText && matchesDate;
      }).toList();

      currentPage = 0;
    });
  }

  List<Map<String, dynamic>> getPaginatedItems() {
    final start = currentPage * itemsPerPage;
    final end = start + itemsPerPage;
    return filteredCustomers.sublist(
        start, end > filteredCustomers.length ? filteredCustomers.length : end);
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
    final paginatedItems = getPaginatedItems();

    return Scaffold(
      appBar: AppBar(title: const Text("Suche Kunden")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: "Suche nach Name oder Telefonnummer...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => filterSearch(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelController,
              decoration: const InputDecoration(
                labelText: "Gerätemodell eingeben...",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => filterSearch(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Filtern nach Startdatum",
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (dateController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            dateController.clear();
                            filteredCustomers = customers;
                            currentPage = 0;
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: pickDate,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: paginatedItems.isEmpty
                  ? const Center(child: Text("Keine Ergebnisse gefunden"))
                  : ListView.builder(
                      itemCount: paginatedItems.length,
                      itemBuilder: (context, index) {
                        final customer = paginatedItems[index];
                        return Card(
                          child: CustomerListTile(
                            customer: customer,
                            onEdit: fetchCustomers,
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: currentPage > 0
                      ? () => setState(() => currentPage--)
                      : null,
                  child: const Text("Zurück"),
                ),
                Text(
                  "Seite ${currentPage + 1} / ${((filteredCustomers.length - 1) / itemsPerPage).ceil() + 1}",
                ),
                ElevatedButton(
                  onPressed: (currentPage + 1) * itemsPerPage <
                          filteredCustomers.length
                      ? () => setState(() => currentPage++)
                      : null,
                  child: const Text("Weiter"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
