import 'package:excel/excel.dart';
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

        body: Column(
          children: [
            SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/icons/Vector.png"),
                SizedBox(width: 10),
                Text(
                  "Stockify",
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                color: Colors.white,

                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Please Insert Your Credentials",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: 30),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Email",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextField(
                            autocorrect: false,
                            controller: emailC,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              label: Text("Email"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Obx(() {
                            return TextField(
                              autocorrect: false,
                              controller: passwordC,
                              decoration: InputDecoration(
                                label: Text("Password"),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    controller.ishidden.toggle();
                                  },
                                  icon: Icon(
                                    controller.ishidden.isFalse
                                        ? Icons.remove_red_eye
                                        : Icons.remove_red_eye_outlined,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                ),
                              ),
                              obscureText: controller.ishidden.value,
                            );
                          }),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              
                              onPressed: () async {
                                if (controller.isLoading.isFalse) {
                                  if (emailC.text.isNotEmpty &&
                                      passwordC.text.isNotEmpty) {
                                    controller.isLoading.value = true;
                                    Map<String, dynamic> hasil = await authC
                                        .login(emailC.text, passwordC.text);
                                    controller.isLoading.value = false;
                            
                                    if (hasil["error"] == true) {
                                      Get.snackbar(
                                        "Error",
                                        hasil["message"],
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    } else {
                                      Get.offAllNamed(Routes.HOME);
                                    }
                                  } else {
                                    Get.snackbar(
                                      "Error",
                                      "Email dan Password harus di isi",
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(9),
                                ),
                                padding: EdgeInsets.all(20),
                                backgroundColor: Colors.blue,
                              ),
                            
                              child: Obx(
                                () => Text(
                                  controller.isLoading.isFalse
                                      ? "Login"
                                      : "Loading.........",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
