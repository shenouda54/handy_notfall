import 'package:flutter/material.dart';

class DataTelponeScreen extends StatelessWidget {
  const DataTelponeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController modelController = TextEditingController();
    final TextEditingController customerCodeController =
        TextEditingController();
    final TextEditingController devicePasswordController =
        TextEditingController();
    final TextEditingController issueController = TextEditingController();
    final TextEditingController repairPriceController = TextEditingController();
    final TextEditingController simPasswordController = TextEditingController();
    final TextEditingController startDateController = TextEditingController();
    final TextEditingController endDateController = TextEditingController();

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
      'Nvidia',
      'MacBook',
      'AirPods',
      'PlayStation',
      'OLED',
      'Xiaomi',
      'Casio ',
      'Sennheiser ',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Data'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child:   // نوع الجهاز
                    DropdownButtonFormField<String>(
                      value: selectedDeviceType,
                      decoration: const InputDecoration(
                        labelText: 'Device Type *',
                        border: OutlineInputBorder(),
                      ),
                      items: deviceTypes
                          .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                          .toList(),
                      onChanged: (value) {
                        selectedDeviceType = value;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a device type';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: // موديل الجهاز
                    TextFormField(
                      controller: modelController,
                      decoration: const InputDecoration(
                        labelText: 'Device Model *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the device model';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),




              const SizedBox(height: 16),
              // كود العميل
              TextFormField(
                controller: customerCodeController,
                decoration: const InputDecoration(
                  labelText: 'Customer Code *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the customer code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // باسورد الجهاز
              TextFormField(
                controller: devicePasswordController,
                decoration: const InputDecoration(
                  labelText: 'Device Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              // العطل
              TextFormField(
                controller: issueController,
                decoration: const InputDecoration(
                  labelText: 'Issue *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the issue';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // سعر التصليح
              TextFormField(
                controller: repairPriceController,
                decoration: const InputDecoration(
                  labelText: 'Repair Price *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the repair price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // باسورد الشريحة
              TextFormField(
                controller: simPasswordController,
                decoration: const InputDecoration(
                  labelText: 'SIM Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              // تاريخ التسجيل
              TextFormField(
                controller: startDateController,
                decoration: const InputDecoration(
                  labelText: 'Start Date *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the start date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // تاريخ انتهاء التصليح
              TextFormField(
                controller: endDateController,
                decoration: const InputDecoration(
                  labelText: 'End Date *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the end date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // زر الحفظ
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // حفظ البيانات أو أي منطق آخر
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Data Saved Successfully!')),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
