import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mosaic_doctors/SignIn_with_phone.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:mosaic_doctors/views/home.dart';


class AuthService {
  getUserData() {
    FirebaseUser user;
    FirebaseAuth.instance.currentUser().then((value) => user = value);
    return user;
  }

  handleAuth() {

  print("handleAuth()");
    return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            print("handleAuth() snapshot has data");

            FirebaseUser user = snapshot.data;
            getIt<SessionData>().phoneNumber = user.phoneNumber;
            return HomeView();

          } else {
            print("handleAuth() snapshot no data");
            print("handleAuth()");
            return LoginPage();
          }
        });
  }

  static signOut() {
    FirebaseAuth.instance.signOut();
  }

  //SignIn
  signIn(AuthCredential authCreds) async {

    await FirebaseAuth.instance.signInWithCredential(authCreds);
    handleAuth();
  //  UserController.registerNotificationToken();
    // send supplier to his screen with phone number as paramenter
  }

  signInWithOTP(phoneNo, smsCode, verId) {
    AuthCredential authCreds = PhoneAuthProvider.getCredential(
        verificationId: verId, smsCode: smsCode);
//    auth user will be connected to store by phone number, no need for a user record.
//    registerUserToFireStore (phoneNo);

//    Query query = GroceryDataRepository.collection.where((doc) => doc.ownerPhoneNumber ==phoneNo);
//    Stream<QuerySnapshot> querySnapshot = query.snapshots();
//    querySnapshot.firstWhere((StoreOwner doc) => doc.ownerPhoneNumber ==phoneNo).then((value) => null)
//    Future snap = querySnapshot.firstWhere((doc) => doc.ownerPhoneNumber ==phoneNo);
//    for (DocumentSnapshot document in querySnapshot.) {
//    print(document.reference);
//    }

    signIn(authCreds);
  }

//  registerUserToFireStore(String phoneNo) async {
//    final FirebaseUser user = await FirebaseAuth.instance.currentUser();
//    final uid = user.uid;
//    UserDataRepository UDR = UserDataRepository();
//    User newUser = User(phoneNumber: phoneNo);
//    UDR.collection.document(user.uid).setData(newUser.toJson());
//  }
}
//import 'package:pinkblue/database_operations/user_operations.dart';
//import 'package:pinkblue/models/user.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//
//class AuthService {
//
//  final FirebaseAuth _auth = FirebaseAuth.instance;
//
//  // create user obj based on firebase user
//  User _userFromFirebaseUser(FirebaseUser user) {
//    return user != null ? User(id: user.uid) : null;
//  }
//
//  // auth change user stream
//  Stream<User> get user {
//    return _auth.onAuthStateChanged
//    //.map((FirebaseUser user) => _userFromFirebaseUser(user));
//        .map(_userFromFirebaseUser);
//  }
//
  // sign in anon
//  Future signInAnon() async {
//    try {
//      AuthResult result = await _auth.signInAnonymously();
//      FirebaseUser user = result.user;
//      return _userFromFirebaseUser(user);
//    } catch (e) {
//      print(e.toString());
//      return null;
//    }
//  }
//
//  // sign in with email and password
//  Future signInWithEmailAndPassword(String email, String password) async {
//      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
//      FirebaseUser user = result.user;
//      return user;
//  }
//
//  // register with email and password
//  Future registerWithEmailAndPassword(String email, String password) async {
//
//      print("creating user $email $password");
//      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
//      FirebaseUser user = result.user;
//      print(user.toString());
//      // create a new document for the user with the uid
//      await UserQueries(uid: user.uid.toString()).updateUserData('ysxsn','new crew member', password,'123',email);
//      return _userFromFirebaseUser(user);
//
//  }
//
//  // sign out
//  Future signOut() async {
//    try {
//      return await _auth.signOut();
//    } catch (error) {
//      print(error.toString());
//      return null;
//    }
//  }
//
//}
