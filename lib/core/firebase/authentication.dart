import 'package:firebase_auth/firebase_auth.dart';

abstract class Authentication {
  Future signUp({
    required String email,
    required String password,
  });

  Future<UserCredential> signIn({
    required String email,
    required String password,
  });

  User? getCurrentUser();

  void signOut();
}

class AuthenticationImpl implements Authentication {
  final _firebaseAuth = FirebaseAuth.instance;

  @override
  Future signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    }
  }

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    }
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  @override
  void signOut() {
    _firebaseAuth.signOut();
  }
}
