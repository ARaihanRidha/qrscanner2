import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrscanner/app/data/Models/product_model.dart';
import 'package:qrscanner/app/routes/app_pages.dart';

import '../controllers/products_controller.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products List'), centerTitle: true),
      body: StreamBuilder(
        stream: controller.streamProducts() ,
        builder: (context, snapProducts) {
          if (snapProducts.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapProducts.data!.docs.isEmpty) {
            return Center(
              child: Text("No Products"),
            );
          }
          List<ProductModel> allProducts = [];

          for (var element in snapProducts.data!.docs) {
            allProducts.add(ProductModel.fromJson(element.data())); 
          }
          return Center(
            child: ListView.builder(
              itemCount: allProducts.length,
              padding: EdgeInsets.all(20),
              itemBuilder: (context, index) {
                ProductModel product = allProducts[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9)
                  ),
          
                  child: InkWell(
                    borderRadius: BorderRadius.circular(9),
                    onTap: () {
                      //Pindah ke detail
                      Get.toNamed(Routes.DETAIL_PRODUCT, arguments: product);
                    },
                    child: Container(
                      height: 100,
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.code, style: TextStyle(fontWeight: FontWeight.bold),),
                                SizedBox(height: 0,),
                                Text(product.name),
                                SizedBox(height: 0,),
                                Text("${product.qty}"),
                            
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            width: 50,
                            child: QrImageView(
                              data: product.code,
                              size: 50.0,
                            ),
                          )
                        ],
                      ),
                      
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
    );
  }
}
