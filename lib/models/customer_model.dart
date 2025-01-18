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
  int startDate;
  int endDate;
  bool isDone;

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
    required this.startDate,
    required this.endDate,
    this.isDone = false,
  });

  CustomerModel.fromJson(Map<String, dynamic> json)
      : this(
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
          startDate: json['startDate'],
          endDate: json['endDate'],
          isDone: json['isDone'],
          id: json['id'],
        );

  Map<String, dynamic> toJson() {
    return {
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
      "id": id,
    };
  }
}
