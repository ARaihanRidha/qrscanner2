import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk cek Platform
import 'package:get/get.dart';
import 'package:qrscanner/app/controllers/auth_controller.dart';
import 'package:qrscanner/app/routes/app_pages.dart';

class LoginController extends GetxController {

  RxBool ishidden = true.obs;
  RxBool isLoading = false.obs;

  // Ambil AuthController
  final AuthController authC = Get.find<AuthController>();

  // Fungsi Kirim Link (Dipanggil dari Tombol)
  void sendMagicLink(String email) async {
    if (email.isEmpty) {
      Get.snackbar("Error", "Email tidak boleh kosong", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      await authC.sendMagicLink(email);
      isLoading.value = false;

      // Cek Platform untuk memberi instruksi yang benar
      if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
        // Instruksi Mobile
        Get.snackbar(
            "Link Terkirim",
            "Cek email Anda. Klik link login dan pilih 'Buka dengan Aplikasi Ini'.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 5)
        );
      } else {
        // Instruksi Desktop/Windows (Dialog Manual)
        _showManualPasteDialog();
      }

    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Gagal", "Gagal mengirim email: ${e.toString()}", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Dialog Khusus Windows
  void _showManualPasteDialog() {
    Get.defaultDialog(
        title: "Verifikasi Manual",
        content: Column(
          children: [
            const Text("1. Buka Email\n2. Copy Link Login\n3. Paste disini:"),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "https://qrscanner2...",
              ),
              onChanged: (val) {
                if (val.contains("apiKey")) {
                  verifyLinkManually(val);
                }
              },
            )
          ],
        ),
        textCancel: "Tutup"
    );
  }

  // Verifikasi Link yang di-paste (Windows)
  void verifyLinkManually(String link) async {
    Get.back(); // Tutup dialog
    isLoading.value = true;

    var hasil = await authC.loginWithMagicLink(link);

    isLoading.value = false;

    if (hasil["error"] == false) {
      Get.offAllNamed(Routes.HOME);
      Get.snackbar("Sukses", "Selamat datang!", backgroundColor: Colors.green, colorText: Colors.white);
    } else {
      Get.snackbar("Gagal", hasil["message"], backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}