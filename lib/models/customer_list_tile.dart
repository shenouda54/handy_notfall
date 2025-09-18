import 'package:flutter/material.dart';
import 'package:handy_notfall/models/customer_details_screen.dart';
import 'package:handy_notfall/features/presentation/pages/edit_customer_screen.dart';

import '../features/presentation/pages/data_telpone_screen.dart';
import 'package:handy_notfall/data/screen_pdfs/auftrag/view_model/pdf_logic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerListTile extends StatelessWidget {
  final Map<String, dynamic> customer;
  final VoidCallback? onEdit;

  const CustomerListTile({super.key, required this.customer,this.onEdit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () async {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('Customers')
              .doc(customer['id'])
              .get();
          if (!doc.exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('❌ لم يتم العثور على بيانات العميل')),
            );
            return;
          }
          final data = doc.data()!;
          data['printId'] = customer['printId'] ?? data['printId'] ?? 0;
          await generatePdf(data, context, data['printId']);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ خطأ أثناء تحميل الفاتورة: $e')),
          );
        }
      },
      child: Card(
        child: ListTile(
          title: Text(customer["firstName"]),
          subtitle: Text(
            "Gerät: 9${customer["deviceType"]}"
            " , ${customer["deviceModel"]}\n"
            "Problem: ${customer["issue"]}\n"
            "Handynummer: ${customer["phone"]}\n"
            "PIN code: ${customer["pinCode"]}\n"
            "Preis: ${customer["price"]}€",
          ),
          trailing: Wrap(
            spacing: 8,
            children: [
              IconButton(
                icon: const Icon(Icons.add, color: Colors.orange),
                tooltip: 'Add New Device',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DataTelponeScreen(
                        firstName: customer["firstName"],
                        address: customer["address"],
                        city: customer["city"],
                        phoneNumber: customer["phone"],
                        emailAddress: customer["email"],
                      ),
                    ),
                  );
                  if (result == true && onEdit != null) {
                    onEdit!(); // ✅ تحديث الشاشة بعد الإضافة
                  }
                }
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () async{
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditCustomerScreen(
                        customerId: customer['id'],
                      ),
                    ),
                  );
                  if (result == true && onEdit != null) {
                    onEdit!(); // ✅ تحديث الشاشة بعد التعديل
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.visibility, color: Colors.green),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CustomerDetailsScreen(
                            customerId: customer['id'],
                            printId: customer['printId'] ?? 0,
                          ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
