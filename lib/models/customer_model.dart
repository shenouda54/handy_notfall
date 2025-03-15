import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  String id;
  String customerFirstName;
  String customerLastName;
  String address;
  String postalCode;
  String city;
  String phoneNumber;
  String emailAddress;
  String deviceType;
  String deviceModel;
  String issue;
  int price;
  Timestamp startDate;
  Timestamp endDate;
  bool isDone;
  String userEmail;

  CustomerModel({
    this.id = '',
    required this.customerFirstName,
    required this.customerLastName,
    required this.address,
    required this.postalCode,
    required this.city,
    required this.phoneNumber,
    required this.emailAddress,
    required this.deviceType,
    required this.deviceModel,
    required this.issue,
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
      customerLastName: json['customerLastName'],
      address: json['address'],
      postalCode: json['postalCode'],
      city: json['city'],
      phoneNumber: json['phoneNumber'],
      emailAddress: json['emailAddress'],
      deviceType: json['deviceType'],
      deviceModel: json['deviceModel'],
      issue: json['issue'],
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
      "customerLastName": customerLastName,
      "address": address,
      "postalCode": postalCode,
      "city": city,
      "phoneNumber": phoneNumber,
      "emailAddress": emailAddress,
      "deviceType": deviceType,
      "deviceModel": deviceModel,
      "issue": issue,
      "price": price,
      "startDate": startDate,
      "endDate": endDate,
      "isDone": isDone,
      "userEmail": userEmail,
    };
  }
}
