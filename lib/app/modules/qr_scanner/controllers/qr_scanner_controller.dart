import 'package:get/get.dart';

class QrScannerController extends GetxController {
  //TODO: Implement QrScannerController
  RxBool isScanned = false.obs;
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
