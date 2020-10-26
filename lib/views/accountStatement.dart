import 'package:flutter/material.dart';
import 'package:mosaic_doctors/models/AccountStatementEntry.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mosaic_doctors/services/DatabaseAPI.dart';
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
  bool isStatementReady = false;
  Future accountStatementEntrys;
  LinkedScrollControllerGroup _scrollControllers;
  ScrollController _titleScrollCont;
  ScrollController _tableScrollCont;

  getAccountStatement() async {
    accountStatementEntrys =
        DatabaseAPI.getDoctorAccountStatement(getIt<SessionData>().doctor.id);
  }

  @override
  void initState() {
    getAccountStatement();
    _scrollControllers = LinkedScrollControllerGroup();
    _titleScrollCont = _scrollControllers.addAndGet();
    _tableScrollCont = _scrollControllers.addAndGet();
    isStatementReady = true;
    setState(() {});
    super.initState();
  }

  @override
  void dispose() {
    _titleScrollCont.dispose();
    _tableScrollCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = new NumberFormat("#,###");

    GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
    double screenHeight = MediaQuery.of(context).size.height;
    double rowWidth = MediaQuery.of(context).size.width * 1.3; // 16 padding
    double screenWidth = MediaQuery.of(context).size.width - 16; // 16 padding
    print("width of header : $rowWidth");
    return Scaffold(
      body: SafeArea(
        key: _scaffoldKey,
        child: Column(
          children: [
            SharedWidgets.getAppBarUI(
                context, _scaffoldKey, "Account Statetment"),
            Container(
              width: rowWidth - 20,
              child: FutureBuilder(
                  future: accountStatementEntrys,
                  builder: (context, accountStatementEntrys) {
                    if (accountStatementEntrys.connectionState ==
                            ConnectionState.none ||
                        accountStatementEntrys.connectionState ==
                            ConnectionState.waiting) {
                      return Center(
                          child: SharedWidgets.loadingCircle('Loading'));
                    }
                    if (accountStatementEntrys.data == null) {
                      return Center(
                          child: Text(
                        "No Entrys",
                      ));
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
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
                                          width: rowWidth / 5,
                                          child: Text("Date",
                                              style: MyFontStyles
                                                  .statementHeaderFontStyle(
                                                      context)),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: rowWidth / 5,
                                          child: Text("Entry",
                                              style: MyFontStyles
                                                  .statementHeaderFontStyle(
                                                      context)),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: rowWidth / 5,
                                          child: Text("Credit",
                                              style: MyFontStyles
                                                  .statementHeaderFontStyle(
                                                      context)),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: rowWidth / 5,
                                          child: Text("Debit",
                                              style: MyFontStyles
                                                  .statementHeaderFontStyle(
                                                      context)),
                                        ),
                                        Container(
                                          alignment: Alignment.center,
                                          width: rowWidth / 5,
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
                                  height: screenHeight / 1.45,
                                  width: rowWidth,
                                  child: ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      itemCount:
                                          accountStatementEntrys.data.length,
                                      itemBuilder: (context, index) {
                                        AccountStatementEntry ASE =
                                            accountStatementEntrys.data[index];

                                        return EntryItem(ASE);
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                          width: screenWidth + 16,
                          child: Row(

                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(

                                padding: EdgeInsets.only(
                                    top: screenHeight / 70,
                                    left: screenHeight / 25,
                                    right: screenHeight / 50),

                                width: screenWidth / 3,
                                child: Column(
                                  children: [
                                    Text("Debit: "),
                                    Row(
                                      children: [
                                        Text(
                                            formatter.format(
                                                DatabaseAPI.totals.totalDebit),
                                            style: MyFontStyles
                                                .statementHeaderFontStyle(
                                                    context)),
                                        Text(" JOD", style: TextStyle())
                                      ],
                                    ),
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(
                                    top: screenHeight / 70,
                                    left: screenHeight / 20,
                                    right: screenHeight / 50),

                                width: screenWidth / 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Credit: "),
                                    Row(
                                      children: [
                                        Text(
                                            formatter.format(
                                                DatabaseAPI.totals.totalCredit),
                                            style: MyFontStyles
                                                .statementHeaderFontStyle(
                                                    context)),
                                        Text(" JOD")
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(

                                padding: EdgeInsets.only(
                                    top: screenHeight / 70,
                                    left: screenHeight / 20,
                                    right: screenHeight / 50),

                                width: screenWidth / 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Balance: "),
                                    Row(
                                      children: [
                                        Text(
                                            formatter.format(double.parse(
                                                getIt<SessionData>()
                                                    .doctor
                                                    .balance)),
                                            style: MyFontStyles
                                                .statementHeaderFontStyle(
                                                    context)),
                                        Text(" JOD")
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
