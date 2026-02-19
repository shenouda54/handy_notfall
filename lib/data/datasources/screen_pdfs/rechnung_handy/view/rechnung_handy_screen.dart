import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:handy_notfall/core/widgets/print_dialog_helper.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/data/datasources/screen_pdfs/rechnung_handy/view_model/pdf_logic.dart';
import 'package:handy_notfall/data/datasources/print_pdf/rechnung_number/view_model/rechnung_numbering_logic.dart';

class RechnungHandyScreen extends StatelessWidget {
  final String customerId;
  final String auftragNr;

  const RechnungHandyScreen({
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
      appBar: AppBar(title: const Text("RechnungHandy")),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1) زر العين (طباعة مباشرة دون توليد كود جديد إذا لم يطلب)
                IconButton(
                  onPressed: () async {
                    // نستخدم الكود الموجود إن وجد، أو نمرر نص فارغ ليظهر بدون كود
                    final code = data['rechnungCode']?.toString() ?? '';
                     await generatePdf(data, context, code);
                  },
                  icon: const Icon(Icons.remove_red_eye, size: 40, color: Colors.blue),
                  tooltip: "معاينة / طباعة مباشرة",
                ),
                const SizedBox(width: 40),

                // 2) زر الطباعة (توليد كود وطباعة أو إرسال إيميل)
                IconButton(
                  onPressed: () async {
                    // Show dialog to choose action
                    final action = await PrintDialogHelper.showPrintOptionsDialog(context);

                    if (action == null) return;

                    // Determine target string for confirmation message
                    String actionText = "طباعة";
                    if (action == 'email_me') actionText = "وإرسال (لي)";
                    if (action == 'email_customer') actionText = "وإرسال (للعميل)";

                    final confirm = await PrintDialogHelper.showConfirmationDialog(context, actionText, "Rechnung");

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
                      
                      // 2. Determine Recipient and Generate PDF
                      String? targetEmail;
                      bool sendEmail = false;

                      if (action == 'email_me') {
                        targetEmail = FirebaseAuth.instance.currentUser?.email;
                        sendEmail = true;
                      } else if (action == 'email_customer') {
                        targetEmail = data['emailAddress']; // Ensure this matches Firestore key
                        sendEmail = true;
                      }
                      
                      // If a NEW code was generated (and thus endDate updated), fetch fresh data
                      Map<String, dynamic> dataToUse = data;
                      if (result["isNew"] == true) {
                        try {
                          dataToUse = await fetchCustomerData();
                        } catch (e) {
                          print("Error fetching updated data: $e");
                        }
                      }

                      await generatePdf(
                        dataToUse, 
                        context, 
                        code,
                        sendEmail: sendEmail,
                        userEmail: targetEmail,
                      );
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
                  tooltip: "خيارات الفاتورة",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
