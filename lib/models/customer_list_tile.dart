import 'package:flutter/material.dart';
import 'package:handy_notfall/models/customer_details_screen.dart';
import 'package:handy_notfall/models/edit_customer_screen.dart';
import 'package:handy_notfall/screens/data_telpone_screen.dart';

class CustomerListTile extends StatelessWidget {
  final Map<String, dynamic> customer;
  final VoidCallback? onEdit;

  const CustomerListTile({super.key, required this.customer,this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(customer["firstName"]),
        subtitle: Text(
          "Gerät: ${customer["deviceType"]}"
          " , ${customer["deviceModel"]}\n"
          "Problem: ${customer["issue"]}\n"
          "Handynummer: ${customer["phone"]}\n"
          "PIN code: ${customer["pinCode"]}\n"
          "Preis: ${customer["price"]}€",
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.orange),
              tooltip: 'Add New Device',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DataTelponeScreen(
                      firstName: customer["firstName"],
                      address: customer["address"],
                      city: customer["city"],
                      phoneNumber: customer["phone"],
                      emailAddress: customer["email"],
                    ),
                  ),
                );
    if (result == true) {
    if (onEdit != null) onEdit!();
              }
              }
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditCustomerScreen(
                      customerId: customer['id'],
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CustomerDetailsScreen(customerId: customer['id']),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
