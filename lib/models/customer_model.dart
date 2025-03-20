import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  String id;
  String customerFirstName;
  String address;
  String city;
  String phoneNumber;
  String emailAddress;
  String deviceType;
  String deviceModel;
  String issue;
  String serialNumber;
  int price;
  Timestamp startDate;
  Timestamp endDate;
  bool isDone;
  String userEmail;

  CustomerModel({
    this.id = '',
    required this.customerFirstName,
    required this.address,
    required this.city,
    required this.phoneNumber,
    required this.emailAddress,
    required this.deviceType,
    required this.deviceModel,
    required this.issue,
    required this.serialNumber,
    required this.price,
    required this.userEmail,
    Timestamp? startDate,
    Timestamp? endDate,
    this.isDone = false,
  })  : startDate = startDate ?? Timestamp.now(),
        endDate = endDate ?? Timestamp.now();

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] ?? '',
      customerFirstName: json['customerFirstName'],
      address: json['address'],
      city: json['city'],
      phoneNumber: json['phoneNumber'],
      emailAddress: json['emailAddress'],
      deviceType: json['deviceType'],
      deviceModel: json['deviceModel'],
      issue: json['issue'],
      serialNumber: json['serialNumber'],
      price: json['price'],
      startDate: json['startDate'] != null ? json['startDate'] as Timestamp : Timestamp.now(),
      endDate: json['endDate'] != null ? json['endDate'] as Timestamp : Timestamp.now(),
      isDone: json['isDone'] ?? false,
      userEmail: json['userEmail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "customerFirstName": customerFirstName,
      "address": address,
      "city": city,
      "phoneNumber": phoneNumber,
      "emailAddress": emailAddress,
      "deviceType": deviceType,
      "deviceModel": deviceModel,
      "issue": issue,
      "serialNumber": serialNumber,
      "price": price,
      "startDate": startDate,
      "endDate": endDate,
      "isDone": isDone,
      "userEmail": userEmail,
    };
  }
}
