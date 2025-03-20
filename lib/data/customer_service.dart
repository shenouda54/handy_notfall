import 'package:handy_notfall/firebase_function.dart';
import 'package:handy_notfall/models/customer_model.dart';

class CustomerService {
  static Future<void> saveCustomer(CustomerModel model) async {
    await FirebaseFireStore.addCustomer(model);
  }
}
