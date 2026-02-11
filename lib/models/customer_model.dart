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
  List<Map<String, dynamic>> defects; // New field for multiple defects

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
    this.defects = const [],
    required this.userEmail,
    this.printId,
    this.kundennummer,
    this.auftragNr,
    this.rechnungCode,
    Timestamp? startDate,
    Timestamp? endDate,
    this.isDone = false,
  })  : startDate = startDate ?? Timestamp.now(),
        endDate = endDate ?? Timestamp.now();

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    // Handle new defects field with fallback to old structure
    List<Map<String, dynamic>> defectsList = [];
    if (json['defects'] != null) {
      defectsList = List<Map<String, dynamic>>.from(json['defects']);
    } else {
      // Fallback for old data
      defectsList.add({
        'issue': json['issue'] ?? '',
        'price': json['price'] ?? 0,
        'quantity': json['quantity'] ?? 1,
      });
    }

    return CustomerModel(
      id: json['id'] ?? '',
      customerFirstName: json['customerFirstName'],
      address: json['address'],
      city: json['city'],
      phoneNumber: json['phoneNumber'],
      emailAddress: json['emailAddress'],
      deviceType: json['deviceType'],
      deviceModel: json['deviceModel'],
      issue: json['issue'] ?? '',
      serialNumber: json['serialNumber'],
      pinCode: json['pinCode'],
      price: json['price'] ?? 0,
      quantity: json['quantity'] ?? 1,
      defects: defectsList,
      userEmail: json['userEmail'] ?? '',
      startDate: json['startDate'] != null ? json['startDate'] as Timestamp : Timestamp.now(),
      endDate: json['endDate'] != null ? json['endDate'] as Timestamp : Timestamp.now(),
      isDone: json['isDone'] ?? false,
      printId: json['printId'],
      kundennummer: json['kundennummer'],
      auftragNr: json['auftragNr'],
      rechnungCode: json['rechnungCode'],
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
      "defects": defects,
      "startDate": startDate,
      "endDate": endDate,
      "isDone": isDone,
      "userEmail": userEmail,
      "printId": printId,
      "kundennummer": kundennummer,
      "auftragNr": auftragNr,
      "rechnungCode": rechnungCode,
    };
  }
}
