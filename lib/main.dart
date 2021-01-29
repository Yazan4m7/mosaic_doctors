import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
import 'package:mosaic_doctors/services/notifications.dart';
import 'package:mosaic_doctors/shared/globalVariables.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:mosaic_doctors/shared/responsive_helper.dart';

import 'services/paymentService.dart';


main() async {

  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await Global.initializeSharedPreferences();
  await Firebase.initializeApp();
 //AuthService.signOut();

    runApp(GetMaterialApp(
      home: MaterialApp(
        home: Scaffold(
            body: EntryPoint()),
      ),
    ));
}
class EntryPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    Notifications.initializeLocalNotificationPlugin(context);
    return ScreenUtilInit(
      designSize: Size(1080 , 1920 ),
      allowFontScaling: false,
      child:  MaterialApp(home:AuthService().handleAuth() ,)
    );
  }
}
