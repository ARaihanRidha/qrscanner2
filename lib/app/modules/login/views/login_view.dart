import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:qrscanner/app/controllers/auth_controller.dart';
import 'package:qrscanner/app/routes/app_pages.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  LoginView({Key? key}) : super(key: key);
  final TextEditingController emailC = TextEditingController(
    text: "admin@gmail.com",
  );
  final TextEditingController passwordC = TextEditingController(
    text: "admin123",
  );

  final AuthController authC = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('LoginView', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
          ElevatedButton(
            onPressed: () async {
              if (controller.isLoading.isFalse) {
                if (emailC.text.isNotEmpty && passwordC.text.isNotEmpty) {
                  controller.isLoading.value = true;
                  Map<String, dynamic> hasil = await authC.login(
                    emailC.text,
                    passwordC.text,
                  );
                  controller.isLoading.value = false;

                  if (hasil["error"] == true) {
                    Get.snackbar(
                      "Error",
                      hasil["message"],
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  } else{
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
                controller.isLoading.isFalse ? "LOGIN" : "LOADING.........",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
