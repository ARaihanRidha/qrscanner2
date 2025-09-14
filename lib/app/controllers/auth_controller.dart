import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  //TODO: Implement AuthController
  String? uid; 
  late FirebaseAuth auth;
  RxString role = "".obs;
  var ifAdmin = false.obs;
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
    },);
    super.onInit();
  }

  Future<Map<String,dynamic>> login(String email, String password) async{
    try { 
      

      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      String uid = userCredential.user!.uid;

      var doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      role.value = doc.data()?['role'];
      return {
        "error" : false,
        "message" : "login berhasil"
      };
    } on FirebaseAuthException catch (e){
      return {
        "error" : true,
        "message" : "${e.message}"
      };
    }
    catch (e) {
      return {
        "error" : true,
        "message" : "Tidak dapat login"
      }; 
    }
  }
  Future<Map<String,dynamic>> logout() async{
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
    }
    catch (e) {
      return {
        "error" : true,
        "message" : "Tidak dapat Logout"
      }; 
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
