import 'package:flutter/material.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mosaic_doctors/shared/locator.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //FirebaseAuth.instance.signOut();
  setupLocator();
    runApp(MaterialApp(
        home: AuthService().handleAuth()));
}

