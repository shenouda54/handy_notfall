import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handy_notfall/core/widgets/custom_input_field.dart';
import 'package:handy_notfall/core/widgets/date_picker_field.dart';
import 'package:handy_notfall/core/widgets/issue_selection.dart';
import 'package:handy_notfall/core/widgets/device_type_selection.dart';
import 'package:handy_notfall/core/widgets/defect_card.dart';
import 'package:intl/intl.dart';

class EditCustomerScreen extends StatefulWidget {
  final String customerId;

  const EditCustomerScreen({super.key, required this.customerId});

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController customIssueController = TextEditingController();
  final TextEditingController customDeviceController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  List<String> selectedDeviceTypes = [];
  
  // Dynamic list for defect cards
  List<DefectCardState> defectCards = [];
  bool hasRechnungCode = false;
  bool isEditingEnabled = true;

  final List<String> deviceTypes = [
    'Dell', 'Apple', 'Samsung', 'HP', 'Lenovo', 'Sony', 'LG', 'Huawei',
    'Toshiba', 'Asus', 'Acer', 'Microsoft', 'Realme', 'HTC', 'Motorola',
    'Blackberry', 'Xiaomi', 'Caterpillar', 'Oppo', 'Google', 'Oneplus'
  ];

  final List<String> issueOptions = [
    'Display ', 'Akku ', 'Kamera ', 'Kameraglas ', 'Hörmuschel ',
    'Ladebuchse  ', 'Lautsprecher ', 'Rückseite ', 'Wasserschaden',
    'Geht nicht an', 'Datenübertragung', 'SoftWare', 'Neue ', 'Gebraucht ',
    'Panzerglas', 'Ladekabel', 'Hülle', 'Ladegerät', 'Nachbesserung',
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Customers')
          .doc(widget.customerId)
          .get();

      if (!doc.exists) {
        throw Exception("Customer not found");
      }

      final data = doc.data();
      if (data == null) {
        throw Exception("Customer data is null");
      }

      setState(() {
        firstNameController.text = data['customerFirstName'] ?? '';
        addressController.text = data['address'] ?? '';
        cityController.text = data['city'] ?? '';
        phoneController.text = data['phoneNumber'] ?? '';
        emailController.text = data['emailAddress'] ?? '';
        modelController.text = data['deviceModel'] ?? '';
        serialNumberController.text = data['serialNumber'] ?? '';
        pinCodeController.text = data['pinCode'] ?? '';
        
        selectedDeviceTypes = (data['deviceType'] as String)
            .split(', ')
            .where((e) => e.isNotEmpty)
            .toList();
        
        // Load defects and populate cards
        defectCards.clear();
        if (data['defects'] != null && data['defects'] is List) {
          var defectsList = (data['defects'] as List);
          for (var item in defectsList) {
            var defectMap = item as Map<String, dynamic>;
            var card = DefectCardState();
            
            // Set issues
            String issueStr = defectMap['issue'] ?? '';
            if (issueStr.isNotEmpty) {
              card.selectedIssues.addAll(
                issueStr.split(', ').where((e) => e.isNotEmpty)
              );
            }
            
            // Set price and quantity
            card.priceController.text = (defectMap['price'] ?? 0).toString();
            card.quantityController.text = (defectMap['quantity'] ?? 1).toString();
            
            defectCards.add(card);
          }
        } else {
          // Fallback for old data structure
          var card = DefectCardState();
          String issueStr = data['issue'] ?? '';
          if (issueStr.isNotEmpty) {
            card.selectedIssues.addAll(
              issueStr.split(', ').where((e) => e.isNotEmpty)
            );
          }
          card.priceController.text = (data['price'] ?? 0).toString();
          card.quantityController.text = (data['quantity'] ?? 1).toString();
          defectCards.add(card);
        }
        
        // Ensure at least one card exists
        if (defectCards.isEmpty) {
          defectCards.add(DefectCardState());
        }

        startDateController.text = DateFormat('yyyy-MM-dd')
            .format((data['startDate'] as Timestamp).toDate());
        endDateController.text = DateFormat('yyyy-MM-dd')
            .format((data['endDate'] as Timestamp).toDate());
        
        final rechnungCode = data['rechnungCode']?.toString();
        hasRechnungCode = rechnungCode != null && rechnungCode.isNotEmpty;
        isEditingEnabled = !hasRechnungCode; // Default to locked if invoice exists
      });
    } catch (e) {
      debugPrint("Error loading customer data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading customer data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateCustomer() async {
    debugPrint("Starting update process...");

    if (!_formKey.currentState!.validate()) {
      debugPrint("Form is not valid.");
      return;
    }

    try {
      // Collect defects from all cards
      List<Map<String, dynamic>> defectsData = defectCards.map((card) {
        return {
          'issue': card.selectedIssues.join(', '),
          'price': int.tryParse(card.priceController.text.trim()) ?? 0,
          'quantity': int.tryParse(card.quantityController.text.trim()) ?? 1,
        };
      }).toList();

      // For backward compatibility, use the first defect's data
      var firstDefect = defectsData.isNotEmpty 
          ? defectsData.first 
          : {'issue': '', 'price': 0, 'quantity': 1};

      await FirebaseFirestore.instance
          .collection('Customers')
          .doc(widget.customerId)
          .update({
        'customerFirstName': firstNameController.text.trim(),
        'address': addressController.text.trim(),
        'city': cityController.text.trim(),
        'phoneNumber': phoneController.text.trim(),
        'emailAddress': emailController.text.trim(),
        'deviceType': selectedDeviceTypes.join(', '),
        'deviceModel': modelController.text.trim(),
        'serialNumber': serialNumberController.text.trim(),
        'pinCode': pinCodeController.text.trim(),
        'defects': defectsData,
        // Keep backward compatibility
        'issue': firstDefect['issue'],
        'price': firstDefect['price'],
        'quantity': firstDefect['quantity'],
        'startDate': Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(startDateController.text)),
        'endDate': Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(endDateController.text)),
      });

      debugPrint("Update successful, showing snackbar...");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Die Daten wurden erfolgreich geändert.'),
          duration: Duration(seconds: 1),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        debugPrint("Popping context...");
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Error during update: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Speichern: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kundendaten ändern"),
        actions: [
          if (hasRechnungCode)
            IconButton(
              icon: Icon(isEditingEnabled ? Icons.lock_open : Icons.lock),
              color: isEditingEnabled ? Colors.green : Colors.red,
              tooltip: isEditingEnabled ? "Bearbeitung aktiv" : "Bearbeitung gesperrt",
              onPressed: () {
                if (!isEditingEnabled) {
                  // Show confirmation dialog to unlock
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Bearbeitung freigeben?"),
                      content: const Text(
                        "Für diesen Kunden wurde bereits eine Rechnung erstellt.\n\n"
                        "Möchten Sie die Daten trotzdem ändern? (z.B. Tippfehler korrigieren)",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Abbrechen"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            setState(() {
                              isEditingEnabled = true;
                            });
                          },
                          child: const Text("Ja, freigeben"),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Lock again manually if desired
                  setState(() {
                    isEditingEnabled = false;
                  });
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (hasRechnungCode)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEditingEnabled ? Colors.orange.shade50 : Colors.red.shade50,
                    border: Border.all(color: isEditingEnabled ? Colors.orange : Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isEditingEnabled ? Icons.warning_amber_rounded : Icons.lock, 
                        color: isEditingEnabled ? Colors.orange : Colors.red
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditingEnabled
                              ? "Achtung: Rechnung existiert bereits. Änderungen nur für Korrekturen!"
                              : "Bearbeitung gesperrt: Rechnung wurde bereits erstellt.",
                          style: TextStyle(
                            color: isEditingEnabled ? Colors.orange[900] : Colors.red, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              CustomInputField(controller: firstNameController, label: "Vor- und Nachname", enabled: isEditingEnabled),
              const SizedBox(height: 12),
              CustomInputField(controller: phoneController, label: "Telefonnummer", enabled: isEditingEnabled),
              const SizedBox(height: 12),
              CustomInputField(controller: addressController, label: "PLZ & Wohnort", enabled: isEditingEnabled),
              const SizedBox(height: 12),
              CustomInputField(controller: cityController, label: "Straße & Hausnummer ", enabled: isEditingEnabled),
              const SizedBox(height: 12),
              CustomInputField(controller: emailController, label: "E-Mail des Empfängers ", enabled: isEditingEnabled),
              const SizedBox(height: 12),
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
                enabled: isEditingEnabled,
              ),
              const SizedBox(height: 12),
              CustomInputField(controller: modelController, label: "Modellnummer ", enabled: isEditingEnabled),
              const SizedBox(height: 12),
              CustomInputField(controller: serialNumberController, label: " Seriennummer", enabled: isEditingEnabled),
              const SizedBox(height: 12),
              CustomInputField(controller: pinCodeController, label: "Speer/Pin Code", enabled: isEditingEnabled),
              const SizedBox(height: 12),
              // Defect Cards Section
              ...defectCards.asMap().entries.map((entry) {
                int index = entry.key;
                DefectCardState card = entry.value;
                return Column(
                  children: [
                    DefectCard(
                      index: index,
                      cardState: card,
                      issueOptions: issueOptions,
                      customIssueController: customIssueController,
                      isLocked: !isEditingEnabled,
                      showDelete: defectCards.length > 1,
                      onDelete: () {
                          setState(() {
                            defectCards.removeAt(index);
                          });
                      },
                      onAddIssue: (issue) {
                          setState(() {
                            if (!card.selectedIssues.contains(issue)) {
                              card.selectedIssues.add(issue);
                            }
                          });
                      },
                      onRemoveIssue: (issue) {
                          setState(() {
                            card.selectedIssues.remove(issue);
                          });
                      },
                    ),
                    const SizedBox(height: 8.0),
                  ],
                );
              }).toList(),
              // Add button
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 32),
                  onPressed: () {
                    if (!isEditingEnabled) return;
                    setState(() {
                      defectCards.add(DefectCardState());
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              DatePickerField(controller: endDateController, label: 'Abholung ', enabled: isEditingEnabled),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: !isEditingEnabled ? null : _updateCustomer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isEditingEnabled ? Colors.grey : null,
                ),
                child: const Text(" Änderungen speichern"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

