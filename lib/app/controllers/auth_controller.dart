import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  String? uid; 
  late FirebaseAuth auth;
  RxString role = "".obs;
  var ifAdmin = false.obs;
  var failedAttempts = 0.obs;
  var isLocked = false.obs;
  var remainingSeconds = 0.obs;
  Timer? lockTimer;

  final int maxAttempts = 3;
  final int baseLockDuration = 10; 
  final int escalatedLockDuration = 60; 

  var hasBeenLocked = false.obs; 

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

  Future<Map<String,dynamic>> login(String email, String password) async {
    if (isLocked.value) {
      return {
        "error": true,
        "message": "Terlalu banyak percobaan gagal. Tunggu ${remainingSeconds.value} detik."
      };
    }

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );

      String uid = userCredential.user!.uid;
      var doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      role.value = doc.data()?['role'];
      failedAttempts.value = 0;
      hasBeenLocked.value = false;
      return {
        "error" : false,
        "message" : "Login berhasil"
      };
    } on FirebaseAuthException catch (e) {
      _handleFailedAttempt();
      return {
        "error" : true,
        "message" : "${e.message}"
      };
    } catch (e) {
      _handleFailedAttempt();
      return {
        "error" : true,
        "message" : "Tidak dapat login"
      };
    }
  }

  void _handleFailedAttempt() {
    failedAttempts.value++;

    if (failedAttempts.value >= maxAttempts) {
      if (hasBeenLocked.isFalse) {
        _startLockTimer(baseLockDuration);
        hasBeenLocked.value = true;
      } else {
        _startLockTimer(escalatedLockDuration);
      }
    }
  }

  void _startLockTimer(int duration) {
    isLocked.value = true;
    remainingSeconds.value = duration;
    failedAttempts.value = 0; 

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

  Future<Map<String,dynamic>> logout() async {
    try { 
      await auth.signOut();
      return {
        "error" : false,
        "message" : "Logout berhasil"
      };
    } on FirebaseAuthException catch (e){
      return {
        "error" : true,
        "message" : "${e.message}"
      };
    } catch (e) {
      return {
        "error" : true,
        "message" : "Tidak dapat Logout"
      }; 
    }
  }

  @override
  void onClose() {
    lockTimer?.cancel();
    super.onClose();
  }
}
