import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handy_notfall/data/screen_pdfs/kostenmittlung/view_model/pdf_logic.dart';

class KostenmittlungScreen extends StatelessWidget {
  final String customerId;
  final String auftragNr;

  const KostenmittlungScreen({
    super.key,
    required this.customerId,
    required this.auftragNr,
  });

  Future<Map<String, dynamic>> fetchCustomerData() async {
    final doc = await FirebaseFirestore.instance
        .collection('Customers')
        .doc(customerId)
        .get();

    if (!doc.exists) {
      throw Exception("Kunde nicht gefunden.");
    }

    return doc.data()!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kostenmittlung")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchCustomerData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("❌ Kunde nicht gefunden"));
          }

          final data = snapshot.data!;

          return Center(
            child: ElevatedButton(
              onPressed: () async {
                await generatePdf(data, context, auftragNr);
              },
              child: const Text("📄 Download Kostenmittlung PDF"),
            ),
          );
        },
      ),
    );
  }
}
