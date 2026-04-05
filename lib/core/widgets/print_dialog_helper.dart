import 'package:flutter/material.dart';

class PrintDialogHelper {
  static Future<String?> showPrintOptionsDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'print'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.print, color: Colors.blue),
                  SizedBox(width: 12),
                  Text("Drucken", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'email_me'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.blueGrey),
                  SizedBox(width: 12),
                  Text("An meine E-Mail", style: TextStyle(fontSize: 16)),
                ],
              ),

            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'email_customer'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.alternate_email, color: Colors.orange),
                  SizedBox(width: 12),
                  Text("An Kunden-E-Mail", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool?> showConfirmationDialog(BuildContext context, String actionText, String type) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد"),
        content: Text(
            "هل تريد توليد $actionText كود $type لهذا الطلب؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("لا"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("نعم"),
          ),
        ],
      ),
    );
  }
}
