import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controllers/qr_scanner_controller.dart';

class QrScannerView extends GetView<QrScannerController> {
  QrScannerView({Key? key}) : super(key: key);
  final MobileScannerController scannerController = MobileScannerController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QrScannerView'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {
            scannerController.toggleTorch();
          }, icon: Icon(Icons.flash_on)),
          IconButton(onPressed: () {
            scannerController.switchCamera();
          }, icon: Icon(Icons.cameraswitch))
        ],
      ),
      body: MobileScanner(
        controller: scannerController,
        onDetect: (BarcodeCapture capture) {
          if (controller.isScanned.value) return; 
          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;

          if (code != null) {
            controller.isScanned.value = true;
            scannerController.stop();
            Get.back(result: code);
          } else {
            Get.snackbar("QR Error", "QR Tidak Terbaca");
          }
        },
      )
    );
  }
}
