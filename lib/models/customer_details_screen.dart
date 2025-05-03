import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/data/print_pdf/customer_number/view/customer_numbering_screen.dart';
import 'package:handy_notfall/data/print_pdf/generate_pdf/view_model/pdf_logic.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final String customerId;
  const CustomerDetailsScreen({super.key, required this.customerId});

  Future<DocumentSnapshot> fetchCustomerDetails() async {
    return await FirebaseFirestore.instance
        .collection('Customers')
        .doc(customerId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: fetchCustomerDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Keine Daten gefunden")),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Kundendetails'),
            actions: [
              IconButton(
                icon: const Icon(Icons.format_list_numbered),
                tooltip: 'ترقيم العميل',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerNumberingScreen(
                        customerName: data['customerFirstName'],
                        customerPhone: data['phoneNumber'],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                detailRow('Name', data['customerFirstName']),
                detailRow('E-Mail', data['emailAddress']),
                detailRow('Handynummer', data['phoneNumber']),
                detailRow('Adresse', data['address']),
                detailRow('Stadt', data['city']),
                detailRow('Gerätetyp', data['deviceType']),
                detailRow('Modell', data['deviceModel']),
                detailRow('Seriennummer', data['serialNumber']),
                detailRow('PIN code', data['pinCode']),
                detailRow('Problem', data['issue']),
                detailRow('Preis', "${data['price']} €"),
                detailRow(
                  'Startdatum',
                  (data['startDate'] as Timestamp).toDate().toString().split(' ')[0],
                ),
                detailRow(
                  'Enddatum',
                  (data['endDate'] as Timestamp).toDate().toString().split(' ')[0],
                ),
                detailRow('Status', data['isDone'] ? 'Done' : 'In Progress'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (data.containsKey('printId')) {
                      final printId = data['printId'];
                      await generatePdf(data, context, printId);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("❌ العميل غير مرقّم، من فضلك استخدم شاشة الترقيم أولًا."),
                        ),
                      );
                    }
                  },
                  child: const Text('Herunterladen als PDF'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
