import 'package:flutter/material.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mosaic_doctors/services/notifications.dart';
import 'package:mosaic_doctors/services/workmanager.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:workmanager/workmanager.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //FirebaseAuth.instance.signOut();

  MOSAICWorkManager.startChecking();
  Notifications.initialize();

  setupLocator();
    runApp(MaterialApp(
        home: AuthService().handleAuth()));
}

