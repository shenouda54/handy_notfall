import 'package:flutter/material.dart';

import '../../../../../core/widgets/delete_customer_button.dart';
import '../../../screen_pdfs/rechnung/view_model/pdf_logic.dart';
import '../view_model/customer_numbering_logic.dart';

class CustomerNumberingScreen extends StatefulWidget {
  final String customerName;
  final String customerPhone;

  const CustomerNumberingScreen({
    super.key,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  State<CustomerNumberingScreen> createState() =>
      _CustomerNumberingScreenState();
}

class _CustomerNumberingScreenState extends State<CustomerNumberingScreen> {
  bool isProcessing = false;
  String result = "";
  List<Map<String, dynamic>> devices = [];
  int? kundennummer;

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

    final response = await CustomerNumberingService.assignCustomerNumber(
        widget.customerName, widget.customerPhone);

    setState(() {
      isProcessing = false;
      result = response["message"];
      if (response["success"]) {
        devices = response["devices"];
        kundennummer = response["kundennummer"];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Geräte : ${widget.customerName}"),
        actions: [
          DeleteCustomerButton(
            customerName: widget.customerName,
            customerPhone: widget.customerPhone,
            onDeleted: () {
              Navigator.pop(context); // ✅ نرجع للششاشة اللي قبل بعد الحذف
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isProcessing
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Text(result,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  if (devices.isNotEmpty && kundennummer != null)
                    Expanded(
                      child: ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          final device = devices[index];
                          final isSelected = device['isSelectedDevice'] == true;
                          final deviceId = device['docId'];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: isSelected ? 4 : 1,
                            color: isSelected ? Colors.blue.shade50 : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? Colors.blue : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: ListTile(
                              onTap: () async {
                                // Select this device
                                if (!mounted) return;
                                final scaffoldMessenger = ScaffoldMessenger.of(context);
                                
                                setState(() => isProcessing = true);
                                
                                final response = await CustomerNumberingService.selectDevice(
                                  deviceId: deviceId,
                                  customerName: widget.customerName,
                                  customerPhone: widget.customerPhone,
                                );
                                
                                if (response['success']) {
                                  // Update local state
                                  setState(() {
                                    for (var d in devices) {
                                      d['isSelectedDevice'] = (d['docId'] == deviceId);
                                    }
                                    isProcessing = false;
                                  });
                                  
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(response['message']),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  setState(() => isProcessing = false);
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(response['message']),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              leading: Icon(
                                isSelected ? Icons.check_circle : Icons.circle_outlined,
                                color: isSelected ? Colors.blue : Colors.grey,
                                size: 28,
                              ),
                              title: Text(
                                "${device['deviceType']} - ${device['deviceModel']}",
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("SN: ${device['serialNumber']}"),
                                  Text("Kundennummer: ${device['kundennummer'] ?? 'غير متوفر'}"),
                                  Text("Auftrag Nr: ${device['auftragNr'] ?? 'غير متوفر'}"),
                                  if (isSelected)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        "✅ Aktives Gerät",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  final auftragNr = device['auftragNr']?.toString() ?? '';
                                  generatePdf(device, context, auftragNr);
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
