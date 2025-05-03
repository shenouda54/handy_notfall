import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handy_notfall/models/customer_model.dart';

class FirebaseFireStore {

  static CollectionReference<CustomerModel> getCustomersCollection() {
    return FirebaseFirestore.instance
        .collection("Customers")
        .withConverter<CustomerModel>(
      fromFirestore: (snapshot, _) => CustomerModel.fromJson(snapshot.data()!),
      toFirestore: (customerModel, _) => customerModel.toJson(),
    );
  }

  static Future<void> addCustomer(CustomerModel model) async {
    var collection = getCustomersCollection();
    var docRef = collection.doc(model.id.isEmpty ? null : model.id); // ✅ لو معاه ID ياخده لو مفيش يعمل جديد
    model.id = docRef.id; // ✅ نحفظ الـ ID جوه الموديل

    await docRef.set(model); // ✅ حفظ العميل
  }
}
