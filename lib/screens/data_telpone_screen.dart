import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/firebase_function.dart';
import 'package:handy_notfall/models/customer_model.dart';
import 'package:intl/intl.dart';

class DataTelponeScreen extends StatefulWidget {
  final String firstName;
  final String address;
  final String city;
  final String phoneNumber;
  final String emailAddress;

  const DataTelponeScreen({
    Key? key,
    required this.firstName,
    required this.address,
    required this.city,
    required this.phoneNumber,
    required this.emailAddress,
  }) : super(key: key);

  @override
  State<DataTelponeScreen> createState() => _DataTelponeScreenState();
}

class _DataTelponeScreenState extends State<DataTelponeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController deviceTypesController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController repairPriceController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController customIssueController = TextEditingController();

  String? selectedDeviceType;
  final List<String> deviceTypes = [
    'Dell',
    'Apple',
    'Samsung',
    'HP',
    'Lenovo',
    'Sony',
    'LG',
    'Huawei',
    'Toshiba',
    'Asus',
    'Acer',
    'Microsoft',
  ];

  final List<String> issueOptions = [
    'Display ',
    'Akku ',
    'Kamera ',
    'Kameraglas ',
    'Hörmuschel ',
    'Ladebuchse  ',
    'Lautsprecher ',
    'Rückseite ',
    'Wasserschaden',
    'Geht nicht an',

  ];

  String? selectedIssue;
  final List<String> selectedIssues = [];

  @override
  void dispose() {
    modelController.dispose();
    deviceTypesController.dispose();
    repairPriceController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    customIssueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Daten '),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // اختيار نوع الجهاز
              _buildDropdownField(
                label: 'Geräte-Typ *',
                value: selectedDeviceType,
                items: deviceTypes,
                onChanged: (value) {
                  setState(() {
                    selectedDeviceType = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),


              // موديل الجهاز
              _buildInputField(
                controller: modelController,
                label: 'Modellnummer *',
              ),
              const SizedBox(height: 16.0),
              _buildInputField(
                controller: serialNumberController,
                label: 'Geräte-Nummer *',

              ),              const SizedBox(height: 16.0),

              // المشاكل داخل Card
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Problem:',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // اختيار عطل من القائمة
                      DropdownButtonFormField<String>(
                        value: selectedIssue,
                        decoration: const InputDecoration(
                          labelText: 'Probleme/Defekt',
                          border: OutlineInputBorder(),
                        ),
                        items: issueOptions
                            .map((issue) => DropdownMenuItem(
                                  value: issue,
                                  child: Text(issue),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedIssue = value;
                            if (value != null &&
                                !selectedIssues.contains(value)) {
                              selectedIssues.add(value);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // عرض الأعطال المختارة
                      if (selectedIssues.isNotEmpty)
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: selectedIssues.map((issue) {
                            return Chip(
                              label: Text(issue),
                              deleteIcon: const Icon(Icons.close),
                              onDeleted: () {
                                setState(() {
                                  selectedIssues.remove(issue);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 16.0),

                      // إضافة عطل يدويًا
                      TextFormField(
                        controller: customIssueController,
                        decoration: InputDecoration(
                          labelText: 'Anmerkungen',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              if (customIssueController.text.isNotEmpty &&
                                  !selectedIssues
                                      .contains(customIssueController.text)) {
                                setState(() {
                                  selectedIssues
                                      .add(customIssueController.text);
                                  customIssueController.clear();
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // سعر التصليح
              _buildInputField(
                controller: repairPriceController,
                label: 'Reparatur Preis *',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),

              // تاريخ البداية
              _buildDateField(
                controller: startDateController,
                label: 'Anfang *',
                context: context,
              ),
              const SizedBox(height: 16.0),

              // تاريخ النهاية
              _buildDateField(
                controller: endDateController,
                label: 'Abholung *',
                context: context,
              ),
              const SizedBox(height: 20.0),

              // زر الحفظ
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () async {
                    String? userEmail = FirebaseAuth.instance.currentUser?.email;
                    if (userEmail == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(' يجب تسجيل الدخول أولاً!')),
                      );
                      return;
                    }
                    try {
                      CustomerModel model = CustomerModel(
                        customerFirstName: widget.firstName.trim(),
                        address: widget.address.trim(),
                        city: widget.city.trim(),
                        phoneNumber: widget.phoneNumber.trim(),
                        emailAddress: widget.emailAddress.trim(),
                        deviceType: selectedDeviceType ?? '',
                        deviceModel: modelController.text.trim(),
                        serialNumber: serialNumberController.text.trim(),
                        issue: selectedIssues.isNotEmpty
                            ? selectedIssues.join(', ')
                            : 'No Issues',
                        // إذا لم يحدد مشاكل
                        price:
                            int.tryParse(repairPriceController.text.trim()) ??
                                0,
                        startDate: startDateController.text.isNotEmpty
                            ? Timestamp.fromDate(DateFormat('yyyy-MM-dd')
                                .parse(startDateController.text.trim()))
                            : Timestamp.now(),
                        endDate: endDateController.text.isNotEmpty
                            ? Timestamp.fromDate(DateFormat('yyyy-MM-dd')
                                .parse(endDateController.text.trim()))
                            : Timestamp.now(),
                        isDone: false,
                        userEmail: userEmail, // ✅ احفظ البريد الإلكتروني مع البيانات
                      );

                      await FirebaseFireStore.addCustomer(model);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Data Saved Successfully!')),
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to save data: $e')),
                      );
                    }
                  },
                  child: const Text(
                    'Speicher Daten',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TODO NEW CLASS
  // حقل إدخال عام
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  // حقل إدخال تاريخ
  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required BuildContext context,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          controller.text = pickedDate.toString().split(' ')[0];
        }
      },
    );
  }

  // حقل اختيار منسدلة
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
