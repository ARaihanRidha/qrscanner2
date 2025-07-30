import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  //TODO: Implement AuthController
  String? uid; //cek kondisi ada auth atau tidak
  //null  -> tidak ada user yg sedang login 
  //uid  -> ada user yg sedang login 

  late FirebaseAuth auth;

  final count = 0.obs;
  @override
  void onInit() {
    auth = FirebaseAuth.instance;

    auth.authStateChanges().listen((event) {
      uid = event?.uid;
    },);
    super.onInit();
  }

  Future<Map<String,dynamic>> login(String email, String password) async{
    try { 
      await auth.signInWithEmailAndPassword(email: email, password: password);
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

  void increment() => count.value++;
}
