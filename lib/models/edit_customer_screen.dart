import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCustomerScreen extends StatefulWidget {
  final String customerId;

  const EditCustomerScreen({Key? key, required this.customerId}) : super(key: key);

  @override
  _EditCustomerScreenState createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController deviceTypesController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController repairPriceController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController customIssueController = TextEditingController();
  // أضف المزيد من المتحكمات حسب الحاجة

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Customers')
        .doc(widget.customerId)
        .get();

    if (doc.exists) {
      setState(() {
        firstNameController.text = doc['customerFirstName'];
        phoneController.text = doc['phoneNumber'];
        // قم بملء باقي الحقول بنفس الطريقة
      });
    }
  }

  Future<void> _updateCustomerData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('Customers')
          .doc(widget.customerId)
          .update({
        'customerFirstName': firstNameController.text,
        'phoneNumber': phoneController.text,
        // أضف باقي الحقول هنا
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث البيانات بنجاح!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات العميل'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'الاسم'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال الاسم';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال رقم الهاتف';
                  }
                  return null;
                },
              ),
              // أضف المزيد من حقول الإدخال حسب الحاجة
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateCustomerData,
                child: const Text('حفظ التعديلات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
