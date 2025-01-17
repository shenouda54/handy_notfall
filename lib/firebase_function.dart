import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handy_notfall/models/customer_model.dart';
class FirebaseFireStore {

 static CollectionReference<CustomerModel> getCustomersCollection(){
    return FirebaseFirestore.instance
        .collection("Customers")
        .withConverter<CustomerModel>(fromFirestore: (snapshot, _) {
      return CustomerModel.fromJson(snapshot.data()!);
    }, toFirestore: (customerModel, _) {
      return customerModel.toJson();
    },);
  }
static Future<void> addCustomer(CustomerModel model)async{
  var collection = getCustomersCollection();
  var docRef=collection.doc();
  model.id=docRef.id;
  docRef.set(model);

  }
}