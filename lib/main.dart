import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
import 'package:mosaic_doctors/shared/globalVariables.dart';
import 'package:mosaic_doctors/shared/locator.dart';


main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Global.initializeSharedPreferences();
 //AuthService.signOut();
  setupLocator();
    runApp(MaterialApp(
      home: Scaffold(
          body: EntryPoint()),
    ));
}
class EntryPoint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return ScreenUtilInit(
      designSize: Size(screenWidth, screenHeight),
      allowFontScaling: false,
      child:  AuthService().handleAuth()
    );
  }
}
