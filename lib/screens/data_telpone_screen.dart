
import 'package:flutter/material.dart';
import 'package:handy_notfall/firebase_function.dart';
import 'package:handy_notfall/models/customer_model.dart';
import 'package:handy_notfall/screens/data_of_custmer_screen.dart';

class DataTelponeScreen extends StatefulWidget {
  const DataTelponeScreen({super.key});

  @override
  State<DataTelponeScreen> createState() => _DataTelponeScreenState();
}

class _DataTelponeScreenState extends State<DataTelponeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController deviceTypesController = TextEditingController();
  final TextEditingController customerCodeController = TextEditingController();
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
    'Screen',
    'Battery',
    'Camera',
    'Speaker',
    'Charging Port',
  ];

  String? selectedIssue;
  final List<String> selectedIssues = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Data'),
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
                controller: deviceTypesController,
                label: 'Device Type *',
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
                label: 'Device Model *',
              ),
              const SizedBox(height: 16.0),

              // // كود العميل
              // _buildInputField(
              //   controller: customerCodeController,
              //   label: 'Customer Code *',
              // ),
              const SizedBox(height: 16.0),

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
                        'Issues:',
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
                          labelText: 'Select an Issue',
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
                        validator: (value) {
                          if (selectedIssues.isEmpty) {
                            return 'Please select at least one issue.';
                          }
                          return null;
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
                          labelText: 'Add Custom Issue',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              if (customIssueController.text.isNotEmpty &&
                                  !selectedIssues.contains(
                                      customIssueController.text)) {
                                setState(() {
                                  selectedIssues.add(customIssueController.text);
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
                label: 'Repair Price *',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),

              // تاريخ البداية
              _buildDateField(
                controller: startDateController,
                label: 'Start Date *',
                context: context,
              ),
              const SizedBox(height: 16.0),

              // تاريخ النهاية
              _buildDateField(
                controller: endDateController,
                label: 'End Date *',
                context: context,
              ),
              const SizedBox(height: 20.0),

              // زر الحفظ
              Container(
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      CustomerModel model= CustomerModel(customerFirstName: firstNameController.text, customerLastName: lastNameController.text, address: addressController.text, postalCode: AutofillHints.postalCode, city: cityController.text, phoneNumber: phoneController.hashCode, emailAddress: emailController.text, deviceType: deviceTypesController.text, deviceModel: modelController.text, issue: customIssueController.text, price: repairPriceController.hashCode, startDate: Duration.millisecondsPerHour , endDate:Duration.millisecondsPerHour );
                      FirebaseFireStore.addCustomer(model).then((value) {
                        Navigator.pop(context);
                      },);
                      if (_formKey.currentState!.validate() &&
                          selectedIssues.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Data Saved Successfully! Issues: ${selectedIssues.join(', ')}'),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Save Data',
                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold,color: Colors.white),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }

  // حقل اختيار منسدلة
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged, required TextEditingController controller,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
    );
  }
}
