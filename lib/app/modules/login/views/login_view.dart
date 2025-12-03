import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrscanner/app/controllers/auth_controller.dart';
import 'package:qrscanner/app/routes/app_pages.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  LoginView({Key? key}) : super(key: key);

  final TextEditingController emailC = TextEditingController();
  final TextEditingController passwordC = TextEditingController();
  final AuthController authC = Get.find<AuthController>();

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

                      // TOMBOL LOGIN UTAMA (Update Disini)
                      SizedBox(
                        width: double.infinity,
                        child: Obx(() {
                          // Kita ambil status locked dari AuthController
                          bool locked = authC.isLocked.value;
                          
                          // Kita ambil status loading dari LoginController
                          bool loading = controller.isLoading.value;

                          return ElevatedButton(
                            onPressed: (locked || loading)
                                ? null // Disable tombol jika terkunci atau sedang loading
                                : () {
                                    // PANGGIL FUNGSI CONTROLLER
                                    // Tidak perlu logika if/else rumit disini lagi
                                    controller.loginProcess(emailC.text, passwordC.text);
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(20),
                              backgroundColor: Colors.blue,
                            ),
                            child: loading
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

                      // --- TOMBOL BIOMETRIK ---
                      const SizedBox(height: 20),
                      const Text("Atau masuk dengan", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => controller.loginBio(), // Panggil Biometrik
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.blue.withOpacity(0.1),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fingerprint, size: 30, color: Colors.blue),
                              SizedBox(width: 10),
                              Text("Sidik Jari / Wajah", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      
                      // --- MAGIC LINK SECTION ---
                      Obx(() {
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
                          return const SizedBox.shrink();
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