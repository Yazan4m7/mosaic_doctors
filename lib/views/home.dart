import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:mosaic_doctors/models/doctor.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/services/DatabaseAPI.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
import 'package:mosaic_doctors/shared/font_styles.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:mosaic_doctors/shared/responsive_helper.dart';
import 'package:mosaic_doctors/shared/styles.dart';
import 'package:mosaic_doctors/shared/widgets.dart';
import 'package:mosaic_doctors/views/accountStatement.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class HomeView extends StatefulWidget {
  @override
  _homeViewState createState() => _homeViewState();
}

class _homeViewState extends State<HomeView> {
  String doctorName = "";
  bool isLoading = true;
  getDoctorData() async {
    Doctor doctor =
        await DatabaseAPI.getDoctorInfo(getIt<SessionData>().phoneNumber);
    if (doctor == null) {
      getIt<SessionData>().loginWelcomeMessage =
          "Number not assiocated with a doctor account, please contact MOSAIC";
      print("doc is null");
      AuthService.signOut();
    } else {
      doctorName = doctor.name;
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    getDoctorData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height ;
    GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
    key: _scaffoldKey,
    //backgroundColor: Colors.white.withOpacity(.97),
    body: MaterialApp(
      theme: GlobalTheme.globalTheme,
      home: SafeArea(
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
                      child: SpinKitWanderingCubes(
                      color: Colors.black,
                    ))
                  : Column(
                      children: [
                        SharedWidgets.getAppBarUI(context, _scaffoldKey, "HOME",null,_exitApp),
                        Image.asset(
                          'assets/images/logo_black.png',
                          width: Responsiveness.logoWidth,
                        ),
                        Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              getIt<SessionData>().doctor.id == "103" ? "" + doctorName: "د. " + doctorName,
                              style: MyFontStyles.doctorNameFontStyle(context),
                            )),
                        SizedBox(height: screenHeight/60,),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 3,
                            child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xffEDEDED), Color(0xffF9F9F9)],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                    ),
                                    borderRadius: BorderRadius.circular(15.0)),
                                height: screenHeight / 7.5,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 25),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Center(
                                          child: Text(
                                        'Account Statement',
                                        style: TextStyle(fontSize: 21.sp),
                                      )),
                                      Image.asset(
                                        'assets/images/account-statement.png',
                                        height: (screenHeight / 12).h,
                                      ),
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
                        Padding(
                          padding: const EdgeInsets.only(left:20,right:20),
                          child: Card(

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 3,
                            child: InkWell(

                              child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xffEDEDED), Color(0xffF9F9F9)],
                                      begin: Alignment.topRight,
                                      end: Alignment.bottomLeft,
                                    ),
                                    borderRadius: BorderRadius.circular(15.0)),
                                height: screenHeight / 7.5,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 25, right: 14),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Center(
                                          child: Text(
                                        'Sign Out',
                                        style: TextStyle(fontSize: 21.sp),
                                      )),
                                      Image.asset(
                                        'assets/images/sign-out-icon.png',
                                        height: (screenHeight / 12).h,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onTap: () {
                                AuthService.signOut();
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
}
