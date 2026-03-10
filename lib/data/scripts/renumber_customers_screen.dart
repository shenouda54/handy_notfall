import 'package:flutter/material.dart';
import 'package:handy_notfall/data/scripts/renumber_customers_script.dart';

class RenumberCustomersScreen extends StatefulWidget {
  const RenumberCustomersScreen({super.key});

  @override
  State<RenumberCustomersScreen> createState() => _RenumberCustomersScreenState();
}

class _RenumberCustomersScreenState extends State<RenumberCustomersScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعادة ترقيم العملاء'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ معلومات مهمة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'هذا السكريبت سيعيد ترقيم العملاء (kundennummer) فقط:',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text('• ترتيب العملاء حسب التاريخ الأقدم'),
                    Text('• كل مستخدم منفصل (1, 2, 3...)'),
                    Text('• الحفاظ على auftragNr للأجهزة كما هو'),
                    Text('• تجميع الأجهزة حسب العميل (الاسم + الهاتف)'),
                    SizedBox(height: 8),
                    Text(
                      '⚠️ سيتم تغيير kundennummer فقط، auftragNr سيبقى كما هو',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            if (_statusMessage.isNotEmpty)
              Card(
                color: _statusMessage.contains('✅') ? Colors.green.shade50 : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            
            const SizedBox(height: 20),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _previewCustomerRenumbering,
              icon: const Icon(Icons.visibility),
              label: const Text('معاينة ترقيم العملاء'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _executeCustomerRenumbering,
              icon: const Icon(Icons.people),
              label: const Text('تطبيق ترقيم العملاء'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('جاري معالجة العملاء...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _previewCustomerRenumbering() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري معاينة ترقيم العملاء...';
    });

    try {
      await RenumberCustomersScript.previewCustomerRenumbering();
      setState(() {
        _statusMessage = '✅ تمت معاينة ترقيم العملاء بنجاح! تحقق من الكونسول لرؤية التفاصيل.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ خطأ في معاينة ترقيم العملاء: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _executeCustomerRenumbering() async {
    // تأكيد من المستخدم
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد ترقيم العملاء'),
        content: const Text(
          'هل أنت متأكد من إعادة ترقيم العملاء؟\n\n'
          'سيتم تغيير kundennummer فقط، auftragNr سيبقى كما هو.\n\n'
          'هذا الإجراء لا يمكن التراجع عنه!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري إعادة ترقيم العملاء...';
    });

    try {
      await RenumberCustomersScript.renumberAllCustomers();
      setState(() {
        _statusMessage = '🎉 تم إعادة ترقيم العملاء بنجاح!\nتحقق من الكونسول لرؤية التفاصيل.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ خطأ في إعادة ترقيم العملاء: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}







