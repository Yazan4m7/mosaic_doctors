import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mosaic_doctors/models/AccountStatementEntry.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/models/statementTotals.dart';
import 'package:mosaic_doctors/services/DatabaseAPI.dart';
import 'package:mosaic_doctors/shared/Constants.dart';
import 'package:mosaic_doctors/shared/customDialogBox.dart';
import 'package:mosaic_doctors/shared/font_styles.dart';
import 'package:mosaic_doctors/shared/responsive_helper.dart';
import 'package:mosaic_doctors/shared/test.dart';
import 'package:mosaic_doctors/shared/widgets.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:mosaic_doctors/views/StatementEntry.dart';
import 'package:intl/intl.dart';


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
  StatementTotals totals = new StatementTotals();
  List<PopupMenuEntry<String>> options = List<PopupMenuEntry<String>>();

  getAccountStatement() {
    accountStatementEntries = DatabaseAPI.getDoctorAccountStatement(
        getIt<SessionData>().doctor.id, false);
  }

  @override
  void initState() {
    getAccountStatement();
    roundedBalance = 0;

    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  GlobalKey _scaffoldKey;
  double screenHeight;
  double rowWidth; // 16 padding
  double screenWidth; // 16 padding

  final formatter = new NumberFormat("#,###");
  bool _roundedBalanceBuilt = false;

  @override
  Widget build(BuildContext context) {
    _setMonthsNavigationFlags();
    pdfTable.clear();
    _roundedBalanceBuilt = false;
    _scaffoldKey = GlobalKey<ScaffoldState>();
    screenHeight = MediaQuery.of(context).size.height - 22;
    rowWidth = MediaQuery.of(context).size.width; // 16 padding
    screenWidth = MediaQuery.of(context).size.width; // 16 padding

    return Scaffold(
//      floatingActionButton:  Padding(
//        padding: const EdgeInsets.only(bottom: 50.0),
//        child: FloatingActionButton.extended(
//          backgroundColor: Colors.black87,
//          onPressed: () {showMOSAICDialog("Sorry, Payments are currently unavailable, Thank you for your interest");},
//          icon: Icon(Icons.payment),
//          label: Text("MAKE A PAYMENT"),
//
//        ),
//      ),
      body: SafeArea(
        bottom: true,
        key: _scaffoldKey,
        child: Stack(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        return options;
                      },
                    )),
                FutureBuilder(
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

                      if (accountStatementEntrys.data == null ||
                          accountStatementEntrys.connectionState ==
                              ConnectionState.none) {
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


                      return Column(
                        //mainAxisSize: MainAxisSize.min,

                        children: [
                          Container(
                            width: rowWidth - 16,
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: screenHeight / 20,
                                        child: Container(
                                          child: SingleChildScrollView(
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: rowWidth /
                                                      dateCellWidthFactor,
                                                  child: Text(" Date",
                                                      style: MyFontStyles
                                                          .statementHeaderFontStyle(
                                                              context)),
                                                ),
                                                Container(
                                                  width: rowWidth /
                                                      entryCellWidthFactor,
                                                  child: Text("Entry",
                                                      style: MyFontStyles
                                                          .statementHeaderFontStyle(
                                                              context),
                                                      textAlign:
                                                          TextAlign.center),
                                                ),
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(left: 5),
                                                  //alignment: Alignment.center,
                                                  width: rowWidth /
                                                      creditCellWidthFactor,
                                                  child: Text("Credit",
                                                      style: MyFontStyles
                                                          .statementHeaderFontStyle(
                                                              context),
                                                      textAlign:
                                                          TextAlign.left),
                                                ),
                                                Container(
                                                  width: rowWidth /
                                                      debitCellWidthFactor,
                                                  child: Text("Debit",
                                                      style: MyFontStyles
                                                          .statementHeaderFontStyle(
                                                              context),
                                                      textAlign:
                                                          TextAlign.left),
                                                ),
                                                Container(
                                                  // alignment: Alignment.center,
                                                  width: rowWidth /
                                                      balanceCellWidthFactor,
                                                  child: Text("Balance",
                                                      style: MyFontStyles
                                                          .statementHeaderFontStyle(
                                                              context),
                                                      textAlign:
                                                          TextAlign.left),
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
                                          height: screenHeight / 1.48,
                                          width: rowWidth,
                                          child: ListView.builder(
                                              scrollDirection: Axis.vertical,
                                              itemCount: accountStatementEntrys
                                                  .data.length,
                                              itemBuilder: (context, index) {
                                                AccountStatementEntry ASE =
                                                    accountStatementEntrys
                                                        .data[index];


                                                //if doctor has no transactions this month, and we're at the latest month, build rounded balance and exit.
                                                if (!DatabaseAPI
                                                        .drHasTransactionsThisMonth &&
                                                    !_roundedBalanceBuilt &&
                                                    (currentMonth
                                                            .format("yy-MM") ==
                                                        Jiffy()
                                                            .format("yy-MM"))) {
                                                  index = accountStatementEntrys
                                                          .data.length -
                                                      1;
                                                  pdfTable.add(ASE);
                                                  return _buildRoundedBalanceEntry(
                                                      accountStatementEntrys
                                                              .data[
                                                          accountStatementEntrys
                                                                  .data.length -
                                                              1],
                                                      false);
                                                }


                                                if (ASE.createdAt.substring(2, 7) !=
                                                    currentMonth
                                                        .format("yy-MM"))
                                                  return SizedBox();
                                                if (!_roundedBalanceBuilt){
                                                  _addToTotals(ASE);
                                                  return Column(
                                                    children: [
                                                      _buildRoundedBalanceEntry(
                                                          ASE),
                                                      EntryItem(ASE)
                                                    ],
                                                  );}
                                                else{
                                                  pdfTable.add(ASE);
                                                  return EntryItem(ASE);}
                                              }),
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
                    }),
              ]),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FutureBuilder(
                  future: accountStatementEntries,
                  builder: (context, accountStatementEntrys) {
                    return _buildBottomCounters(screenHeight, screenWidth);
                  }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCounters(double screenHeight, double screenWidth) {
    return Column(
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
                        Text(formatter.format(DatabaseAPI.totals.totalCredit),
                            style:
                            MyFontStyles.statementHeaderFontStyle(context)),
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
                        Text( addBracketsIfNegative(formatter.format(DatabaseAPI.totals.totalDebit)),
                            style:
                                MyFontStyles.statementHeaderFontStyle(context),
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
                            addBracketsIfNegative(formatter.format(double.parse(getIt<SessionData>().doctor.balance))),
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
              splashColor: Colors.blueAccent,
              child: Text("MAKE A PAYMENT", style: TextStyle(fontSize: 20.sp)),
              onPressed: () {
                showMOSAICDialog(
                    "Payments will be available soon, Thank you for your interest.");
              },
            ))
      ],
    );
  }

  _addToTotals(AccountStatementEntry ASE){
    if(ASE.credit != "N/A") totals.totalCredit += double.parse(ASE.credit);
    else
        totals.totalDebit += double.parse(ASE.debit);



  }


  Widget _buildRoundedBalanceEntry(AccountStatementEntry ASE,
      [bool isCurrentMonthEntry = true]) {
    double rowWidth = MediaQuery
        .of(context)
        .size
        .width - 16;
    double openingBalance = 0;
    if (isCurrentMonthEntry) {
      print("Current month entry");
      if (ASE.credit != "N/A") {
        print("Opening balance = $openingBalance + ${ASE.credit} = ${double.parse(ASE.balance) + double.parse(ASE.credit)}");
        openingBalance = double.parse(ASE.balance) + double.parse(ASE.credit);

      }else{
        print("Opening balance = $openingBalance - ${ASE.debit} = ${double.parse(ASE.balance) - double.parse(ASE.debit)}");
      openingBalance = double.parse(ASE.balance) - double.parse(ASE.debit);}}
    else {
      print("Opening balance = $openingBalance + Nothing");
      openingBalance = double.parse(ASE.balance);
    }
    AccountStatementEntry ASEtoPrint = new AccountStatementEntry(patientName: "رصيد مدور",createdAt: "N/A",credit: "N/A",debit: "N/A", balance: openingBalance.toString());
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
                width: rowWidth / entryCellWidthFactor,
                child: Text(
                  "رصيد مدور",
                  style: MyFontStyles.statementPatientNameFontStyle(context)
                      .copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.right
                    ,textScaleFactor:1.0
                )),
            Container(
              width: rowWidth / creditCellWidthFactor,
              child: Text(""),
            ),
            Container(
              width: rowWidth / debitCellWidthFactor,
              child: Text(""),
            ),
            Container(
              padding: EdgeInsets.only(left: 15),
              width: rowWidth / balanceCellWidthFactor,
              child: Text(
                addBracketsIfNegative(openingBalance.toString()),
                style: MyFontStyles.statementEntryFontStyle(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.left
                  ,textScaleFactor:1.0),
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
//    if (currentMonth.format("yy") == "21" &&currentMonth.format("MM") == "01" ) {
//      showMOSAICDialog(
//          "Sorry, Account statements of previous year is only available through MOSAIC. Please contact us.");
//      return;
//    }
    if (currentMonth.format("yy-MM") == twoMonthsAgo.format("yy-MM")) {
      showMOSAICDialog(
          "Sorry, If you wish to view the statement of ${threeMonthsAgo.format("MMMM, yyyy")} Please contact us.");
      return;
    }
    if (Jiffy(DatabaseAPI.firstEntryDate, "yyyy-MM-dd").format("yy-MM") ==
        currentMonth.format("yy-MM")) {
      showMOSAICDialog("Sorry, You have no transactions in that month");
      return;
    }
    setState(() {
      currentMonth = currentMonth..subtract(months: 1);
    });
  }

  goForwardAMonth() {
    if (currentMonth.format("yy-MM") == Jiffy().format("yy-MM")) {
      showMOSAICDialog("Sorry, We can't tell the future");
      return;
    }
    setState(() {
      currentMonth = currentMonth..add(months: 1);
    });
  }

  popupMenuAction(String optionSelected) {
    return showMOSAICDialog("Currently unavailable");
    switch (optionSelected) {
      case "Next Month":
        goForwardAMonth();
        break;
      case "Previous Month":
        goBackAMonth();
        break;
      case "SaveAsPDF":
        saveAsPDF();
        break;
    }
  }

  Widget showMOSAICDialog(String text) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
            title: "Alert",
            descriptions: text,
            text: "Ok",
          );
        });

//    showDialog(
//                    context: context,
//                    child: new AlertDialog(
//                      title: Center(child: new Text("Alert")),
//                      content: Container(
//                          height: 120,
//                          child: Column(
//                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                            crossAxisAlignment: CrossAxisAlignment.center,
//                            children: [
//                              Text(text),
//                              RaisedButton(
//                                child: Text(
//                                  "Ok",
//                                  style: TextStyle(color: Colors.white),
//                                ),
//                                color: Colors.blue,
//                                onPressed: () {
//                                  Navigator.pop(context);
//                                },
//                              )
//                            ],
//                          )),
//                    ));
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

  addBracketsIfNegative(String number) {
    double num;
    try {
      if (number[0] == "-") {
        number.replaceAll("-", "");
        return ("($number)");
      }
      else
        return number;
    }catch(e){
      return number;
    }
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
