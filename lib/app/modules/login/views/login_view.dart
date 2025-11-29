import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrscanner/app/controllers/auth_controller.dart';
import 'package:qrscanner/app/routes/app_pages.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  LoginView({Key? key}) : super(key: key);

  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final AuthController authC = Get.find<AuthController>(); // Injeksi AuthController

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2567E8), Color(0xFF1CE6DA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Login",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),

                      // FIELD EMAIL
                      TextField(
                        controller: emailC,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          label: const Text("Email"),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // FIELD PASSWORD
                      Obx(() => TextField(
                        controller: passwordC,
                        obscureText: controller.ishidden.value,
                        decoration: InputDecoration(
                          label: const Text("Password"),
                          suffixIcon: IconButton(
                            onPressed: () => controller.ishidden.toggle(),
                            icon: Icon(controller.ishidden.isTrue ? Icons.visibility_off : Icons.visibility),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                        ),
                      )),
                      const SizedBox(height: 20),

                      // TOMBOL LOGIN UTAMA
                      SizedBox(
                        width: double.infinity,
                        child: Obx(() {
                          bool locked = authC.isLocked.value;
                          return ElevatedButton(
                            onPressed: locked
                                ? null // Tombol mati jika terkunci
                                : () async {
                              if (controller.isLoading.isFalse) {
                                if (emailC.text.isNotEmpty && passwordC.text.isNotEmpty) {
                                  controller.isLoading.value = true;

                                  var hasil = await authC.login(emailC.text, passwordC.text);

                                  controller.isLoading.value = false;

                                  if (hasil["error"] == true) {
                                    Get.snackbar("Gagal", hasil["message"], backgroundColor: Colors.red, colorText: Colors.white);
                                  } else {
                                    Get.offAllNamed(Routes.HOME);
                                  }
                                } else {
                                  Get.snackbar("Error", "Email & Password wajib diisi", backgroundColor: Colors.red, colorText: Colors.white);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(20),
                              backgroundColor: Colors.blue,
                            ),
                            child: controller.isLoading.isTrue
                                ? const Text("Loading...", style: TextStyle(color: Colors.white))
                                : Text(
                              locked
                                  ? "Tunggu ${authC.remainingSeconds.value}s"
                                  : "Login",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          );
                        }),
                      ),

                      // ⭐️ FITUR MAGIC LINK (Hanya muncul jika sudah lewat hukuman 60s) ⭐️
                      Obx(() {
                        // Jika authC.allowMagicLink bernilai TRUE, tampilkan tombol ini
                        if (authC.allowMagicLink.isTrue) {
                          return Column(
                            children: [
                              const SizedBox(height: 20),
                              const Divider(),
                              const Text(
                                "Masih kesulitan login?",
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                              TextButton.icon(
                                onPressed: () => controller.sendMagicLink(emailC.text),
                                icon: const Icon(Icons.mark_email_read, color: Colors.orange),
                                label: const Text("Masuk dengan Magic Link (Tanpa Password)", style: TextStyle(color: Colors.orange)),
                              )
                            ],
                          );
                        } else {
                          return const SizedBox.shrink(); // Sembunyikan jika belum waktunya
                        }
                      }),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}