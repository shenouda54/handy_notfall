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
  final TextEditingController invoiceAddressController = TextEditingController();

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];

  int currentPage = 0;
  final int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  // دالة منفصلة لإضافة عميل جديد
  Future<void> refreshAfterAdd() async {
    await fetchCustomers(clearFilters: true);
  }

  Future<void> fetchCustomers({bool clearFilters = false}) async {
    try {
      String? userEmail = FirebaseAuth.instance.currentUser?.email;
      if (userEmail == null) {
        throw Exception("User not authenticated");
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
          "auftragNr": doc.data().toString().contains('auftragNr') ? doc['auftragNr'] : "",
          "rechnungCode": doc.data().toString().contains('rechnungCode') ? doc['rechnungCode'] : "",
        };
      }).toList();

      setState(() {
        customers = customerList;
        
        if (clearFilters) {
          // مسح الفلاتر عند إضافة عميل جديد لضمان ظهوره
          searchController.clear();
          dateController.clear();
          dateController.clear();
          modelController.clear();
          invoiceAddressController.clear();
          filteredCustomers = customerList;
        } else {
          // إعادة تطبيق الفلاتر الحالية بعد جلب البيانات الجديدة
          filterSearch();
        }
        
        currentPage = 0;
      });
    } catch (e) {
      print("❌ خطأ في جلب البيانات: $e");
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void filterSearch() {
    String query = searchController.text.toLowerCase();
    String selectedDate = dateController.text.trim();
    String modelText = modelController.text.toLowerCase();
    String invoiceAddressText = invoiceAddressController.text.toLowerCase();

    setState(() {
      filteredCustomers = customers.where((customer) {
        bool matchesSearch =
            customer["firstName"].toLowerCase().contains(query) ||
                customer["phone"].contains(query);

        bool matchesDeviceText = modelText.isEmpty ||
            customer["deviceType"].toLowerCase().contains(modelText) ||
            customer["deviceModel"].toLowerCase().contains(modelText);

        String fullAddress = "${customer["address"] ?? ""} ${customer["city"] ?? ""}".toLowerCase();
        
        bool matchesInvoiceAddress = invoiceAddressText.isEmpty ||
            (customer["rechnungCode"] != null &&
                customer["rechnungCode"].toString().toLowerCase().contains(invoiceAddressText)) ||
             fullAddress.contains(invoiceAddressText);

        bool matchesDate = selectedDate.isEmpty
            ? true
            : DateFormat('yyyy-MM-dd').format(customer["startDate"]) ==
                selectedDate;

        return matchesSearch && matchesDeviceText && matchesInvoiceAddress && matchesDate;
      }).toList();

      currentPage = 0; // إعادة تعيين الصفحة إلى الأولى
    });
  }

  List<Map<String, dynamic>> getPaginatedItems() {
    final start = currentPage * itemsPerPage;
    final end = start + itemsPerPage;
    return filteredCustomers.sublist(
        start, end > filteredCustomers.length ? filteredCustomers.length : end);
  }

  //TODO: class new any were
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
    filteredCustomers.sort((a, b) => b["startDate"].compareTo(a["startDate"]));
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
              controller: invoiceAddressController,
              decoration: const InputDecoration(
                labelText: "Suche nach Rechnungsnr. oder Adresse...",
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
                            onAdd: refreshAfterAdd,
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
