import 'package:cloud_firestore/cloud_firestore.dart';
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: controller.streamProducts(),
        builder: (context, snapProducts) {
          
          // 1. CEK LOADING
          if (snapProducts.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 2. PERBAIKAN UTAMA DI SINI (Mencegah Crash)
          // Kita cek dulu apakah datanya NULL. Kalau null, jangan dipaksa pakai tanda seru (!).
          if (snapProducts.data == null || snapProducts.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Products"),
            );
          }

          // 3. OLAH DATA (Aman karena sudah lolos pengecekan di atas)
          List<ProductModel> allProducts = [];

          for (var element in snapProducts.data!.docs) {
            allProducts.add(ProductModel.fromJson(element.data()));
          }

          return ListView.builder(
            itemCount: allProducts.length,
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              ProductModel product = allProducts[index];
              return Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: () {
                    // Pindah ke detail
                    Get.toNamed(Routes.DETAIL_PRODUCT, arguments: product);
                  },
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center, // Tambahan agar rapi ke tengah
                            children: [
                              Text(
                                product.code,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),

                              Text(product.name),
                              Text("Qty: ${product.qty}"),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: QrImageView(
                            data: product.code,
                            size: 50.0,
                            version: QrVersions.auto, // Tambahan agar otomatis
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}