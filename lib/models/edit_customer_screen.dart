import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handy_notfall/data/custom_dropdown.dart';
import 'package:handy_notfall/data/custom_input_field.dart';
import 'package:handy_notfall/data/date_picker_field.dart';
import 'package:handy_notfall/data/issue_selection.dart';
import 'package:intl/intl.dart';

class EditCustomerScreen extends StatefulWidget {
  final String customerId;

  const EditCustomerScreen({Key? key, required this.customerId}) : super(key: key);

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController repairPriceController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController customIssueController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String? selectedDeviceType;
  List<String> selectedIssues = [];

  final List<String> deviceTypes = [
    'Dell', 'Apple', 'Samsung', 'HP', 'Lenovo', 'Sony', 'LG', 'Huawei',
    'Toshiba', 'Asus', 'Acer', 'Microsoft', 'Realme', 'HTC', 'Motorola',
    'Blackberry', 'Xiaomi', 'Caterpillar', 'Oppo', 'Google', 'Oneplus'
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
    'Datenübertragung',
    'SoftWare',
    'Neue ',
    'Gebraucht ',
    'Panzerglas',
    'Ladekabel',
    'Hülle',
    'Ladegerät',
    'Nachbesserung',
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    final doc = await FirebaseFirestore.instance
        .collection('Customers')
        .doc(widget.customerId)
        .get();

    final data = doc.data();
    if (data == null) return;

    setState(() {
      firstNameController.text = data['customerFirstName'] ?? '';
      addressController.text = data['address'] ?? '';
      cityController.text = data['city'] ?? '';
      phoneController.text = data['phoneNumber'] ?? '';
      emailController.text = data['emailAddress'] ?? '';
      modelController.text = data['deviceModel'] ?? '';
      serialNumberController.text = data['serialNumber'] ?? '';
      pinCodeController.text = data['pinCode'] ?? '';
      repairPriceController.text = data['price'].toString();
      selectedDeviceType = data['deviceType'] ?? '';
      selectedIssues = (data['issue'] as String).split(', ').where((e) => e.isNotEmpty).toList();
      startDateController.text = DateFormat('yyyy-MM-dd').format((data['startDate'] as Timestamp).toDate());
      endDateController.text = DateFormat('yyyy-MM-dd').format((data['endDate'] as Timestamp).toDate());
    });
  }

  Future<void> _updateCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection('Customers')
        .doc(widget.customerId)
        .update({
      'customerFirstName': firstNameController.text.trim(),
      'address': addressController.text.trim(),
      'city': cityController.text.trim(),
      'phoneNumber': phoneController.text.trim(),
      'emailAddress': emailController.text.trim(),
      'deviceType': selectedDeviceType ?? '',
      'deviceModel': modelController.text.trim(),
      'serialNumber': serialNumberController.text.trim(),
      'pinCode': pinCodeController.text.trim(),
      'issue': selectedIssues.join(', '),
      'price': int.tryParse(repairPriceController.text.trim()) ?? 0,
      'startDate': Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(startDateController.text)),
      'endDate': Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(endDateController.text)),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Die Daten wurden erfolgreich geändert.')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kundendaten ändern")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomInputField(controller: firstNameController, label: "Vor- und Nachname"),
              const SizedBox(height: 12),
              CustomInputField(controller: phoneController, label: "Telefonnummer"),
              const SizedBox(height: 12),
              CustomInputField(controller: addressController, label: "PLZ & Wohnort"),
              const SizedBox(height: 12),
              CustomInputField(controller: cityController, label: "Straße & Hausnummer "),
              const SizedBox(height: 12),
              CustomInputField(controller: emailController, label: "E-Mail des Empfängers "),
              const SizedBox(height: 12),

              CustomDropdown(

                label: 'Geräte-Typ  ',
                value: selectedDeviceType,
                items: deviceTypes,
                onChanged: (value) {
                  setState(() => selectedDeviceType = value);
                },
              ),
              const SizedBox(height: 12),
              CustomInputField(controller: modelController, label: "Modellnummer "),
              const SizedBox(height: 12),
              CustomInputField(controller: serialNumberController, label: " Seriennummer"),
              const SizedBox(height: 12),
              CustomInputField(controller: pinCodeController, label: "Speer/Pin Code"),
              const SizedBox(height: 12),

              IssueSelection(
                issueOptions: issueOptions,
                selectedIssues: selectedIssues,
                customIssueController: customIssueController,
                onAddIssue: (issue) {
                  setState(() {
                    if (!selectedIssues.contains(issue)) selectedIssues.add(issue);
                  });
                },
                onRemoveIssue: (issue) {
                  setState(() {
                    selectedIssues.remove(issue);
                  });
                },
              ),
              const SizedBox(height: 12),
              CustomInputField(
                controller: repairPriceController,
                label: ' Reparatur Preis ',

                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DatePickerField(controller: startDateController, label: ' Anfang'),
              const SizedBox(height: 12),
              DatePickerField(controller: endDateController, label: 'Abholung '),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateCustomer,
                child: const Text(" Änderungen speichern"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

