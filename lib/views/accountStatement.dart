import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mosaic_doctors/models/AccountStatementEntry.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/services/DatabaseAPI.dart';
import 'package:mosaic_doctors/shared/customDialogBox.dart';
import 'package:mosaic_doctors/shared/font_styles.dart';
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
  double roundedBalance=0;

  bool isOldestMonth=false;
  Jiffy twoMonthsAgo = Jiffy()..subtract(months: 2);
  bool isNewestMonth = true;
  static Jiffy previousMonth = Jiffy()..subtract(months: 1);
  static Jiffy currentMonth = Jiffy();

  List<PopupMenuEntry<String>> options=List<PopupMenuEntry<String>>() ;
  getAccountStatement() {
    accountStatementEntries = DatabaseAPI.getDoctorAccountStatement(
        getIt<SessionData>().doctor.id, false);
  }

  @override
  void initState() {
    getAccountStatement();
    roundedBalance=0;

    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }




  final formatter = new NumberFormat("#,###");
  bool _roundedBalanceBuilt=false;

  @override
  Widget build(BuildContext context) {
    _setMonthsNavigationFlags();

    _roundedBalanceBuilt = false;
    GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
    double screenHeight = MediaQuery.of(context).size.height-22;
    double rowWidth = MediaQuery.of(context).size.width ; // 16 padding
    double screenWidth = MediaQuery.of(context).size.width; // 16 padding

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

              child: Column(

          children: [ SharedWidgets.getAppBarUI(
                context, _scaffoldKey, "Account Statetment ${currentMonth.format("yy-MM")}",
                PopupMenuButton<String>(
                  onSelected: changeMonth,
                  itemBuilder: (BuildContext context){
                    options.clear();
                    if(!isOldestMonth)options.add(PopupMenuItem(child: Text("Previous Month",style: TextStyle(color: Colors.grey),),value: "Previous Month",));
                    if(!isNewestMonth)options.add(PopupMenuItem(child: Text("Next Month",style: TextStyle(color: Colors.grey)),value: "Next Month"));
                    return options;
                  },
                )
          ),
              FutureBuilder(
                  future: accountStatementEntries,
                  builder: (context, accountStatementEntrys) {
                    if (accountStatementEntrys.connectionState ==
                        ConnectionState.none ||
                        accountStatementEntrys.connectionState ==
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
                    if (accountStatementEntrys.data == null) {
                      return Center(
                          child: Text(
                            "No Entrys",
                          ));
                    }

                    return Column(

                      mainAxisSize: MainAxisSize.min,

                      children: [
                        Container(
                          width: rowWidth,

                          child: Column(
                            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [

                              Padding(
                                padding: const EdgeInsets.only(top:5),
                                child: Column(
                                  children: [
                                    Container(
                                      height: screenHeight / 20,
                                      child: Container(

                                        child: SingleChildScrollView(

                                          child: Row(
                                            children: [
                                              Container(


                                                width: rowWidth / 4.7,
                                                child: Text(" Date",
                                                    style: MyFontStyles
                                                        .statementHeaderFontStyle(
                                                        context)),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                width: rowWidth / 4,
                                                child: Text("Entry",
                                                    style: MyFontStyles
                                                        .statementHeaderFontStyle(
                                                        context)),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                width: rowWidth / 5.4,
                                                child: Text("Credit",
                                                    style: MyFontStyles
                                                        .statementHeaderFontStyle(
                                                        context)),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                width: rowWidth / 5.4,
                                                child: Text("Debit",
                                                    style: MyFontStyles
                                                        .statementHeaderFontStyle(
                                                        context)),
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                width: rowWidth / 6,
                                                child: Text("Balance",
                                                    style: MyFontStyles
                                                        .statementHeaderFontStyle(
                                                        context)),
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
                                              if(!DatabaseAPI.drHasTransactionsThisMonth && !_roundedBalanceBuilt &&(currentMonth.format("yy-MM") == Jiffy().format("yy-MM")) ) {
                                                print("doctor has no trans this month");
                                                index= accountStatementEntrys
                                                    .data.length-1;
                                                return _buildRoundedBalanceEntry(accountStatementEntrys
                                                    .data[accountStatementEntrys
                                                    .data.length-1],false);}

                                              print(ASE.createdAt.substring(2, 7) + "current "+currentMonth.format("yy-MM") );
                                              if(ASE.createdAt.substring(2, 7) != currentMonth.format("yy-MM")) return SizedBox();
                                              if(!_roundedBalanceBuilt) return Column(children: [_buildRoundedBalanceEntry(ASE),EntryItem(ASE)],) ;
                                              else return EntryItem(ASE);

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
                  }),]),
            ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FutureBuilder(
                future: accountStatementEntries,
                builder: (context, accountStatementEntrys) {
              return _buildBottomCounters(screenHeight, screenWidth); }),
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
          child: Padding(
            padding: EdgeInsets.only(
                left: (screenWidth + 16) / 10, top: (screenHeight / 13) / 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Column(
                    children: [
                      Text("Debit: "),
                      Row(
                        children: [
                          Text(formatter.format(DatabaseAPI.totals.totalDebit),
                              style: MyFontStyles.statementHeaderFontStyle(
                                  context)),
                          Text(" JOD", style: TextStyle())
                        ],
                      ),
                    ],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Credit: "),
                      Row(
                        children: [
                          Text(formatter.format(DatabaseAPI.totals.totalCredit),
                              style: MyFontStyles.statementHeaderFontStyle(
                                  context)),
                          Text(" JOD")
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Balance: "),
                      Row(
                        children: [
                          Text(
                              formatter.format(
                                  double.parse(getIt<SessionData>().doctor.balance)),
                              style:
                                  MyFontStyles.statementHeaderFontStyle(context)
                                      .copyWith(fontSize: 20)),
                          Text(" JOD")
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color:Colors.black87,
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  offset: const Offset(0, 2),
                  blurRadius: 8.0),
            ],
          ),
          height: screenHeight / 13,
          width: screenWidth + 16,
          child:
            FlatButton(

              textColor: Colors.white,
              splashColor: Colors.blueAccent,
              child: Text("MAKE A PAYMENT", style: TextStyle(fontSize: 18.sp)),
              onPressed: () {
               showMOSAICDialog("Payments will be available soon, Thank you for your interest.");

              },
            )
        )
      ],
    );
  }

  addToRoundedBalance(AccountStatementEntry entry){

    if(entry.debit !="N/A"){
      print("Rounded balance $roundedBalance - ${entry} = ${roundedBalance-double.parse(entry.debit)}");
      roundedBalance += double.parse(entry.debit);
    }
    else{
      print("Rounded balance $roundedBalance + ${entry} = ${roundedBalance-double.parse(entry.credit)}");
      roundedBalance -= double.parse(entry.credit);
  }
  }




  Widget _buildRoundedBalanceEntry(AccountStatementEntry ASE , [bool isCurrentMonthEntry = true]) {
    double rowWidth = MediaQuery.of(context).size.width ;
    double openingBalance=0;
    if(isCurrentMonthEntry)
    if (ASE.credit !="N/A") openingBalance = double.parse(ASE.balance) + double.parse(ASE.credit);
    else  openingBalance = double.parse(ASE.balance) - double.parse(ASE.debit)  ;
    else{
      openingBalance = double.parse(ASE.balance)   ;
    }

    _roundedBalanceBuilt = true;
    return  InkWell(
      child: Container(
        decoration:
        BoxDecoration(color: Colors.transparent),

        child: Row(
          children: [
            Container(
              width: rowWidth / 4.7,
              child: Text(""
              ),
            ),
            Container(
              padding: EdgeInsets.only(left :rowWidth / 5 / 10),
              width: rowWidth / 4.0,
              child: Text("رصيد مدور",
                style: MyFontStyles.statementPatientNameFontStyle(context),
              textAlign: TextAlign.right,)
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: rowWidth / 5 / 5),
              width: rowWidth / 5.4,
              child: Text(""



              ),
            ),
            Container(
              padding: EdgeInsets.only(left :rowWidth / 5 / 5),
              width: rowWidth / 5.4,
              child: Text( ""
              ),
            ),
            Container(
              padding: EdgeInsets.only(left :rowWidth / 5 / 10),
              width: rowWidth / 6,
              child: Text(openingBalance.toString(),
                style:
                MyFontStyles.statementEntryFontStyle(context),
                textAlign: TextAlign.left,
              ),
            )
          ],
        ),
      ),
      onTap: () {
        //goBackAMonth();

      },
    );

  }
  goBackAMonth(){

    Jiffy threeMonthsAgo = Jiffy()..subtract(months: 3);
    if (currentMonth.format("yy-MM") ==  twoMonthsAgo.format("yy-MM")){
      showMOSAICDialog("Sorry, If you wish to view the statement of ${threeMonthsAgo.format("MMMM, yyyy")} Please contact us.");
      return;}
    print(Jiffy(DatabaseAPI.firstEntryDate, "yyyy-MM-dd").format("yy-MM") + "===" +currentMonth.format("yy-MM"));
    if(Jiffy(DatabaseAPI.firstEntryDate, "yyyy-MM-dd").format("yy-MM") == currentMonth.format("yy-MM")){
    showMOSAICDialog("Sorry, You have no transactions in that month");
    return;}
    setState(() {

      currentMonth = currentMonth
        ..subtract(months: 1);
    });

  }
  goForwardAMonth(){
if (currentMonth.format("yy-MM") == Jiffy().format("yy-MM")){
  showMOSAICDialog("Sorry, We can't tell the future");
  return;}
    setState(() {
      currentMonth = currentMonth
        ..add(months: 1);
    });

  }
  changeMonth(String optionSelected){
    return showMOSAICDialog("Currently unavailable");
    switch(optionSelected){
      case "Next Month" :goForwardAMonth();break;
      case "Previous Month" :goBackAMonth();break;
    }

  }
  Widget showMOSAICDialog(String text){
    showDialog(context: context,
        builder: (BuildContext context){
          return CustomDialogBox(title:"Alert",descriptions: text,text: "Ok",
          );
        }
    );


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
  _setMonthsNavigationFlags(){
    if (currentMonth.format("yy-MM") == Jiffy().format("yy-MM"))
     setState(() {isNewestMonth = true; });
    else
      setState(() {isNewestMonth = false; });
    if (currentMonth.format("yy-MM") ==  twoMonthsAgo.format("yy-MM"))
      setState(() {isOldestMonth =true; });
      else
      setState(() {isOldestMonth =false; });

  }
}
