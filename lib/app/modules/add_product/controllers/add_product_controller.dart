import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:qrscanner/app/controllers/auth_controller.dart';

class AddProductController extends GetxController {
  //TODO: Implement AddProductController
  RxBool isLoading = false.obs;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future <Map<String,dynamic>> addProduct(Map<String, dynamic> data) async{
    try {
      // Menambah Product
      var hasil = await firestore.collection("products").add(data); //jika berhasil masuk ke database cloud firebase
      await firestore.collection("products").doc(hasil.id).update({ 
        "productId": hasil.id //blok kode ini dipakai untuk menyimpan id setiap data yg di input yg mana id nya itu otomatis dibikinin firebase
      });
      Get.find<AuthController>().addAuditLog(
      "ADD_PRODUCT", 
      "Menambah produk baru: ${data["name"]} (Qty: ${data["qty"]})"
    );
      return{
        "error": false,
        "Message": "Add Product Succeed"
      };
      
    } catch (e) {
      return {
        "error": true,
        "Message": "Add Product failed"
      };
      
    }

  }

  final count = 0.obs;
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
