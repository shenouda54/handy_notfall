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
    try {
      var collection = getCustomersCollection();
      var docRef = collection.doc(model.id.isEmpty ? null : model.id);
      model.id = docRef.id;

      await docRef.set(model);
      print("✅ Customer saved successfully");
    } catch (e) {
      print("❌ Error saving customer: $e");
      throw Exception('Failed to save customer: $e');
    }
  }
}
