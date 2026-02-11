import 'package:handy_notfall/models/customer_model.dart';
import 'package:handy_notfall/service/customer_service.dart';

import '../entities/customer_data_telpone_entity.dart';

class SaveCustomerDataUseCase {
  Future<void> execute(CustomerDataEntity entity) async {
    // Convert defects list to maps
    final defectsMaps = entity.defects.map((e) => e.toMap()).toList();
    
    // For backward compatibility, use first defect for legacy fields
    String firstIssue = 'No Issues';
    int firstPrice = 0;
    int firstQuantity = 1;
    
    if (entity.defects.isNotEmpty) {
      firstIssue = entity.defects.first.issue;
      firstPrice = entity.defects.first.price;
      firstQuantity = entity.defects.first.quantity;
    }

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
      issue: firstIssue,
      price: firstPrice,
      quantity: firstQuantity,
      defects: defectsMaps,
      startDate: entity.startDate,
      endDate: entity.endDate,
      isDone: entity.isDone, 
      userEmail: entity.userEmail,
    );

    await CustomerService.saveCustomer(model);
  }
}
