import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/data/print_pdf/generate_pdf.dart';

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

  Future<void> assignCustomerNumber() async {
    setState(() {
      isProcessing = true;
      result = "";
      devices.clear();
    });

    final snapshot = await FirebaseFirestore.instance
        .collection('Customers')
        .where('customerFirstName', isEqualTo: widget.customerName)
        .where('phoneNumber', isEqualTo: widget.customerPhone)
        .get();

    if (snapshot.docs.isEmpty) {
      setState(() {
        isProcessing = false;
        result = "❌ لا توجد أجهزة لهذا العميل.";
      });
      return;
    }

    // Check if already has printId
    final existingPrintId = snapshot.docs.first.data()['printId'];
    if (existingPrintId != null) {
      devices = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        printId = existingPrintId;
        isProcessing = false;
        result = "ℹ️ العميل بالفعل مرقّم برقم $printId";
      });
      return;
    }

    // Generate new printId
    final last = await FirebaseFirestore.instance
        .collection('Customers')
        .orderBy('printId', descending: true)
        .limit(1)
        .get();

    int newPrintId = 2025501;
    if (last.docs.isNotEmpty && last.docs.first.data().containsKey('printId')) {
      newPrintId = last.docs.first['printId'] + 1;
    }

    for (final doc in snapshot.docs) {
      await doc.reference.update({'printId': newPrintId});
    }

    devices = snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();

    setState(() {
      printId = newPrintId;
      isProcessing = false;
      result = "✅ تم ترقيم العميل برقم $newPrintId";
    });
  }

  @override
  void initState() {
    super.initState();
    assignCustomerNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("أجهزة ${widget.customerName}")),
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
