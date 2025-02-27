import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthData {
  Future<void> register(String email, String password, String passConfirm);
  Future<void> login(String email, String password);
}

class AuthDataReal extends AuthData {
  @override
  Future<void> login(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(), password: password.trim());
  }

  @override
  Future<void> register(
      String email, String password, String passConfirm) async {
    if (passConfirm == password) {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    }
  }
}
