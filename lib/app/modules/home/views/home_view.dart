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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2567E8), Color(0xFF1CE6DA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            "assets/icons/Vector.png", 
                            height: 40,
                            width: 40,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Stockify",
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Greeting
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 800),
                      child: Text(
                        auth.ifAdmin.value
                            ? "Selamat Datang, Admin!"
                            : "Selamat Datang!",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.ifAdmin.value
                          ? "Kelola stok dengan mudah"
                          : "Akses produk dan katalog",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // GridView Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    itemCount: auth.ifAdmin.value ? 4 : 3,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 1.2, // Membuat card lebih square
                        ),
                    itemBuilder: (context, index) {
                      return _buildMenuCard(
                        context,
                        auth.ifAdmin.value,
                        index,
                        auth,
                        controller,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2567E8),
            elevation: 8,
            tooltip: "Logout",
            onPressed: () => _showLogoutDialog(auth),
            child: const Icon(Icons.logout, size: 28),
          ),
        ),
      ),
    );
  }

  // Helper method untuk build menu card (mengurangi duplikasi kode)
  Widget _buildMenuCard(
    BuildContext context,
    bool isAdmin,
    int index,
    AuthController auth,
    HomeController controller,
  ) {
    late String title;
    late IconData icon;
    late Color iconColor;
    late VoidCallback onTap;
    late String subtitle;

    if (isAdmin) {
      iconColor = Colors.green; 
      switch (index) {
        case 0:
          title = "Add Product";
          icon = Icons.post_add_rounded;
          subtitle = "Tambah item baru";
          onTap = () => Get.toNamed(Routes.ADD_PRODUCT);
          break;
        case 1:
          title = "Products";
          icon = Icons.list_alt_outlined;
          subtitle = "Lihat semua produk";
          onTap = () => Get.toNamed(Routes.PRODUCTS);
          break;
        case 2:
          title = "QR Code";
          icon = Icons.qr_code_2_rounded;
          subtitle = "Scan untuk detail";
          onTap = () => _handleQRScan(controller);
          break;
        case 3:
          title = "Catalog";
          icon = Icons.document_scanner_outlined;
          subtitle = "Unduh PDF";
          onTap = () => controller.downloadPDF();
          break;
        default:
          return const SizedBox.shrink();
      }
    } else {
      iconColor = const Color(0xFF2567E8); 
      switch (index) {
        case 0:
          title = "Products";
          icon = Icons.list_alt_outlined;
          subtitle = "Lihat semua produk";
          onTap = () => Get.toNamed(Routes.PRODUCTS);
          break;
        case 1:
          title = "QR Code";
          icon = Icons.qr_code_2_rounded;
          subtitle = "Scan untuk detail";
          onTap = () => _handleQRScan(controller);
          break;
        case 2:
          title = "Catalog";
          icon = Icons.document_scanner_outlined;
          subtitle = "Unduh PDF";
          onTap = () => controller.downloadPDF();
          break;
        default:
          return const SizedBox.shrink();
      }
    }

    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Card(
        elevation: 8,
        shadowColor: iconColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: iconColor.withOpacity(0.2),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iconColor.withOpacity(0.1),
                        iconColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper untuk handle QR Scan (extract dari onTap)
  void _handleQRScan(HomeController controller) async {
    final result = await Get.toNamed(Routes.QR_SCANNER);
    if (result != null && result is String) {
      Map<String, dynamic> hasil = await controller.getProductById(result);
      if (hasil["error"] == false) {
        Get.toNamed(Routes.DETAIL_PRODUCT, arguments: hasil["data"]);
      } else {
        Get.snackbar(
          "Error",
          hasil["message"],
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  // Confirmation dialog untuk logout
  void _showLogoutDialog(AuthController auth) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              Map<String, dynamic> logoutResult = await auth.logout();
              if (logoutResult["error"] == false) {
                Get.offAllNamed(Routes.LOGIN);
              } else {
                Get.snackbar(
                  "Error",
                  "${logoutResult["message"]}",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2567E8),
              foregroundColor: Colors.white,
            ),
            child: const Text("Ya, Logout"),
          ),
        ],
      ),
    );
  }
}
