import 'package:flutter/material.dart';
import '../../presentation/pages/data_telpone_screen.dart';
import '../entities/customer_entity.dart';

class GoToDataScreenUseCase {
  Future<bool?> call(BuildContext context, CustomerEntity customer) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DataTelponeScreen(
          firstName: customer.firstName,
          address: customer.address,
          city: customer.city,
          phoneNumber: customer.phoneNumber,
          emailAddress: customer.emailAddress,
        ),
      ),
    );
  }
}
