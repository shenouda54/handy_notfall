import 'package:flutter/material.dart';
import 'package:handy_notfall/models/customer_details_screen.dart';
import 'package:handy_notfall/features/presentation/pages/edit_customer_screen.dart';

import '../data/datasources/screen_pdfs/auftrag/view_model/pdf_logic.dart';
import '../features/presentation/pages/data_telpone_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerListTile extends StatelessWidget {
  final Map<String, dynamic> customer;
  final VoidCallback? onEdit;
  final VoidCallback? onAdd;

  const CustomerListTile({super.key, required this.customer, this.onEdit, this.onAdd});

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
          await generatePdf(data, context, data['auftragNr'] ?? '');
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
            "Gerät: ${customer["deviceType"]}"
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
                icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
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
                  if (result == true && onAdd != null) {
                    onAdd!(); // ✅ تحديث الشاشة بعد الإضافة مع مسح الفلاتر
                  }
                }
              ),
              IconButton(
                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary),
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
                icon: Icon(Icons.visibility, color: Theme.of(context).colorScheme.secondary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CustomerDetailsScreen(
                            customerId: customer['id'],
                            auftragNr: customer['auftragNr']?.toString() ?? '',
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
