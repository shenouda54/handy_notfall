import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/data/print_pdf/customer_number/view/customer_numbering_screen.dart';
import 'package:handy_notfall/data/error_widget.dart';
import 'package:intl/intl.dart';

import '../data/screen_pdfs/auftrag/view/auftrag_screen.dart';
import '../data/screen_pdfs/kostenmittlung/view/kostenmittlung_screen.dart';
import '../data/screen_pdfs/rechnung/view/rechnung_screen.dart';
import '../data/screen_pdfs/rechnung_handy/view/rechnung_handy_screen.dart';
import '../data/screen_pdfs/rechnungs_verkaufe/view/rechnungs_verkaufe_screen.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final String customerId;
  final int printId; // 👈 أضف هذا السطر

  const CustomerDetailsScreen({super.key, required this.customerId, required this.printId});

  Future<DocumentSnapshot> fetchCustomerDetails() async {
    try {
      return await FirebaseFirestore.instance
          .collection('Customers')
          .doc(customerId)
          .get();
    } catch (e) {
      throw Exception('Failed to load customer data: $e');
    }
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

        if (snapshot.hasError) {
          return CustomErrorWidget(
            errorMessage: snapshot.error.toString(),
            onRetry: () {
              // Force rebuild to retry
              (context as Element).markNeedsBuild();
            },
            onGoBack: () => Navigator.pop(context),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return CustomErrorWidget(
            errorMessage: "Customer data not found",
            onGoBack: () => Navigator.pop(context),
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
                detailDoubleRow('Kundennummer', '', 'Auftrag Nr ', data['printId']?.toString() ?? 'غير مرقم'),
                detailRow('Name', data['customerFirstName']),
                detailRow('Stadt', data['city']),
                detailRow('Adresse', data['address']),
                detailRow('Handynummer', data['phoneNumber']),
                detailRow('E-Mail', data['emailAddress']),
                detailRow('Model', '${data['deviceType']} ${data['deviceModel']}'),
                detailRow('Seriennummer', data['serialNumber']),
                detailRow('PIN code', data['pinCode']),
                detailRow('Problem', data['issue']),
                detailRow('Preis', "${data['price']} €"),
                detailRow(
                  'Startdatum',
                  DateFormat('dd.MM.yyyy')
                      .format((data['startDate'] as Timestamp).toDate()),
                ),
                detailRow(
                  'Enddatum',
                  DateFormat('dd-MM-yyyy').format
                    ((data['endDate'] as Timestamp)
                      .toDate())
                ),
                // detailRow('Status', data['isDone'] ? 'Done' : 'In Progress'),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    child: ElevatedButton(
                      onPressed: () {
                        if (data.containsKey('printId')) {
                          final printId = data['printId'];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AuftragScreen(customerId: customerId, printId: printId),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("❌ العميل غير مرقّم، من فضلك استخدم شاشة الترقيم أولًا."),
                            ),
                          );
                        }
                      },
                      child: const Text('Auftrag'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    {
                      'label': 'Rechnung',
                      'screen': (String id, int pid) =>
                          RechnungScreen(customerId: id, printId: pid),
                    },
                    {
                      'label': 'Verkaufe',
                      'screen': (String id, int pid) =>
                          RechnungVerkaufeScreen(customerId: id, printId: pid),
                    },
                    {
                      'label': 'Gebraucht Handy',
                      'screen': (String id, int pid) =>
                          RechnungHandyScreen(customerId: id, printId: pid),
                    },
                    {
                      'label': 'Kostenmittlung',
                      'screen': (String id, int pid) =>
                          KostenmittlungScreen(customerId: id, printId: pid),
                    },
                  ].map((item) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 24,
                      child: ElevatedButton(
                        onPressed: () {
                          if (data.containsKey('printId')) {
                            final printId = data['printId'];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => (item['screen'] as Widget Function(String, int))(customerId, printId),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("❌ العميل غير مرقّم، من فضلك استخدم شاشة الترقيم أولًا."),
                              ),
                            );
                          }
                        },
                        child: Text(item['label'] as String),
                      ),
                    );
                  }).toList(),
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
  Widget detailDoubleRow(String title1, String value1, String title2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text("$title1: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(value1)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Text("$title2: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                Expanded(child: Text(value2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
