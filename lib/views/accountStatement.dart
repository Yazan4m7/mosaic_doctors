import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mosaic_doctors/models/AccountStatementEntry.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/models/statementTotals.dart';
import 'package:mosaic_doctors/services/DatabaseAPI.dart';
import 'package:mosaic_doctors/services/auth_service.dart';
import 'package:mosaic_doctors/services/security.dart';
import 'package:mosaic_doctors/shared/Constants.dart';
import 'package:mosaic_doctors/shared/customDialogBox.dart';
import 'package:mosaic_doctors/shared/font_styles.dart';
import 'package:mosaic_doctors/shared/responsive_helper.dart';
import 'package:mosaic_doctors/shared/test.dart';
import 'package:mosaic_doctors/shared/widgets.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:mosaic_doctors/views/StatementEntry.dart';
import 'package:intl/intl.dart';
import 'package:mosaic_doctors/views/paymentView.dart';
import '../SignIn_with_phone.dart';

class AccountStatementView extends StatefulWidget {
  @override
  _AccountStatementViewState createState() => _AccountStatementViewState();
}

class _AccountStatementViewState extends State<AccountStatementView> {
  // build bottom banner when statement is ready
  bool isStatementReady = false;
  Future accountStatementEntries;
  double roundedBalance = 0;
  List<AccountStatementEntry> pdfTable = new List<AccountStatementEntry>();
  bool isOldestMonth = false;
  Jiffy twoMonthsAgo = Jiffy()..subtract(months: 2);
  bool isNewestMonth = true;
  static Jiffy previousMonth = Jiffy()..subtract(months: 1);
  static Jiffy currentMonth = Jiffy();

  List<PopupMenuEntry<String>> options = [];

  getAccountStatement() {
    accountStatementEntries = DatabaseAPI.getDoctorAccountStatement(
        getIt<SessionData>().doctor.id, false);
  }
  getAccountStatementTotals(currentMonth){
    totals = DatabaseAPI.getAccountStatementTotals(
        currentMonth);
  }
  refreshStatement() {
    accountStatementEntries = DatabaseAPI.getDoctorAccountStatement(
        getIt<SessionData>().doctor.id, true);
    setState(() {});
  }

  checkSession(BuildContext context) async {
    print("checking session in AS Entry");
    if (await Security.checkSession() == SessionStatus.inValid) {
      print("Session is invalid");
      await AuthService.signOut();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false);
    } else
      print("Session is valid.");
  }

  @override
  void initState() {
    getAccountStatement();
    getAccountStatementTotals(currentMonth);
    roundedBalance = 0;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }


  static Future<Null> isRegistering;
  static var completer = new Completer<Null>();
  GlobalKey _scaffoldKey;
  double screenHeight;
  double rowWidth; // 16 padding
  double screenWidth; // 16 padding
  final formatter = new NumberFormat("#,###");
  bool _roundedBalanceBuilt = false;
  bool _accountStatementBuilt = false;
  bool _bottomCountersBuilt = false;
  @override
  Widget build(BuildContext context) {
    print("Built");

    _setMonthsNavigationFlags();
    pdfTable.clear();
    _roundedBalanceBuilt = false;
    _scaffoldKey = GlobalKey<ScaffoldState>();
    screenHeight = MediaQuery.of(context).size.height - 22;
    rowWidth = MediaQuery.of(context).size.width; // 16 padding
    screenWidth = MediaQuery.of(context).size.width;
    print("Screen width : $screenWidth");
    return Scaffold(
      body: SafeArea(
        bottom: true,
        key: _scaffoldKey,
        child: Stack(
          children: [
            Positioned(
              child: Column(children: [
                SharedWidgets.getAppBarUI(
                    context,
                    _scaffoldKey,
                    "Account Statetment ${currentMonth.format("yy-MM")}",
                    PopupMenuButton<String>(
                      onSelected: popupMenuAction,
                      itemBuilder: (BuildContext context) {
                        options.clear();
                        if (!isOldestMonth)
                          options.add(PopupMenuItem(
                            child: Text(
                              "Previous Month",
                              style: TextStyle(color: Colors.grey),
                            ),
                            value: "Previous Month",
                          ));
                        if (!isNewestMonth)
                          options.add(PopupMenuItem(
                              child: Text("Next Month",
                                  style: TextStyle(color: Colors.grey)),
                              value: "Next Month"));
//                        options.add(PopupMenuItem(
//                            child: Text("Save as PDF ",
//                                style: TextStyle(color: Colors.black87)),
//                            value: "SaveAsPDF"));
                        options.add(PopupMenuItem(
                          child: Text(
                            "Refresh",
                            style: TextStyle(color: Colors.black87),
                          ),
                          value: "Refresh",
                        ));
                        options.add(PopupMenuItem(
                          child: Text(
                            "Change font size",
                            style: TextStyle(color: Colors.black87),
                          ),
                          value: "fontSizeChange",
                        ));

                        if (Constants.debuggers.contains(getIt<SessionData>().doctor.phone))  options.add(PopupMenuItem(
                          child: Text(
                            "Debug info",
                            style: TextStyle(color: Colors.black87),
                          ),
                          value: "debugInfo",
                        ));

                        return options;
                      },
                    )),
                _buildAccountStatement()
              ]),
            ),
            _buildBottomCounters(screenHeight, screenWidth)

          ],
        ),
      ),
    );
  }

  Widget _buildAccountStatement() {
    return FutureBuilder(
        future: accountStatementEntries,
        builder: (context, accountStatementEntrys) {
          if (accountStatementEntrys.connectionState ==
              ConnectionState.waiting) {
            return Center(
              child: Container(
                height: screenHeight - 100,
                child: SpinKitWanderingCubes(
                  color: Colors.black,
                ),
              ),
            );
          }

          if (accountStatementEntrys.connectionState == ConnectionState.none) {
            return Center(
                child: Container(
              height: screenHeight - 300,
              width: screenWidth - 100,
              child: Center(
                child: Text(
                  "Failed To Connect, Please check your connection to the internet",
                ),
              ),
            ));
          }

          if (accountStatementEntrys.data == null) {
            return Center(
                child: Container(
              height: screenHeight - 300,
              width: screenWidth - 100,
              child: Center(
                child: Text(
                  "No Cases Found.",
                ),
              ),
            ));
          }
          return Column(
            //mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                width: rowWidth,

                child: Column(
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Column(
                        children: [
                          Container(
                            height: screenHeight / 21,
                            child: Container(
                              child: SingleChildScrollView(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(left: 3),
                                      width: rowWidth / dateCellWidthFactor,
                                      child: Text(" Date",
                                          style: MyFontStyles
                                              .statementHeaderFontStyle(
                                                  context)),
                                    ),
                                    Container(
                                      width: rowWidth / entryCellWidthFactor,
                                      child: Text("Entry",
                                          style: MyFontStyles
                                              .statementHeaderFontStyle(
                                                  context),
                                          textAlign: TextAlign.center),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: 0),
                                      //alignment: Alignment.center,
                                      width: rowWidth / creditCellWidthFactor,
                                      child: Text("Credit",
                                          style: MyFontStyles
                                              .statementHeaderFontStyle(
                                                  context),
                                          textAlign: TextAlign.left),
                                    ),
                                    Container(
                                      width: rowWidth / debitCellWidthFactor,
                                      child: Text("Debit",
                                          style: MyFontStyles
                                              .statementHeaderFontStyle(
                                                  context),
                                          textAlign: TextAlign.left),
                                    ),
                                    Container(
                                      // alignment: Alignment.center,
                                      width: rowWidth / balanceCellWidthFactor,
                                      child: Text("Balance",
                                          style: MyFontStyles
                                              .statementHeaderFontStyle(
                                                  context),
                                          textAlign: TextAlign.left),
                                    ),
                                  ],
                                ),
                                scrollDirection: Axis.horizontal,
                              ),
                            ),
                          ),
                          Divider(),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              height: screenHeight / 1.42,
                              width: rowWidth,
                              child: Padding(
                                padding:
                                    EdgeInsets.only(bottom: screenHeight / 25),
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount:
                                        accountStatementEntrys.data.length,
                                    itemBuilder: (context, index) {
                                      AccountStatementEntry ASE =
                                          accountStatementEntrys.data[index];


                                      //if doctor has no transactions this month, and we're at the latest month, build rounded balance and exit.
                                      if (!DatabaseAPI
                                              .drHasTransactionsThisMonth &&
                                          !_roundedBalanceBuilt &&
                                          (currentMonth.format("yy-MM") ==
                                              Jiffy().format("yy-MM"))) {
                                        index =
                                            accountStatementEntrys.data.length -
                                                1;
                                        pdfTable.add(ASE);

                                        return _buildRoundedBalanceEntry(
                                            accountStatementEntrys.data[
                                                accountStatementEntrys
                                                        .data.length -
                                                    1],
                                            false);
                                      }

                                      if (ASE.createdAt.substring(2, 7) !=
                                          currentMonth.format("yy-MM"))
                                        return SizedBox();
                                      if (!_roundedBalanceBuilt) {

                                        return Column(
                                          children: [
                                            _buildRoundedBalanceEntry(ASE),
                                            EntryItem(ASE)
                                          ],
                                        );
                                      } else {
                                        pdfTable.add(ASE);

//                                        if(index == accountStatementEntrys.data.length-1)
//                                        {_accountStatementBuilt = true;
//                                        if (!_bottomCountersBuilt)
//                                          WidgetsBinding.instance
//                                            .addPostFrameCallback((_) =>  setState(() {
//                                          _bottomCountersBuilt = true;
//                                        }));
//                                        print("Finished building AS");}
                                        return EntryItem(ASE);
                                      }

                                    }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        })
      ;
  }

  Future totals ;
  Widget _buildBottomCounters(double screenHeight, double screenWidth) {
    print("building bottom counters");
    return FutureBuilder(
        future: totals,
        builder: (context, data)
    {
      StatementTotals totalsItem = data.data;
      if(data.data == null) return SizedBox();
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: screenWidth / 8, top: (screenHeight / 12) / 6),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      offset: const Offset(0, -2),
                      blurRadius: 8.0),
                ],
              ),
              height: screenHeight / 12,
              width: screenWidth,
              child: Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Credit: "),
                        Row(
                          children: [
                            Text(formatter.format(totalsItem.totalCredit),
                                style: MyFontStyles.statementHeaderFontStyle(
                                    context)),
                            Text(" JOD")
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Debit: "),
                        Row(
                          children: [
                            Text(formatter.format(totalsItem.totalDebit),
                                style: MyFontStyles.statementHeaderFontStyle(
                                    context),
                                textAlign: TextAlign.left),
                            Text(" JOD", style: TextStyle())
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Balance: "),
                        Row(
                          children: [
                            Text(
                                getIt<SessionData>().doctor.balance == "N/A"
                                    ? "0"
                                    : formatter.format(double.parse(
                                    getIt<SessionData>().doctor.balance)),
                                style:
                                MyFontStyles.statementHeaderFontStyle(context)
                                    .copyWith(
                                  fontSize: Responsiveness.entryFontSize.sp + 3,
                                )),
                            Text(" JOD")
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        offset: const Offset(0, 2),
                        blurRadius: 8.0),
                  ],
                ),
                height: screenHeight / 13,
                width: screenWidth + 16,
                child: FlatButton(
                  textColor: Colors.white,
                  splashColor: Colors.grey,
                  child:
                  Text("MAKE A PAYMENT", style: TextStyle(fontSize: 43.sp)),
                  onPressed: () {
                    SharedWidgets.showMOSAICDialog("Payments will be available soon.",context);
                      //Get.to(PaymentView());
                  },
                ))
          ],
        ),
      );
    });
  }


  Widget _buildRoundedBalanceEntry(AccountStatementEntry ASE,
      [bool isCurrentMonthEntry = true]) {
    double rowWidth = MediaQuery.of(context).size.width ;
    double openingBalance = 0;
    if (isCurrentMonthEntry) {
      print("Current month entry");
      if (ASE.credit != "N/A") {
        print(
            "Opening balance = $openingBalance + ${ASE.credit} = ${double.parse(ASE.balance) + double.parse(ASE.credit)}");
        openingBalance = double.parse(ASE.balance) + double.parse(ASE.credit);
      } else {
        print(
            "Opening balance = $openingBalance - ${ASE.debit} = ${double.parse(ASE.balance) - double.parse(ASE.debit)}");
        openingBalance = double.parse(ASE.balance) - double.parse(ASE.debit);
      }
    } else {
      print("Opening balance = $openingBalance + Nothing");
      openingBalance = double.parse(ASE.balance);
    }
    AccountStatementEntry ASEtoPrint = new AccountStatementEntry(
        patientName: "رصيد مدور",
        createdAt: "N/A",
        credit: "N/A",
        debit: "N/A",
        balance: openingBalance.toString());
    pdfTable.add(ASEtoPrint);
    pdfTable.add(ASE);
    _roundedBalanceBuilt = true;
    return InkWell(
      child: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Row(
          children: [
            Container(
              width: rowWidth / dateCellWidthFactor,
              child: Text(""),
            ),
            Container(
                padding: EdgeInsets.only(right: patientNameRightPadding),
                width: rowWidth / entryCellWidthFactor,
                child: Text("رصيد مدور",
                    style: MyFontStyles.statementPatientNameFontStyle(context)
                        .copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.right)),
            Container(
              width: rowWidth / creditCellWidthFactor,
              child: Text(""),
            ),
            Container(
              width: rowWidth / debitCellWidthFactor,
              child: Text(""),
            ),
            Container(
              padding: EdgeInsets.only(left: cellsLeftPadding),
              width: rowWidth / balanceCellWidthFactor,
              child: Text(openingBalance.toString(),
                  style: MyFontStyles.statementEntryFontStyle(context).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left),
            )
          ],
        ),
      ),
      onTap: () {
        //goBackAMonth();
      },
    );
  }

  goBackAMonth() {
    Jiffy threeMonthsAgo = Jiffy()..subtract(months: 3);
    if (currentMonth.format("yy-MM") == twoMonthsAgo.format("yy-MM")) {
      SharedWidgets.showMOSAICDialog(
          "Sorry, If you wish to view the statement of ${threeMonthsAgo.format("MMMM, yyyy")} Please contact us.",context);
      return;
    }
    try {
      if (Jiffy(DatabaseAPI.firstEntryDate, "yyyy-MM-dd").format("yy-MM") ==
          currentMonth.format("yy-MM")) {
        SharedWidgets.showMOSAICDialog("Sorry, You have no transactions in that month",context);
        return;
      }
    } catch (e) {
      SharedWidgets.showMOSAICDialog("Sorry, You have no transactions in that month",context);
      return;
    }
    setState(() {
      //_bottomCountersBuilt = false;
      _accountStatementBuilt=false;
      _roundedBalanceBuilt=false;
      currentMonth = currentMonth..subtract(months: 1);
    });
  }

  goForwardAMonth() {
    if (currentMonth.format("yy-MM") == Jiffy().format("yy-MM")) {
      SharedWidgets.showMOSAICDialog("Sorry, We can't tell the future",context);
      return;
    }
    setState(() {
      //_bottomCountersBuilt = false;
      _accountStatementBuilt=false;
      _roundedBalanceBuilt=false;
      currentMonth = currentMonth..add(months: 1);
    });
  }

  popupMenuAction(String optionSelected) {
    switch (optionSelected) {
      case "Next Month":
        //goForwardAMonth();
        return SharedWidgets.showMOSAICDialog("Currently unavailable",context);
        break;
      case "Previous Month":
        //goBackAMonth();
        return SharedWidgets.showMOSAICDialog("Currently unavailable",context);
        break;
      case "SaveAsPDF":
        saveAsPDF();
        break;
      case "Refresh":
        refreshStatement();
        break;
      case "fontSizeChange":
        changeFontSize(context);
        break;
      case "debugInfo":
        return SharedWidgets.showMOSAICDialog("Screen width: $screenWidth "
            "Screen Height : $screenHeight,  "
            "Current fonts size : ${Responsiveness.patientNameFontSize} , ${Responsiveness.entryFontSize}",context
            );
        break;
    }
  }

  refreshState(){
  setState(() {

  });
  }



   changeFontSize(BuildContext context){
    showDialog(
        context: context,
        child: new AlertDialog(

          title: Center(child: new Text("Change font size")),
          content:StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                  height: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(

                        children: [
                          IconButton(icon: Icon(Icons.add_circle_outline_sharp ), onPressed:Responsiveness.patientNameFontSize ==48 ? (){} : (){ setState(() {

                            Responsiveness.increaseSize(); });},color:Responsiveness.patientNameFontSize ==48 ?Colors.grey: Colors.black87 ),
                          Text( Responsiveness.entryFontSize.toString()),
                          IconButton(icon: Icon(Icons.remove_circle_outline_sharp), onPressed:Responsiveness.patientNameFontSize ==28 ? (){} :(){setState(() { Responsiveness.decreaseSize();});}
                          ,color:Responsiveness.patientNameFontSize ==28 ?Colors.grey: Colors.black87 ,),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      RaisedButton(
                        child: Text(
                          "Ok",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop('dialog');

                          refreshState();

                        },
                      )
                    ],
                  ));

            })
        ));
  }

  _setMonthsNavigationFlags() {
    if (currentMonth.format("yy-MM") == Jiffy().format("yy-MM"))
      setState(() {
        isNewestMonth = true;
      });
    else
      setState(() {
        isNewestMonth = false;
      });
    if (currentMonth.format("yy-MM") == twoMonthsAgo.format("yy-MM"))
      setState(() {
        isOldestMonth = true;
      });
    else
      setState(() {
        isOldestMonth = false;
      });
  }

  saveAsPDF() async {
    Exporting.reportView(context, pdfTable, currentMonth);
//    pw.Widget printMe = pw.Column(children: [
//
//
//    ]);
//
//    final pdf = pw.Document();
//    var data = await rootBundle.load("assets/fonts/DroidKufi-Regular.ttf");
//    pdf.addPage(pw.Page(
//        pageFormat: PdfPageFormat.a4,
//        build: (pw.Context context) {
//          return pw.Center(
//            child: printMe
//          ); // Center
//        })); // Page
//    Directory tempDir = await getExternalStorageDirectory();
//    File file = File("${tempDir.path}/MOSAIC.pdf");
//    print("file created");
//    await file.writeAsBytes(pdf.save());
//    print("file written");
//    file.open();
//    print("file opened");
//    print(file.path);
  }
}
