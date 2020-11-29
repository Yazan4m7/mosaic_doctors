import 'package:flutter/material.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mosaic_doctors/services/notifications.dart';
import 'package:mosaic_doctors/services/scheduler.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:mosaic_doctors/shared/responsive_helper.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();



  setupLocator();
    runApp(MaterialApp(
        home: AuthService().handleAuth()));
}

