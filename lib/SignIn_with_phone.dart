import 'dart:async';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:mosaic_doctors/shared/styles.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Timer _timer;
  int _start = 30;
  bool _sendCodeEnabled = true;
  bool _keyboardVisible = false;
  void startTimer() {
    const oneSec = const Duration(seconds: 1);

    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _sendCodeEnabled = false;
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    if(_timer !=null)
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        setState(() {
          _keyboardVisible = !_keyboardVisible;
        });
        if (visible)
          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent + 150,
              duration: Duration(milliseconds:600),
              curve: Curves.easeInCirc);
      },
    );
    super.initState();
  }

  String phoneNo, verificationId, smsCode;
  TextEditingController phoneNoTxtController = TextEditingController();
  TextEditingController smsCodeTxtController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool codeSent = false;
  GlobalKey formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
   // print(MediaQuery.of(context).viewInsets.bottom);
    double screenHeight = MediaQuery.of(context).size.height;
    //double screenWidth = MediaQuery.of(context).size.width;
    return MaterialApp(
      theme: GlobalTheme.globalTheme,
      home:Scaffold (
        resizeToAvoidBottomPadding: false,
//        resizeToAvoidBottomInset: false,

        body: Container(
          height: screenHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Color(0xffc3c3c3), Colors.white30]),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: _keyboardVisible? -325 : -100- (MediaQuery.of(context).viewInsets.bottom*-1),
                right: -110,
                child: Container(
                  alignment: Alignment(2.5, 5),
                  child: Image.asset(
                    'assets/images/logo_transaperant.png',
                    height: 600,
                  ),
                ),
              ),
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    Form(
                        key: formKey,
                        child: Column(

                          children: <Widget>[
                            Column(
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: screenHeight / 12,
                                ),
                                Image.asset(
                                  'assets/images/logo_black_vertical.png',
                                  width: 300,
                                ),
                                Divider(),
                                Padding(
                                  padding:  EdgeInsets.only(left: 50.0, right: 50.0),
                                  child: Text(
                                    getIt<SessionData>().loginWelcomeMessage,
                                    style: TextStyle(color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                    padding:
                                        EdgeInsets.only(left: 30.0, right: 30.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: TextFormField(
                                              enabled: false,
                                              decoration:
                                                  InputDecoration( prefixIcon: const Icon(
                                                    Icons.phone,
                                                    color: Colors.black87,
                                                  ),hintText: '+962',),
                                            )),
                                        Expanded(
                                          flex: 7,
                                          child: TextFormField(

                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(

                                                hintText: 'Phone number'),
                                            controller: phoneNoTxtController,
                                          ),
                                        ),
                                      ],
                                    )),
                                codeSent
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            left: 50.0, right: 50.0),
                                        child: TextFormField(
                                          keyboardType: TextInputType.phone,
                                          decoration:
                                              InputDecoration(hintText: 'OTP code'),
                                          controller: smsCodeTxtController,
                                        ))
                                    : Container(),
                                Padding(
                                    padding:
                                        EdgeInsets.only(left: 50.0, right: 50.0),
                                    child: _buildButton(
                                        codeSent ? 'LOG IN' : 'SEND CODE', () {
                                      if (codeSent) {
                                        AuthService().signInWithOTP(
                                            '+962'+phoneNoTxtController.text,
                                            smsCodeTxtController.text,
                                            verificationId);
                                      } else {
                                        startTimer();
                                        verifyPhone('+962'+phoneNoTxtController.text);
                                      }
                                    })),
                                codeSent
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            left: 70.0, right: 70.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              "Didnt recieve the code ? please allow $_start seconds and re-send",
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black),
                                            ),
                                            !_sendCodeEnabled
                                                ? RaisedButton(
                                                    child: Center(
                                                        child:
                                                            Text('RE-SEND CODE')),
                                                    onPressed: () {
                                                      verifyPhone(
                                                         "+962"+ phoneNoTxtController
                                                              .text);
                                                      startTimer();
                                                    })
                                                : RaisedButton(
                                                    child: Center(
                                                        child:
                                                            Text('RE-SEND CODE')))
                                          ],
                                        ))
                                    : SizedBox(),
                              ],
                            ),
                          ],
                        )),
//                    _keyboardVisible
//                        ? SizedBox(height: MediaQuery.of(context).viewInsets.bottom)
//                        : SizedBox()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> verifyPhone(phoneNo) async {
    if (phoneNo == '') {
      showDialog(
          context: context,
          child: new AlertDialog(
            title: Center(child: new Text("Error")),
            content: Container(
                height: 90,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Invalid or empty phone number"),
                    RaisedButton(
                      child: Text(
                        "Ok",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                )),
          ));
      return;
    }
    final PhoneVerificationCompleted verified = (AuthCredential authResult) {
      AuthService().signIn(authResult);
    };

    final PhoneVerificationFailed verificationfailed =
        (AuthException authException) {
      showDialog(
          context: context,
          child: new AlertDialog(
            title: Center(child: new Text("Error ")),
            content: Container(
                height: 90,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        "Invalid phone number, if error persists please try again later. ${authException.message}"),
                    RaisedButton(
                      child: Text(
                        "Ok",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                )),
          ));
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

  _buildButton(String text, Function onPress) {
    return Container(
      height: 50.0,
      margin: EdgeInsets.all(10),
      child: RaisedButton(
        onPressed: onPress,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: EdgeInsets.all(0.0),
        child: Ink(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff3A3A3A), Color(0xff181818)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(30.0)),
          child: Container(
            constraints: BoxConstraints(maxWidth: 250.0, minHeight: 50.0),
            alignment: Alignment.center,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

}
