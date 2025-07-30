import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qrscanner/app/data/Models/product_model.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  RxList<ProductModel> allProducts = List<ProductModel>.empty().obs;

  void downloadPDF() async {
    final pdf = pw.Document();

    var getData = await firestore.collection("products").get();

    //reset all products -> utk mengatasi duplikat
    allProducts.clear();

    //Isi data dari database
    for (var element in getData.docs) {
      allProducts.add(ProductModel.fromJson(element.data()));
      
    }
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          List<pw.TableRow> allData = List.generate(allProducts.length, (index) {
            ProductModel product = allProducts[index];
            return pw.TableRow(
              children: [
                //No
                pw.Padding(
                  padding: pw.EdgeInsets.all(20),
                  child: pw.Text(
                    "${index + 1}",
                    style: pw.TextStyle(
                      fontSize: 10,

                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                //nama barang
                pw.Padding(
                  padding: pw.EdgeInsets.all(20),
                  child: pw.Text(
                    product.name,
                    style: pw.TextStyle(
                      fontSize: 10,

                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                // Quantitas
                pw.Padding(
                  padding: pw.EdgeInsets.all(20),
                  child: pw.Text(
                    product.qty.toString(),
                    style: pw.TextStyle(
                      fontSize: 10,

                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                // QR code
                pw.Padding(
                  padding: pw.EdgeInsets.all(20),
                  child: pw.BarcodeWidget(
                    data: product.code,
                    barcode: pw.Barcode.qrCode(),
                    color: PdfColor.fromHex("#000000"),
                    height: 60,
                    width: 60
                  ),
                ),
              ],
            );
          });
          //Gaboleh widget dari material, harus dari pdf

          //Header Table
          return [
            pw.Center(
              child: pw.Text(
                "CATALOG PRODUCTS",
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 30),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColor.fromHex("#000000"),
                width: 2,
              ),
              children: [
                pw.TableRow(
                  children: [
                    //No
                    pw.Padding(
                      padding: pw.EdgeInsets.all(20),
                      child: pw.Text(
                        "No",
                        style: pw.TextStyle(
                          fontSize: 12,

                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),

                    //nama barang
                    pw.Padding(
                      padding: pw.EdgeInsets.all(20),
                      child: pw.Text(
                        "Product Name",
                        style: pw.TextStyle(
                          fontSize: 12,

                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),

                    // Quantitas
                    pw.Padding(
                      padding: pw.EdgeInsets.all(20),
                      child: pw.Text(
                        "Quantity",
                        style: pw.TextStyle(
                          fontSize: 10,

                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),

                    // QR code
                    pw.Padding(
                      padding: pw.EdgeInsets.all(20),
                      child: pw.Text(
                        "QR CODE",
                        style: pw.TextStyle(
                          fontSize: 10,

                          fontWeight: pw.FontWeight.bold,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                  
                ),
                //Isi table
                ...allData,
              ],
            ),
          ];
        },
      ),
    );

    //Simpan, ubah pdf ke bentuk bytes
    Uint8List bytes = await pdf.save();

    //Buat file kosong di directory
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/mydocument.pdf');

    //memasukkan data bytes ke dalam file kosong yg dibuat dg nama mydocument

    await file.writeAsBytes(bytes);

    //Open pdf

    await OpenFile.open(file.path);

    //Font
  }

  Future<Map<String,dynamic>> getProductById(String productCode) async {

    try {
      var hasil = await firestore.collection("products").where("code", isEqualTo: productCode).get();
      
      if (hasil.docs.isEmpty) {
        throw {
        "error": true,
        "message": "Tidak ada data di database"
      };
      }
      Map<String,dynamic> data = hasil.docs.first.data();


      return {
        "error" : false,
        "message" : "Berhasil mendapatkan detail product dari data",
        "data" : ProductModel.fromJson(data)
      };
      
    } catch (e) {
      return {
        "error": true,
        "message": "Tidak dapat mendapatkan detail product code ini"
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
