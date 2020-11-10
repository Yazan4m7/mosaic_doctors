import 'package:flutter/material.dart';
import 'package:mosaic_doctors/SignIn_with_phone.dart';
import 'package:mosaic_doctors/models/doctor.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/services/DatabaseAPI.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
import 'package:mosaic_doctors/shared/font_styles.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:mosaic_doctors/shared/styles.dart';
import 'package:mosaic_doctors/shared/widgets.dart';
import 'package:mosaic_doctors/views/accountStatement.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
    if (doctor==null){
      getIt<SessionData>().loginWelcomeMessage = "Number not assiocated with a doctor account, please contact MOSAIC";
      print("doc is null");
      AuthService.signOut();
     }
    else {
      doctorName = doctor.name;
      isLoading = false;
      setState(() {

      });
    }
  }

  @override
  void initState() {
    getDoctorData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
    return SafeArea(
        child: MaterialApp(
      theme: GlobalTheme.globalTheme,
      home:  Scaffold(

          key: _scaffoldKey,
          backgroundColor: Colors.white.withOpacity(.97),
          body:isLoading ? Container(child: SpinKitWanderingCubes(color: Colors.black,)) : Column(
            children: [
              SharedWidgets.getAppBarUI(context, _scaffoldKey,"HOME"),
              Image.asset(
                'assets/images/logo_black.png',
                width: 280,
              ),
              Padding(
                  padding: EdgeInsets.all(10),
                  child:Text("د. " + doctorName ,style: MyFontStyles.doctorNameFontStyle(context),)),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                elevation: 8,
                child: InkWell(
                  child: Container(
                    height: screenHeight / 6,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Center(child: Text('Account Statement',style: TextStyle(fontSize: 22),)),
                          Image.asset(
                            'assets/images/account-statement.png',
                            height: screenHeight / 9,
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AccountStatementView()));
                  },
                ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top:5,left:20,right:20),
                child: Card(
                  elevation: 8,
                  child: InkWell(
                    child: Container(
                      height: screenHeight / 6,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25,right:14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Center(child: Text('Sign Out',style: TextStyle(fontSize: 22),)),
                            Image.asset(
                              'assets/images/sign-out-icon.png',
                              height: screenHeight / 9,
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
          )),
    ));
  }
}
