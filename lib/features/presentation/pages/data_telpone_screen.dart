import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/data/custom_input_field.dart';
import 'package:handy_notfall/data/date_picker_field.dart';
import 'package:handy_notfall/data/device_type_selection.dart';
import 'package:handy_notfall/data/issue_selection.dart';
import 'package:handy_notfall/features/domain/usecases/save_customer_data_usecase.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/customer_data_telpone_entity.dart';

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
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController repairPriceController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController customIssueController = TextEditingController();
  final TextEditingController customDeviceController = TextEditingController();

  List<String> selectedDeviceTypes = [];
  final List<String> deviceTypes = [
    'Dell', 'Apple', 'Samsung', 'HP', 'Lenovo', 'Sony', 'LG', 'Huawei',
    'Toshiba', 'Asus', 'Acer', 'Microsoft', 'Realme', 'HTC', 'Motorola',
    'Blackberry', 'Xiaomi', 'Caterpillar', 'Oppo', 'Google', 'Oneplus',
  ];

  final List<String> issueOptions = [
    'Display ', 'Akku ', 'Kamera ', 'Kameraglas ', 'Hörmuschel ',
    'Ladebuchse  ', 'Lautsprecher ', 'Rückseite ', 'Wasserschaden',
    'Geht nicht an', 'Datenübertragung', 'SoftWare', 'Neue ', 'Gebraucht ',
    'Panzerglas', 'Ladekabel', 'Hülle', 'Ladegerät', 'Nachbesserung',
  ];

  final List<String> selectedIssues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

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
        title: const Text('Daten'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeviceTypeSelection(
                deviceTypes: deviceTypes,
                selectedDeviceTypes: selectedDeviceTypes,
                onAdd: (value) {
                  setState(() {
                    if (!selectedDeviceTypes.contains(value)) {
                      selectedDeviceTypes.add(value);
                    }
                  });
                },
                onRemove: (value) {
                  setState(() {
                    selectedDeviceTypes.remove(value);
                  });
                },
                customDeviceController: customDeviceController,
              ),
              const SizedBox(height: 16.0),
              CustomInputField(controller: modelController, label: 'Modellnummer *'),
              const SizedBox(height: 16.0),
              CustomInputField(controller: serialNumberController, label: 'Seriennummer *'),
              const SizedBox(height: 16.0),
              CustomInputField(controller: pinCodeController, label: 'Speer/Pin Code *'),
              const SizedBox(height: 16.0),
              IssueSelection(
                issueOptions: issueOptions,
                selectedIssues: selectedIssues,
                customIssueController: customIssueController,
                onAddIssue: (issue) {
                  setState(() {
                    selectedIssues.add(issue);
                  });
                },
                onRemoveIssue: (issue) {
                  setState(() {
                    selectedIssues.remove(issue);
                  });
                },
              ),
              const SizedBox(height: 16.0),
              CustomInputField(
                controller: repairPriceController,
                label: 'Reparatur Preis *',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              DatePickerField(controller: startDateController, label: 'Anfang *'),
              const SizedBox(height: 16.0),
              DatePickerField(controller: endDateController, label: 'Abholung *'),
              const SizedBox(height: 20.0),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () async {
                    String? userEmail = FirebaseAuth.instance.currentUser?.email;
                    if (userEmail == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sie müssen sich zuerst anmelden!')),
                      );
                      return;
                    }
                    try {
                      final entity = CustomerDataEntity(
                        customerFirstName: widget.firstName.trim(),
                        address: widget.address.trim(),
                        city: widget.city.trim(),
                        phoneNumber: widget.phoneNumber.trim(),
                        emailAddress: widget.emailAddress.trim(),
                        deviceType: selectedDeviceTypes.join(', '),
                        deviceModel: modelController.text.trim(),
                        serialNumber: serialNumberController.text.trim(),
                        pinCode: pinCodeController.text.trim(),
                        issue: selectedIssues.isNotEmpty
                            ? selectedIssues.join(', ')
                            : 'No Issues',
                        price: int.tryParse(repairPriceController.text.trim()) ?? 0,
                        startDate: startDateController.text.isNotEmpty
                            ? Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(startDateController.text.trim()))
                            : Timestamp.now(),
                        endDate: endDateController.text.isNotEmpty
                            ? Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(endDateController.text.trim()))
                            : Timestamp.now(),
                        isDone: false,
                        userEmail: userEmail,
                      );

                      await SaveCustomerDataUseCase().execute(entity);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Datei gespeichert!')),
                      );

                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Daten konnten nicht gespeichert werden: $e')),
                      );
                    }
                  },
                  child: const Text(
                    'Speicher Daten',
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
