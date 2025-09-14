import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrscanner/app/controllers/auth_controller.dart';
import 'package:qrscanner/app/data/Models/product_model.dart';

import '../controllers/detail_product_controller.dart';

class DetailProductView extends GetView<DetailProductController> {
  DetailProductView({Key? key}) : super(key: key);
  final ProductModel product = Get.arguments;
  final TextEditingController codeC = TextEditingController();
  final TextEditingController nameC = TextEditingController();
  final TextEditingController qtyC = TextEditingController();
  AuthController auth = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    codeC.text = product.code;
    nameC.text = product.name;
    qtyC.text = product.qty.toString();
    return Scaffold(
      appBar: AppBar(title: const Text('DetailProductView'), centerTitle: true),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
                width: 300,
                child: QrImageView(data: product.code),
              ),
            ],
          ),
          SizedBox(height: 20),
          TextField(
            autocorrect: false,
            controller: codeC,
            keyboardType: TextInputType.number,
            maxLength: 10, //jumlah maksimal kode
            readOnly: true,
            decoration: InputDecoration(
              label: Text("Product Code"),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          TextField(
            autocorrect: false,
            controller: nameC,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              label: Text("Product Name"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          SizedBox(height: 20),
          TextField(
            autocorrect: false,
            controller: qtyC,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              label: Text("Quantity"),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
          SizedBox(height: 20),
          if(auth.ifAdmin.value)
          ElevatedButton(
            onPressed: () async {
              if (controller.isLoadingUpdate.isFalse) {
                if (nameC.text.isNotEmpty && qtyC.text.isNotEmpty) {
                  controller.isLoadingUpdate.value = true;
                  //Proses memasukkan data
                  Map<String, dynamic> hasil = await controller.editProduct({
                    "id": product.productId,
                    "name": nameC.text,
                    "qty": int.tryParse(qtyC.text),
                  });
                  controller.isLoadingUpdate.value = false;

                  Get.back();
                  Get.snackbar(
                    hasil["error"] == true ? "Error" : "Succeed",
                    hasil["Message"],
                  );
                } else {
                  Get.snackbar("Error", "Please input all data");
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(9),
              ),
            ),
            child: Obx(
              () => Text(
                controller.isLoadingUpdate.value
                    ? "LOADING........."
                    : "Update Product",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          auth.ifAdmin.value ? 
          TextButton(
            onPressed: () {
              Get.defaultDialog(
                title: "Delete Product",
                middleText: "Are you sure to delete this product?",
                actions: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    child: Text("CANCEL"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      controller.isLoadingDelete.value = true;
                      Map<String, dynamic> hasil = await controller
                          .deleteProduct(product.productId);
                      controller.isLoadingDelete.value = false;
                      Get.back(); //tutup dialog
                      Get.back(); //Balik ke page all product
                      Get.snackbar(
                        hasil["error"] == true ? "Error" : "Succeed",
                        hasil["Message"],
                        duration: Duration(seconds: 2),
                      );
                    },
                    child: Obx(
                      () => controller.isLoadingDelete.value
                          ? Container(
                              padding: EdgeInsets.all(2),
                              height: 25,
                              width: 25,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 1,
                              ),
                            )
                          : Text(
                              "DELETE",
                              style: TextStyle(color: Colors.red),
                            )
                    ),
                  ),
                ],
              );
            },
            child: Text(
              "Delete Product",
              style: TextStyle(color: Colors.red.shade900),
            ),
          ) : SizedBox(),
        ],
      ),
    );
  }
}
