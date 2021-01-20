import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
import 'package:mosaic_doctors/shared/globalVariables.dart';
import 'package:mosaic_doctors/shared/locator.dart';


main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await Global.initializeSharedPreferences();

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

    return ScreenUtilInit(
      designSize: Size(1080 , 1920 ),
      allowFontScaling: false,
      child:  AuthService().handleAuth()
    );
  }
}
