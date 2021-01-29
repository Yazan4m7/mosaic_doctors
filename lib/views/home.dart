import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mosaic_doctors/models/doctor.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/services/DatabaseAPI.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
import 'package:mosaic_doctors/services/notifications.dart';
import 'package:mosaic_doctors/services/security.dart';
import 'package:mosaic_doctors/shared/font_styles.dart';
import 'package:mosaic_doctors/shared/globalVariables.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:mosaic_doctors/shared/responsive_helper.dart';
import 'package:mosaic_doctors/shared/styles.dart';
import 'package:mosaic_doctors/shared/widgets.dart';
import 'package:mosaic_doctors/views/accountStatement.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'loggedInDevices.dart';
class HomeView extends StatefulWidget {
  @override
  _homeViewState createState() => _homeViewState();
}

class _homeViewState extends State<HomeView> {
  String doctorName = "";
  bool isLoading = true;
  List<PopupMenuEntry<String>> options = [];
  getDoctorData() async {



    Doctor doctor =  await DatabaseAPI.getDoctorInfo(Global.prefs.getString("phoneNo"));
    if (doctor == null) {
      getIt<SessionData>().loginWelcomeMessage =
          "Number not assiocated with a doctor account, please contact MOSAIC";
      print("doc is null");
      AuthService.signOut();
    } else {
      doctorName = doctor.name;
      isLoading = false;
      if(mounted)
      setState(() {});
    }
  }
  checkSession() async{
    Future.delayed(Duration(seconds: 3));
    if ( await Security.checkSession() == SessionStatus.inValid){
      print("Session status : invalid");
      AuthService.signOut();
    }
    else{
      print("Session status : valid");
    }
  }
  @override
  void initState() {

    Responsiveness.setResponsiveProperties();
    getDoctorData();
    Notifications.initializeFCM();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
   // checkSession();
    //double screenWidth = MediaQuery.of(context).size.width;

    double screenHeight = MediaQuery.of(context).size.height ;
    GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
    return MaterialApp(
      //  theme: GlobalTheme.globalTheme,
    //backgroundColor: Colors.white.withOpacity(.97),
    home: Scaffold(
        key: _scaffoldKey,
      resizeToAvoidBottomInset:false,
      body: SafeArea(
        bottom: true,
        child: Container(
          height: screenHeight ,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Color(0xffc3c3c3), Colors.white30]),
          ),
          child: Stack(
            children: [
              Container(
                alignment: Alignment(2.5, 5),
                child: Image.asset(
                  'assets/images/logo_transaperant.png',
                  height: 600,
                ),
              ),
              isLoading
                  ? Container(
                      child: SpinKitChasingDots(
                      color: Colors.black,
                    ))
                  : Column(

                      children: [
                        SharedWidgets.getAppBarUI(context, _scaffoldKey, "HOME",PopupMenuButton<String>(
                          onSelected: popupMenuAction,
                          itemBuilder: (BuildContext context) {
                            options.clear();

                            options.add(PopupMenuItem(
                              child: Row(
                                children: [
                                  Icon(Icons.logout),
                                  SizedBox(width: 5,),
                                  Text(
                                    "Log out",
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                              value: "Sign out",
                            ));
                            return options;
                          },
                        ),_exitApp),
                        Padding(
                          padding:  EdgeInsets.only(top: screenHeight/13),
                          child: Image.asset(
                            'assets/images/logo_black_vertical.png',
                            width: Responsiveness.logoWidth.w,
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(top:screenHeight/18),
                            child: Text(
                              getIt<SessionData>().doctor.id == "103" ? "" + doctorName: "د. " + doctorName,
                              style: MyFontStyles.doctorNameFontStyle(context),
                            )),
                        SizedBox(height: screenHeight/120,),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 4,
                            child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xffEDEDED), Color(0xffF9F9F9)],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                    ),
                                    borderRadius: BorderRadius.circular(15.0)),
                                height: screenHeight / 8.5,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 25),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Center(
                                          child: Text(
                                        'View Account Statement',
                                        style: TextStyle(fontSize: Responsiveness.mainNavCardsFontSize),
                                      )),
//                                      Image.asset(
//                                        'assets/images/account-statement.png',
//                                        height: (screenHeight / 12).h,
//                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {

                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        AccountStatementView()));
                              },
                            ),
                          ),
                        ),

                      ],
                    ),
            ],
          ),
        ),
      ),
    ));
  }
  static _exitApp(){
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }
  popupMenuAction(String optionSelected) {

    switch (optionSelected) {
      case "Sign out":
        AuthService.signOut();
        break;
      case "Logged in devices":
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                LoggedInDevices()));
        break;


    }
  }
}
