import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mosaic_doctors/models/AccountStatementEntry.dart';
import 'package:mosaic_doctors/models/payment.dart';
import 'package:mosaic_doctors/models/previousMonthBalance.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mosaic_doctors/services/DatabaseAPI.dart';
import 'package:mosaic_doctors/services/notifications.dart';
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
  Future accountStatementEntrys;

  // scroll both header and body togother
  LinkedScrollControllerGroup _scrollControllers;
  ScrollController _titleScrollCont;
  ScrollController _tableScrollCont;

  getAccountStatement() {
    accountStatementEntrys = DatabaseAPI.getDoctorAccountStatement(
        getIt<SessionData>().doctor.id, false);
  }

  @override
  void initState() {
    getAccountStatement();

    _scrollControllers = LinkedScrollControllerGroup();
    _titleScrollCont = _scrollControllers.addAndGet();
    _tableScrollCont = _scrollControllers.addAndGet();

    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    _titleScrollCont.dispose();
    _tableScrollCont.dispose();
    super.dispose();
  }



  final formatter = new NumberFormat("#,###");

  @override
  Widget build(BuildContext context) {
    GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
    double screenHeight = MediaQuery.of(context).size.height;
    double rowWidth = MediaQuery.of(context).size.width - 16; // 16 padding
    double screenWidth = MediaQuery.of(context).size.width; // 16 padding
    print("screenWidth: $screenWidth screenHieght: $screenHeight");
    return Scaffold(
      body: SafeArea(
        key: _scaffoldKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SharedWidgets.getAppBarUI(
                context, _scaffoldKey, "Account Statetment"),
            FutureBuilder(
                future: accountStatementEntrys,
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
                    children: [
                      Container(
                        width: rowWidth,
                        child: Column(
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Column(
                                children: [
                                  Container(
                                    height: screenHeight / 20,
                                    child: Container(
                                      child: SingleChildScrollView(
                                        controller: _titleScrollCont,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: rowWidth / 4.7,
                                              child: Text("Date",
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
                                              child: Text("Payment",
                                                  style: MyFontStyles
                                                      .statementHeaderFontStyle(
                                                          context)),
                                            ),
                                            Container(
                                              alignment: Alignment.center,
                                              width: rowWidth / 5.4,
                                              child: Text("Trans.",
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
                                            SizedBox(
                                              height: 50,
                                            )
                                          ],
                                        ),
                                        scrollDirection: Axis.horizontal,
                                      ),
                                    ),
                                  ),
                                  Divider(),
                                  SingleChildScrollView(
                                    controller: _tableScrollCont,
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      height: screenHeight / 1.58,
                                      width: rowWidth,
                                      child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: accountStatementEntrys
                                              .data.length,
                                          itemBuilder: (context, index) {
                                            print(
                                                "Entrys length : ${accountStatementEntrys.data.length}");

                                            if (accountStatementEntrys
                                                    .data[index]
                                                is AccountStatementEntry) {
                                              AccountStatementEntry ASE =
                                                  accountStatementEntrys
                                                      .data[index];
                                              print(
                                                  "Building entry for ${ASE.toString()}");
                                              return EntryItem(ASE);
                                            }
                                            if (accountStatementEntrys
                                                .data[index] is Payment) {
                                              Payment payment =
                                                  accountStatementEntrys
                                                      .data[index];
                                              print(
                                                  "Building entry for ${payment.toString()}");
                                              return EntryItem(payment);
                                            } else {
                                              PreviousMonthBalance preBalance =
                                                  accountStatementEntrys
                                                      .data[index];
                                              return EntryItem(preBalance);
                                            }
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildBottomCounters(screenHeight, screenWidth)
                    ],
                  );
                }),
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
          height: screenHeight / 13,
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
                                  DatabaseAPI.totals.totalDebit - DatabaseAPI.totals.totalCredit).toString(),
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
            color: Colors.white,
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
            color: Colors.blue,
            textColor: Colors.white,
            splashColor: Colors.blueAccent,
            child: Text("MAKE A PAYMENT", style: TextStyle(fontSize: 18.0)),
            onPressed: () {
              showDialog(
                  context: context,
                  child: new AlertDialog(
                    title: Center(child: new Text("Alert")),
                    content: Container(
                        height: 90,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Payments will be availabe soon! Thank you."),
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
            },
          ),
        )
      ],
    );
  }
}
