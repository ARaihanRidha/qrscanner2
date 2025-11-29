import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  String? uid;
  late FirebaseAuth auth;
  RxString role = "".obs;
  var ifAdmin = false.obs;

  // --- LOGIKA KEAMANAN ---
  var failedAttempts = 0.obs;
  var isLocked = false.obs;
  var remainingSeconds = 0.obs;
  Timer? lockTimer;

  // Level Hukuman
  final int maxAttempts = 3;
  final int firstLockDuration = 10; // Hukuman 1
  final int escalatedLockDuration = 60; // Hukuman 2

  // Status User
  var hasPassedFirstLock = false.obs; // Sudah lewat 10 detik?
  var hasPassedEscalatedLock = false.obs; // Sudah lewat 60 detik?
  var allowMagicLink = false.obs; // Boleh pakai magic link?

  @override
  void onInit() {
    auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((event) async {
      uid = event?.uid;
      if (uid != null) {
        var doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        ifAdmin.value = (doc.data()?['role'] == "admin");
      } else {
        ifAdmin.value = false;
      }
    });
    super.onInit();
  }

  // --- 1. LOGIN BIASA ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (isLocked.value) {
      return {
        "error": true,
        "message": "Akun terkunci sementara. Tunggu ${remainingSeconds.value} detik."
      };
    }

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Login Sukses -> Reset Semua Hukuman
      _resetSecurityFlags();

      String uid = userCredential.user!.uid;
      var doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      role.value = doc.data()?['role'];

      return {"error": false, "message": "Login berhasil"};

    } on FirebaseAuthException catch (e) {
      _handleFailedAttempt(); // Jalankan Hukuman
      return {"error": true, "message": "${e.message}"};
    } catch (e) {
      _handleFailedAttempt();
      return {"error": true, "message": "Tidak dapat login"};
    }
  }

  // --- 2. MANAGEMEN HUKUMAN (LOGIKA INTI) ---
  void _handleFailedAttempt() {
    failedAttempts.value++;

    // Jika gagal sudah 3x atau lebih
    if (failedAttempts.value >= maxAttempts) {

      // HUKUMAN TAHAP 1: Kunci 10 Detik
      if (hasPassedFirstLock.isFalse) {
        _startLockTimer(firstLockDuration);
        hasPassedFirstLock.value = true;
      }
      // HUKUMAN TAHAP 2: Kunci 60 Detik (Jika gagal lagi setelah 10s)
      else if (hasPassedEscalatedLock.isFalse) {
        _startLockTimer(escalatedLockDuration);
        hasPassedEscalatedLock.value = true;
      }
      // TAHAP 3: Magic Link Muncul (Jika gagal lagi setelah 60s)
      else {
        allowMagicLink.value = true; // Trigger UI untuk memunculkan tombol
      }
    }
  }

  void _startLockTimer(int duration) {
    isLocked.value = true;
    remainingSeconds.value = duration;

    // Kita tidak mereset failedAttempts agar hukuman berlanjut (eskalasi)
    // failedAttempts.value = 0; <--- JANGAN DI RESET DISINI

    lockTimer?.cancel();
    lockTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        isLocked.value = false;
        timer.cancel();
      }
    });
  }

  void _resetSecurityFlags() {
    failedAttempts.value = 0;
    hasPassedFirstLock.value = false;
    hasPassedEscalatedLock.value = false;
    allowMagicLink.value = false;
    isLocked.value = false;
    lockTimer?.cancel();
  }

  // --- 3. FITUR MAGIC LINK ---
  Future<void> sendMagicLink(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emailForSignIn', email);

    var acs = ActionCodeSettings(
      // ⚠️ GANTI URL INI DENGAN PROJECT FIREBASE KAMU
      url: 'https://qrcode-9b8c5.firebaseapp.com/login',
      handleCodeInApp: true,
      androidPackageName: 'com.example.qrscanner',
      androidInstallApp: true,
      androidMinimumVersion: '12',
    );

    await auth.sendSignInLinkToEmail(email: email, actionCodeSettings: acs);
  }

  Future<Map<String, dynamic>> loginWithMagicLink(String urlLink) async {
    final prefs = await SharedPreferences.getInstance();
    String? emailAuth = prefs.getString('emailForSignIn');

    if (emailAuth == null) {
      return {"error": true, "message": "Email session hilang. Input email ulang."};
    }

    if (auth.isSignInWithEmailLink(urlLink)) {
      try {
        final userCredential = await auth.signInWithEmailLink(
          email: emailAuth,
          emailLink: urlLink,
        );

        // Reset hukuman jika berhasil masuk lewat link
        _resetSecurityFlags();

        String uid = userCredential.user!.uid;
        var doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
        role.value = doc.data()?['role'] ?? "user";

        return {"error": false, "message": "Login Magic Link Berhasil!"};
      } catch (e) {
        return {"error": true, "message": "Link expired atau salah."};
      }
    } else {
      return {"error": true, "message": "Link tidak valid."};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    try {
      await auth.signOut();
      return {
        "error": false,
        "message": "Logout berhasil"
      };
    } on FirebaseAuthException catch (e) {
      return {
        "error": true,
        "message": "${e.message}"
      };
    } catch (e) {
      return {
        "error": true,
        "message": "Tidak dapat Logout"
      };
    }
  }
  @override
  void onClose() {
    lockTimer?.cancel();
    super.onClose();
  }
}