import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrscanner/app/controllers/auth_controller.dart';
import 'package:qrscanner/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    AuthController auth = Get.find<AuthController>();
    MobileScannerController scannerController = MobileScannerController();
    return Scaffold(
      appBar: AppBar(title: const Text('HomeView'), centerTitle: true),
      body: GridView.builder(
        itemCount: 4,
        padding: EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        itemBuilder: (context, index) {
          late String title;
          late IconData icon;
          late VoidCallback onTap; //variabel untuk callback

          switch (index) {
            //contoh agar judul dan icon dan ontap berbeda-beda tiap iterasi.
            case 0:
              title = "Add Product";
              icon = Icons.post_add_rounded;
              onTap = () => Get.toNamed(Routes.ADD_PRODUCT);
              break;
            case 1:
              title = "Products";
              icon = Icons.list_alt_outlined;
              onTap = () => Get.toNamed(Routes.PRODUCTS);
              break;
            case 2:
              title = "QR Code";
              icon = Icons.qr_code;
              //scan QR Code
              onTap = () async {
                final result = await Get.toNamed(Routes.QR_SCANNER);
                //Get data search by product code
                if (result != null && result is String) {
                  // Get data search by product code
                  Map<String, dynamic> hasil = await controller.getProductById(
                    result,
                  );

                  if (hasil["error"] == false) {
                    Get.toNamed(
                      Routes.DETAIL_PRODUCT,
                      arguments: hasil["data"],
                    );
                  } else {
                    Get.snackbar("Error", hasil["message"]);
                  }
                }
              };
              break;
            case 3:
              title = "Catalog";
              icon = Icons.document_scanner_outlined;
              onTap = () => {controller.downloadPDF()};
              break;
            default:
          }
          return Material(
            color: Colors.grey.shade300,
            child: InkWell(
              onTap: () {
                onTap(); //harus memakai ().jika tidak, maka tidak berfungsi
              },
              borderRadius: BorderRadius.circular(9),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 50, height: 50, child: Icon(icon)),
                    SizedBox(height: 10),
                    Text(title),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Map<String, dynamic> logout = await auth.logout();
          if (logout["error"] == false) {
            Get.offAllNamed(Routes.LOGIN);
          } else {
            Get.snackbar("Error", "${logout["message"]}");
          }
        },
        child: Icon(Icons.logout),
      ),
    );
  }
}
