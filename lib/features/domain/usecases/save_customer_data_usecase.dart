import 'package:handy_notfall/models/customer_model.dart';
import 'package:handy_notfall/data/customer_service.dart';

import '../entities/customer_data_telpone_entity.dart';

class SaveCustomerDataUseCase {
  Future<void> execute(CustomerDataEntity entity) async {
    final model = CustomerModel(
      customerFirstName: entity.customerFirstName,
      address: entity.address,
      city: entity.city,
      phoneNumber: entity.phoneNumber,
      emailAddress: entity.emailAddress,
      deviceType: entity.deviceType,
      deviceModel: entity.deviceModel,
      serialNumber: entity.serialNumber,
      pinCode: entity.pinCode,
      issue: entity.issue,
      price: entity.price,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isDone: entity.isDone, 
      userEmail: entity.userEmail,
    );

    await CustomerService.saveCustomer(model);
  }
}
