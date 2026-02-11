import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/core/widgets/custom_input_field.dart';
import 'package:handy_notfall/core/widgets/date_picker_field.dart';
import 'package:handy_notfall/core/widgets/device_type_selection.dart';
import 'package:handy_notfall/core/widgets/issue_selection.dart';
import 'package:handy_notfall/features/domain/usecases/save_customer_data_usecase.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/customer_data_telpone_entity.dart';
import 'package:handy_notfall/service/issue_storage_service.dart';
import 'package:handy_notfall/service/storage_service.dart';
import 'package:handy_notfall/service/auftrag_pdf_service.dart';
import '../../domain/entities/defect_item.dart';

class DataTelponeScreen extends StatefulWidget {
  final String firstName;
  final String address;
  final String city;
  final String phoneNumber;
  final String emailAddress;

  const DataTelponeScreen({
    super.key,
    required this.firstName,
    required this.address,
    required this.city,
    required this.phoneNumber,
    required this.emailAddress,
  });

  @override
  State<DataTelponeScreen> createState() => _DataTelponeScreenState();
}

class _DataTelponeScreenState extends State<DataTelponeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController deviceTypesController = TextEditingController();
  final TextEditingController serialNumberController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController customIssueController = TextEditingController();
  final TextEditingController customDeviceController = TextEditingController();

  List<String> selectedDeviceTypes = [];
  List<String> deviceTypes = [
     'Apple', 'Samsung','Xiaomi', 'HP','Dell', 'Lenovo', 'Sony', 'LG', 'Huawei',
    'Toshiba', 'Asus', 'Acer', 'Microsoft', 'Realme', 'HTC', 'Motorola',
    'Blackberry',  'Caterpillar', 'Oppo', 'Google', 'Oneplus',
  ];

  List<String> issueOptions = [
    'Display', 'Akku', 'Kamera', 'Kameraglas', 'Hörmuschel',
    'Ladebuchse', 'Lautsprecher', 'Rückseite', 'Wasserschaden',
    'Geht nicht an', 'Datenübertragung', 'SoftWare', 'Neue', 'Gebraucht',
    'Panzerglas', 'Ladekabel', 'Hülle', 'Ladegerät', 'Nachbesserung',
    'Mikrofon', 'Kostenvoranschlag', 'Tischlampe', 'Reinigung',
  ];

  // Dynamic list for defect cards
  List<DefectCardState> defectCards = [];
  bool _isLoading = true;
  bool _isSaving = false; // متغير للتحكم في حالة الحفظ



  @override
  void initState() {
    super.initState();
    _loadCustomDeviceTypes();
    _loadCustomIssues();
    // Add first defect card by default
    defectCards.add(DefectCardState());
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _loadCustomDeviceTypes() async {
    final customDeviceTypes = await StorageService.loadDeviceTypes();
    setState(() {
      for (final type in customDeviceTypes) {
        if (!deviceTypes.contains(type)) {
          deviceTypes.add(type);
        }
      }
    });
  }

  Future<void> _loadCustomIssues() async {
    final customIssues = await IssueStorageService.loadIssues();
    setState(() {
      // دمج الأعطال المحفوظة مع الافتراضية بدون تكرار
      for (final issue in customIssues) {
        if (!issueOptions.contains(issue)) {
          issueOptions.add(issue);
        }
      }
    });
  }

  @override
  void dispose() {
    modelController.dispose();
    deviceTypesController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    customIssueController.dispose();
    // Dispose defect card controllers
    for (var card in defectCards) {
      card.priceController.dispose();
      card.quantityController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daten'),

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
                onAdd: (value) async {
                  setState(() {
                    if (!selectedDeviceTypes.contains(value)) {
                      selectedDeviceTypes.add(value);
                    }
                    if (!deviceTypes.contains(value)) {
                      deviceTypes.add(value);
                    }
                  });
                  await StorageService.saveDeviceType(value);
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
              // Defect Cards Section
              ...defectCards.asMap().entries.map((entry) {
                int index = entry.key;
                DefectCardState card = entry.value;
                return Column(
                  children: [
                    _buildDefectCard(card, index),
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
                    setState(() {
                      defectCards.add(DefectCardState());
                    });
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              DatePickerField(controller: startDateController, label: 'Anfang *'),
              const SizedBox(height: 16.0),
              DatePickerField(controller: endDateController, label: 'Abholung *'),
              const SizedBox(height: 20.0),
              // add new dart file logic
              Center(
                child: ElevatedButton(

                  onPressed: _isSaving ? null : () async {
                    // منع الضغط المتكرر
                    if (_isSaving) return;
                    
                    setState(() {
                      _isSaving = true;
                    });

                    String? userEmail = FirebaseAuth.instance.currentUser?.email;
                    if (userEmail == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Sie müssen sich zuerst anmelden!')),
                      );
                      setState(() {
                        _isSaving = false;
                      });
                      return;
                    }
                    
                    
                    try {
                      // Collect defects from all cards
                      List<DefectItem> defects = defectCards.map((card) {
                        return DefectItem(
                          issue: card.selectedIssues.join(', '),
                          price: int.tryParse(card.priceController.text.trim()) ?? 0,
                          quantity: int.tryParse(card.quantityController.text.trim()) ?? 1,
                        );
                      }).toList();

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
                        defects: defects,
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

                      // طباعة وفتح PDF للـ Auftrag بالبيانات الحالية
                      await AuftragPdfService.generateAndPrintAuftrag(
                        context: context,
                        entity: entity,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Datei gespeichert!')),
                      );

                      Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Daten konnten nicht gespeichert werden: $e')),
                      );
                    } finally {
                      setState(() {
                        _isSaving = false;
                      });
                    }
                  },
                  child: _isSaving 
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Speichert...',
                            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : const Text(
                        'Speicher Daten',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefectCard(DefectCardState card, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Problem ${index + 1}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (defectCards.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        defectCards.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Issue Selection
            IssueSelection(
              issueOptions: issueOptions,
              selectedIssues: card.selectedIssues,
              customIssueController: customIssueController,
              onAddIssue: (issue) async {
                setState(() {
                  if (!card.selectedIssues.contains(issue)) {
                    card.selectedIssues.add(issue);
                  }
                  if (!issueOptions.contains(issue)) {
                    issueOptions.add(issue);
                  }
                });
                await StorageService.saveIssue(issue);
              },
              onRemoveIssue: (issue) {
                setState(() {
                  card.selectedIssues.remove(issue);
                });
              },
              menuMaxHeight: 200,
            ),
            const SizedBox(height: 12),
            // Price and Quantity in a Row
            Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    controller: card.priceController,
                    label: 'Preis *',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomInputField(
                    controller: card.quantityController,
                    label: 'Menge *',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Helper class to manage state for each defect card
class DefectCardState {
  final List<String> selectedIssues = [];
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController(text: '1');
}
