import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:mosaic_doctors/shared/styles.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String phoneNo, verificationId, smsCode;
  TextEditingController phoneNoTxtController = TextEditingController();
  TextEditingController smsCodeTxtController = TextEditingController();
  bool codeSent = false;
  GlobalKey formKey =  GlobalKey();
  @override
  Widget build(BuildContext context) {
    double screenHeight =MediaQuery.of(context).size.height;

    return MaterialApp(
      theme: GlobalTheme.globalTheme,
      home: Scaffold(

        body: SingleChildScrollView(

          child: Form(
              key: formKey,
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                   Column(
                     //mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       SizedBox(height: screenHeight/12,),
                     Padding(
                       padding: const EdgeInsets.only(bottom: 0),
                       child: Image.asset(
                         'assets/images/logo_black_vertical.png',
                         width: 300,
                       ),
                     ),
                     Divider(),
                     Padding(
                       padding: const EdgeInsets.all(12.0),
                       child: Text( getIt<SessionData>().loginWelcomeMessage,style: TextStyle(color:Colors.red),textAlign: TextAlign.center,),
                     ),
                     Padding(
                         padding: EdgeInsets.only(left: 50.0, right: 50.0),
                         child: TextFormField(
                           keyboardType: TextInputType.phone,
                           decoration: InputDecoration(hintText: 'Phone number'),
                           controller: phoneNoTxtController,
                         )),
                     codeSent ? Padding(
                         padding: EdgeInsets.only(left: 50.0, right: 50.0),
                         child: TextFormField(
                           keyboardType: TextInputType.phone,
                           decoration: InputDecoration(hintText: 'OTP code'),
                           controller: smsCodeTxtController,
                         )) : Container(),
                     Padding(
                         padding: EdgeInsets.only(left: 50.0, right: 50.0),
                         child: RaisedButton(
                             child: Center(child: codeSent ? Text('LOG IN'):Text('SEND CODE')),
                             onPressed: () {
                               codeSent ? AuthService().signInWithOTP(phoneNoTxtController.text,smsCodeTxtController.text, verificationId):verifyPhone(phoneNoTxtController.text);
                             }))

                   ],)
                ],
              )),
        ),
      ),
    );
  }

  Future<void> verifyPhone(phoneNo) async {
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      AuthService().signIn(authResult);
    };

    final PhoneVerificationFailed verificationfailed =
        (AuthException authException) {
      print('${authException.message}');
    };

    final PhoneCodeSent smsSent = (String verId, [int forceResend]) {
      this.verificationId = verId;
      setState(() {
        this.codeSent = true;
      });
    };

    final PhoneCodeAutoRetrievalTimeout autoTimeout = (String verId) {
      this.verificationId = verId;
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNo,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verified,
        verificationFailed: verificationfailed,
        codeSent: smsSent,
        codeAutoRetrievalTimeout: autoTimeout);
  }
}