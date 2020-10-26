import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
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

  @override
  Widget build(BuildContext context) {
    GlobalKey formKey =  GlobalKey();
    return MaterialApp(
      theme: GlobalTheme.globalTheme,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Padding(
                      padding: EdgeInsets.only(left: 50.0, right: 50.0),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(hintText: 'رقم الهاتف'),
                        controller: phoneNoTxtController,
                      )),
                  codeSent ? Padding(
                      padding: EdgeInsets.only(left: 50.0, right: 50.0),
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(hintText: 'رمز التحقق'),
                        controller: smsCodeTxtController,
                      )) : Container(),
                  Padding(
                      padding: EdgeInsets.only(left: 50.0, right: 50.0),
                      child: RaisedButton(
                          child: Center(child: codeSent ? Text('تسجيل الدخول'):Text('أرسل')),
                          onPressed: () {
                            codeSent ? AuthService().signInWithOTP(phoneNoTxtController.text,smsCodeTxtController.text, verificationId):verifyPhone(phoneNoTxtController.text);
                          }))
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