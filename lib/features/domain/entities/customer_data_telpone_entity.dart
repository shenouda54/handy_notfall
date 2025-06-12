import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDataEntity {
  final String customerFirstName;
  final String address;
  final String city;
  final String phoneNumber;
  final String emailAddress;
  final String deviceType;
  final String deviceModel;
  final String serialNumber;
  final String pinCode;
  final String issue;
  final int price;
  final Timestamp startDate;
  final Timestamp endDate;
  final bool isDone;
  final String userEmail;

  CustomerDataEntity({
    required this.customerFirstName,
    required this.address,
    required this.city,
    required this.phoneNumber,
    required this.emailAddress,
    required this.deviceType,
    required this.deviceModel,
    required this.serialNumber,
    required this.pinCode,
    required this.issue,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.isDone,
    required this.userEmail,
  });
}
