import 'package:flutter/material.dart';
import 'package:handy_notfall/data/scripts/renumber_all_devices_script.dart';

class RenumberScreen extends StatefulWidget {
  const RenumberScreen({super.key});

  @override
  State<RenumberScreen> createState() => _RenumberScreenState();
}

class _RenumberScreenState extends State<RenumberScreen> {
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعادة ترقيم الأجهزة'),
        backgroundColor: Colors.orange,
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
                      '⚠️ تحذير مهم',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'هذا السكريبت سيعيد ترقيم جميع الأجهزة في قاعدة البيانات:',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text('• ترتيب الأجهزة حسب التاريخ الأقدم'),
                    Text('• كل مستخدم منفصل (5/1, 5/2, 5/3...)'),
                    Text('• كل جهاز رقم منفصل'),
                    Text('• السنة الحالية: 2025'),
                    SizedBox(height: 8),
                    Text(
                      'تأكد من عمل نسخة احتياطية قبل المتابعة!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
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
              onPressed: _isLoading ? null : _previewRenumbering,
              icon: const Icon(Icons.visibility),
              label: const Text('معاينة الترقيم الجديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _executeRenumbering,
              icon: const Icon(Icons.refresh),
              label: const Text('تطبيق إعادة الترقيم'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
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
                      Text('جاري المعالجة...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _previewRenumbering() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري معاينة الترقيم...';
    });

    try {
      await RenumberAllDevicesScript.previewRenumbering();
      setState(() {
        _statusMessage = '✅ تمت المعاينة بنجاح! تحقق من الكونسول لرؤية التفاصيل.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ خطأ في المعاينة: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _executeRenumbering() async {
    // تأكيد من المستخدم
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد إعادة الترقيم'),
        content: const Text(
          'هل أنت متأكد من إعادة ترقيم جميع الأجهزة؟\n\n'
          'هذا الإجراء لا يمكن التراجع عنه!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تأكيد', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'جاري إعادة ترقيم جميع الأجهزة...';
    });

    try {
      await RenumberAllDevicesScript.renumberAllDevices();
      setState(() {
        _statusMessage = '🎉 تم إعادة ترقيم جميع الأجهزة بنجاح!\nتحقق من الكونسول لرؤية التفاصيل.';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ خطأ في إعادة الترقيم: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
