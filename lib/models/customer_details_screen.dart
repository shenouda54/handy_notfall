import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/data/print&pdf/generate_pdf.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: fetchCustomerDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No Data Found"));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                detailRow('Name', data['customerFirstName']),
                detailRow('Phone', data['phoneNumber']),
                detailRow('Address', data['address']),
                detailRow('City', data['city']),
                detailRow('Device Type', data['deviceType']),
                detailRow('Device Model', data['deviceModel']),
                detailRow('Serial Number', data['serialNumber']),
                detailRow('Pin Code', data['pinCode']),
                detailRow('Issue', data['issue']),
                detailRow('Price', "${data['price']} €"),
                detailRow('Start Date', (data['startDate'] as Timestamp).toDate().toString().split(' ')[0]),
                detailRow('End Date', (data['endDate'] as Timestamp).toDate().toString().split(' ')[0]),
                detailRow('Status', data['isDone'] ? 'Done' : 'In Progress'),
                const SizedBox(height: 20),

                // 🔥 زرار تحميل الـ PDF
                ElevatedButton(
                  onPressed: () async {
                    await generatePdf(data);
                  },
                  child: const Text('Download PDF'),
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
