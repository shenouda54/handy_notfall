import 'package:flutter/material.dart';
import 'package:handy_notfall/data/print_pdf/customer_number/view_model/customer_numbering_logic.dart';
import 'package:handy_notfall/data/print_pdf/generate_pdf/view_model/pdf_logic.dart';

import '../../../delete_customer_button.dart';

class CustomerNumberingScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;

  const CustomerNumberingScreen({
    super.key,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  State<CustomerNumberingScreen> createState() => _CustomerNumberingScreenState();
}

class _CustomerNumberingScreenState extends State<CustomerNumberingScreen> {
  bool isProcessing = false;
  String result = "";
  List<Map<String, dynamic>> devices = [];
  int? printId;

  @override
  void initState() {
    super.initState();
    assignNumber();
  }

  Future<void> assignNumber() async {
    setState(() {
      isProcessing = true;
      result = "";
      devices.clear();
    });

    final response = await CustomerNumberingService.assignCustomerNumber(widget.customerName, widget.customerPhone);

    setState(() {
      isProcessing = false;
      result = response["message"];
      if (response["success"]) {
        devices = response["devices"];
        printId = response["printId"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Geräte : ${widget.customerName}"),
      actions: [
        DeleteCustomerButton(
          customerName: widget.customerName,
          customerPhone: widget.customerPhone,
          onDeleted: () {
            Navigator.pop(context); // ✅ نرجع للششاشة اللي قبل بعد الحذف
          },
        ),
      ],),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isProcessing
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Text(result, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (devices.isNotEmpty && printId != null)
              Expanded(
                child: ListView.builder(
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text("${device['deviceType']} - ${device['deviceModel']}"),
                        subtitle: Text("SN: ${device['serialNumber']}"),
                        trailing: ElevatedButton(
                          onPressed: () {
                            generatePdf(device, context, printId!);
                          },
                          child: const Text("PDF"),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
