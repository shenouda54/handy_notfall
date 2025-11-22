import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handy_notfall/core/widgets/error_widget.dart';

import 'package:handy_notfall/data/datasources/screen_pdfs/rechnung/view_model/pdf_logic.dart';

class RechnungScreen extends StatelessWidget {
  final String customerId;
  final String auftragNr;

  const RechnungScreen({
    super.key,
    required this.customerId,
    required this.auftragNr,
  });

  Future<Map<String, dynamic>> fetchCustomerData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Customers')
          .doc(customerId)
          .get();

      if (!doc.exists) {
        throw Exception("Customer not found");
      }

      return doc.data()!;
    } catch (e) {
      throw Exception('Failed to load customer data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rechnung")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchCustomerData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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

          if (!snapshot.hasData) {
            return CustomErrorWidget(
              errorMessage: "Customer data not found",
              onGoBack: () => Navigator.pop(context),
            );
          }

          final data = snapshot.data!;

          return Center(
            child: ElevatedButton(
              onPressed: () async {
                await generatePdf(data, context, auftragNr);
              },
              child: const Text("📄 Download Rechnung"),
            ),
          );
        },
      ),
    );
  }
}
