import 'package:customer_portal/database/database_service.dart';
import 'package:customer_portal/model/singletons_data.dart';
import 'package:customer_portal/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  //sign in anonymously
  final FirebaseAuth _auth;

  //FirebaseAuth instance
  AuthService(this._auth);

  //Constuctor to initalize the FirebaseAuth instance
  Stream<User?> get authState => _auth.idTokenChanges();

  //create user obj from FirebaseUser
  MyUser? _userFromFirebaseUser(User? user) {
    return user != null ? MyUser(uid: user.uid) : null;
  }

  //auth change user stream
  Stream<MyUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  Future<void> sendEmailVerificationLink() async {
    try {
      _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  //Register as new user
  Future registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    List<String> sector,
    List<String> port,
    String stakeHolder,
    List<String> modules,
    bool acceptedTCs,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      var prefs = await SharedPreferences.getInstance();
      //create a new document users for the user with the uid
      await DatabaseService(user!.uid).createUserData(
        displayName,
        user.email!.toLowerCase(),
        stakeHolder,
        prefs.getString('fcmToken') ?? '',
        port.isEmpty ? ['TPT - Durban RORO'] : port,
        sector,
        modules,
        acceptedTCs,
      );

      //create a new entry in approvals
      for (var module in modules) {
        if (appData.modulesList
            .where((element) => element.module == module)
            .first
            .requiresApproval) {
          await DatabaseService(
            null,
          ).updateApprovalsData(email.toLowerCase(), module);
        }
      }

      await user.sendEmailVerification();

      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        debugPrint('The password provided is too weak.');
      } else if (e.code == "email-already-in-use") {
        debugPrint('An account already exists for that email.');
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  //Register as new user
  Future registerAPIWithEmailAndPassword(
    String email,
    String password,
    String displayName,
    String stakeHolder,
    List<ModuleData> moduleData,
    bool acceptedTCs,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      var prefs = await SharedPreferences.getInstance();
      //create a new document users for the user with the uid
      await DatabaseService(user!.uid).createApiUserData(
        displayName,
        user.email!.toLowerCase(),
        stakeHolder,
        prefs.getString('fcmToken') ?? '',
        moduleData,
        acceptedTCs,
      );

      await user.sendEmailVerification();

      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        debugPrint('The password provided is too weak.');
      } else if (e.code == "email-already-in-use") {
        debugPrint('An account already exists for that email.');
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  //Sign in existing user
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      return _userFromFirebaseUser(user!);
    } catch (e) {
      debugPrint('err: ${e.toString()}');
      return 'err: ${e.toString()}';
    }
  }

  //Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  //Delete user
  Future deleteUser() async {
    try {
      await DatabaseService(null).deleteProfileData().then(
        (value) async => {await _auth.currentUser!.delete()},
      );
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint(e.toString());

      if (e.code == "requires-recent-login") {
        return await _reauthenticateAndDelete();
      } else {
        // Handle other Firebase exceptions
        debugPrint(e.toString());
        return e.toString();
      }
    } catch (e) {
      // Handle general exception
      debugPrint(e.toString());
      return e.toString();
    }
  }

  //handle requires recent login error
  Future _reauthenticateAndDelete() async {
    try {
      final providerData = _auth.currentUser?.providerData.first;

      if (AppleAuthProvider().providerId == providerData!.providerId) {
        await _auth.currentUser!.reauthenticateWithProvider(
          AppleAuthProvider(),
        );
      } else if (GoogleAuthProvider().providerId == providerData.providerId) {
        await _auth.currentUser!.reauthenticateWithProvider(
          GoogleAuthProvider(),
        );
      }

      await DatabaseService(null).deleteProfileData().then(
        (value) async => {await _auth.currentUser!.delete()},
      );
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  //Password reset
  Future passwordReset(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
