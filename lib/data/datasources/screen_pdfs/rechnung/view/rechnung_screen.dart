import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handy_notfall/core/widgets/error_widget.dart';

import 'package:handy_notfall/data/datasources/screen_pdfs/rechnung/view_model/pdf_logic.dart';
import 'package:handy_notfall/data/datasources/print_pdf/rechnung_number/view_model/rechnung_numbering_logic.dart';

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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1) زر العين (طباعة مباشرة)
                IconButton(
                  onPressed: () async {
                    // Use rechnungCode if present, otherwise fallback to auftragNr
                    final code = data['rechnungCode']?.toString() ?? auftragNr;
                    await generatePdf(data, context, code);
                  },
                  icon: const Icon(Icons.remove_red_eye, size: 40, color: Colors.blue),
                  tooltip: "معاينة / طباعة مباشرة",
                ),
                const SizedBox(width: 40),

                // 2) زر الطباعة (توليد كود وطباعة)
                IconButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("تأكيد"),
                        content: const Text(
                            "هل تريد توليد وطباعـة كود Rechnung لهذا الطلب؟"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text("لا"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text("نعم"),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    final result =
                        await RechnungNumberingService.assignRechnungCode(
                      customerId: customerId,
                    );

                    final message =
                        result["message"]?.toString() ?? "تم تنفيذ الطلب.";
                    final code = result["rechnungCode"]?.toString();

                    if (result["success"] == true &&
                        code != null &&
                        code.isNotEmpty) {
                      await generatePdf(data, context, code);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          code != null && code.isNotEmpty
                              ? "$message\nالكود: $code"
                              : message,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.print, size: 40, color: Colors.green),
                  tooltip: "توليد كود وطباعة",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
