import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk cek Platform
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // IMPORT WAJIB
import 'package:qrscanner/app/controllers/auth_controller.dart';
import 'package:qrscanner/app/routes/app_pages.dart';

class LoginController extends GetxController {

  RxBool ishidden = true.obs;
  RxBool isLoading = false.obs;

  // Dependency Injections
  final AuthController authC = Get.find<AuthController>();
  final LocalAuthentication authLocal = LocalAuthentication();
  
  // Inisialisasi Penyimpanan Aman
  final storage = const FlutterSecureStorage();

  // ------------------------------------------------------------------------
  // 1. LOGIN MANUAL (Email & Password)
  // Dipanggil dari Tombol Login biasa
  // ------------------------------------------------------------------------
  Future<void> loginProcess(String email, String pass) async {
    if (email.isNotEmpty && pass.isNotEmpty) {
      isLoading.value = true;
      
      // A. Login ke Firebase
      var hasil = await authC.login(email, pass);
      
      isLoading.value = false;

      if (hasil["error"] == true) {
        // Gagal
        Get.snackbar("Gagal", hasil["message"], backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        // B. SUKSES -> Simpan Email & Password ke Secure Storage
        // Ini kunci agar Biometrik bisa bekerja nanti
        await storage.write(key: 'email', value: email);
        await storage.write(key: 'pass', value: pass);
        
        // C. Pindah ke Home
        Get.offAllNamed(Routes.HOME);
      }
    } else {
      Get.snackbar("Error", "Email & Password wajib diisi", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ------------------------------------------------------------------------
  // 2. LOGIN BIOMETRIK
  // Dipanggil dari Icon Sidik Jari
  // ------------------------------------------------------------------------
  Future<void> loginBio() async {
    try {
      // A. Cek Support HP
      bool canCheckBiometrics = await authLocal.canCheckBiometrics;
      bool isDeviceSupported = await authLocal.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        Get.snackbar("Maaf", "HP ini tidak support fitur biometrik", 
          backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // B. Munculkan Popup Scan
      bool didAuthenticate = await authLocal.authenticate(
        localizedReason: 'Scan sidik jari untuk login cepat',
        options: const AuthenticationOptions(
          biometricOnly: true, 
          stickyAuth: true,
        ),
      );

      // C. Jika Jari Cocok
      if (didAuthenticate) {
        // Tampilkan loading agar user tahu sedang proses login
        isLoading.value = true; 

        // D. Ambil Password dari Penyimpanan Aman
        String? savedEmail = await storage.read(key: 'email');
        String? savedPass = await storage.read(key: 'pass');

        // E. Cek apakah ada data tersimpan
        if (savedEmail != null && savedPass != null) {
          // F. SILENT LOGIN KE FIREBASE
          // Kita login ulang user secara diam-diam menggunakan data yg disimpan
          var hasil = await authC.login(savedEmail, savedPass);
          
          isLoading.value = false;

          if (hasil["error"] == false) {
            Get.offAllNamed(Routes.HOME);
            Get.snackbar("Sukses", "Login Biometrik Berhasil");
          } else {
            Get.snackbar("Gagal", "Password tersimpan kedaluwarsa. Mohon login manual ulang.");
          }
        } else {
          isLoading.value = false;
          Get.snackbar("Info", "Anda harus Login Manual (Email & Pass) minimal sekali untuk mengaktifkan fitur ini.");
        }
      }
    } catch (e) {
      isLoading.value = false;
      print(e);
      Get.snackbar("Error", "Gagal memproses biometrik");
    }
  }

  // ------------------------------------------------------------------------
  // 3. MAGIC LINK (Tidak Berubah)
  // ------------------------------------------------------------------------
  void sendMagicLink(String email) async {
    if (email.isEmpty) {
      Get.snackbar("Error", "Email tidak boleh kosong", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      isLoading.value = true;
      await authC.sendMagicLink(email);
      isLoading.value = false;

      if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
        Get.snackbar(
            "Link Terkirim",
            "Cek email Anda. Klik link login dan pilih 'Buka dengan Aplikasi Ini'.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 5)
        );
      } else {
        _showManualPasteDialog();
      }

    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Gagal", "Gagal mengirim email: ${e.toString()}", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

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

  void verifyLinkManually(String link) async {
    Get.back();
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