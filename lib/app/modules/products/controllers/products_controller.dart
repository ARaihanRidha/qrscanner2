import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';

class ProductsController extends GetxController {
  //TODO: Implement ProductsController
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamProducts() async* {
    yield* firestore.collection("products").snapshots();
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
