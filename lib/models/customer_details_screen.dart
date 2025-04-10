import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/data/print&pdf/generate_pdf.dart';

class CustomerDetailsScreen extends StatelessWidget {
  final String customerId;
  const CustomerDetailsScreen({super.key, required this.customerId});

  Future<DocumentSnapshot> fetchCustomerDetails() async {
    return await FirebaseFirestore.instance
        .collection('Customers') //
        .doc(customerId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kundendetails')), //Customer Details
      body: FutureBuilder<DocumentSnapshot>(
        future: fetchCustomerDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Keine Daten gefunden"));  //No Data Found
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                detailRow('Name', data['customerFirstName']),
                detailRow('Handynummer', data['phoneNumber']),
                detailRow('Adresse', data['address']),
                detailRow('Stadt', data['city']),
                detailRow('Gerätetyp', data['deviceType']),
                detailRow('Modell', data['deviceModel']),
                detailRow('Seriennummer', data['serialNumber']),
                detailRow('PIN code', data['pinCode']),
                detailRow('Problem', data['issue']),
                detailRow('Preis', "${data['price']} €"),
                detailRow('Startdatum', (data['startDate'] as Timestamp).toDate().toString().split(' ')[0]),
                detailRow('Enddatum ', (data['endDate'] as Timestamp).toDate().toString().split(' ')[0]),
                detailRow('Status', data['isDone'] ? 'Done' : 'In Progress'),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    await generatePdf(data, context);
                  },
                  child: const Text('Herunterladen als PDF'),
                ),

              ],
            ),
          );
        },
      ),
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
