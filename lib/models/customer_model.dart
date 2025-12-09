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
  String pinCode;
  int price;
  int quantity;
  Timestamp startDate;
  Timestamp endDate;
  bool isDone;
  String userEmail;
  int? printId;
  int? kundennummer; // رقم العميل
  String? auftragNr; // رقم الطلب
  String? rechnungCode; // كود الفاتورة/الفواتير

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
    required this.pinCode,
    required this.price,
    this.quantity = 1,
    required this.userEmail,
    this.printId,
    this.kundennummer, // رقم العميل
    this.auftragNr, // رقم الطلب
    this.rechnungCode, // كود الفاتورة/الفواتير
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
      pinCode: json['pinCode'],
      price: json['price'],
      quantity: json['quantity'] ?? 1,
      userEmail: json['userEmail'] ?? '',
      startDate: json['startDate'] != null ? json['startDate'] as Timestamp : Timestamp.now(),
      endDate: json['endDate'] != null ? json['endDate'] as Timestamp : Timestamp.now(),
      isDone: json['isDone'] ?? false,
      printId: json['printId'],
      kundennummer: json['kundennummer'], // رقم العميل
      auftragNr: json['auftragNr'], // رقم الطلب
      rechnungCode: json['rechnungCode'], // كود الفاتورة/الفواتير
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
      "pinCode": pinCode,
      "price": price,
      "quantity": quantity,
      "startDate": startDate,
      "endDate": endDate,
      "isDone": isDone,
      "userEmail": userEmail,
      "printId": printId,
      "kundennummer": kundennummer, // رقم العميل
      "auftragNr": auftragNr, // رقم الطلب
      "rechnungCode": rechnungCode, // كود الفاتورة/الفواتير
    };
  }
}
