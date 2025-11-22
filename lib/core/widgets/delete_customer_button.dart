import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteCustomerButton extends StatelessWidget {
  final String customerName;
  final String customerPhone;
  final VoidCallback? onDeleted;

  const DeleteCustomerButton({
    super.key,
    required this.customerName,
    required this.customerPhone,
    this.onDeleted,
  });

  Future<void> _deleteCustomer(BuildContext context) async {

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد أنك تريد حذف كل بيانات هذا العميل؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("حذف"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('Customers')
        .where('customerFirstName', isEqualTo: customerName)
        .where('phoneNumber', isEqualTo: customerPhone)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    if (onDeleted != null) onDeleted!();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.delete_forever, color: Colors.red),
      tooltip: 'حذف كل بيانات العميل',
      onPressed: () => _deleteCustomer(context),
    );
  }
}
