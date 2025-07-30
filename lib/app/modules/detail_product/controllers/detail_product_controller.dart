import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DetailProductController extends GetxController {
  //TODO: Implement DetailProductController
  RxBool isLoadingUpdate = false.obs;
  RxBool isLoadingDelete = false.obs;

  final count = 0.obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future <Map<String,dynamic>> editProduct(Map<String, dynamic> data) async{
    try {
      // Menambah Product
      await firestore.collection("products").doc(data["id"]).update({ //mengambil data id yg di input di detail view
        "name" : data["name"], 
        "qty"  : data["qty"]
      });
      return{
        "error": false,
        "Message": "Update Product Succeed"
      };
      
    } catch (e) {
      return {
        "error": true,
        "Message": "Update Product failed"
      }; 
    }
  }
  Future <Map<String,dynamic>> deleteProduct(String id) async{
    try {
      // Menambah Product
      await firestore.collection("products").doc(id).delete();
      return{
        "error": false,
        "Message": "Delete Product Succeed"
      };
      
    } catch (e) {
      return {
        "error": true,
        "Message": "Delete Product failed"
      };
      
    }

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

  void increment() => count.value++;
}
