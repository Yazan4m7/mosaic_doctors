import 'package:flutter/material.dart';
import 'package:mosaic_doctors/models/AccountStatementEntry.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/models/doctor.dart';
import 'package:mosaic_doctors/models/statementTotals.dart';
import 'package:mosaic_doctors/services/DatabaseAPI.dart';
import 'package:mosaic_doctors/shared/font_styles.dart';
import 'package:mosaic_doctors/shared/styles.dart';
import 'package:mosaic_doctors/shared/widgets.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:mosaic_doctors/views/StatementEntry.dart';

class AccountStatementView extends StatefulWidget {
  @override
  _AccountStatementViewState createState() => _AccountStatementViewState();
}

class _AccountStatementViewState extends State<AccountStatementView> {
  Future accountStatementEntrys;

  getAccountStatement() async{

    accountStatementEntrys =
          DatabaseAPI.getDoctorAccountStatement(getIt<SessionData>().doctor.id);

  }
  @override
  void initState() {

    getAccountStatement();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
    double screenHeight = MediaQuery.of(context).size.height-7;
    double rowWidth = MediaQuery.of(context).size.width-14;

    return Scaffold(
      body: SafeArea(
        key: _scaffoldKey,
        child: Column(

          children: [
            SharedWidgets.getAppBarUI(context, _scaffoldKey, "Account Statetment"),
            Container(
              height: screenHeight-85,
              child: FutureBuilder(
                  future: accountStatementEntrys,
                  builder: (context, accountStatementEntrys) {
                    if (accountStatementEntrys.connectionState ==
                        ConnectionState.none || accountStatementEntrys.connectionState ==
                        ConnectionState.waiting) {
                      return SharedWidgets.loadingCircle('Loading');
                    }
                    if (accountStatementEntrys.data == null ) {
                      return Center(
                          child: Text(
                        "No Entrys",
                      ));
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [

                              Container(
                                width: rowWidth,
                                height: screenHeight/22,
                                child: Row(
                                  children: [
                                    Container(
                                      width: rowWidth/4,
                                      child: Text("Date", style:MyFontStyles.statementHeaderFontStyle(context)),
                                    ),
                                    Container(alignment: Alignment.center,
                                      width: rowWidth/4,
                                      child: Text("Entry", style:MyFontStyles.statementHeaderFontStyle(context)),
                                    ),
                                    Container(alignment: Alignment.center,
                                      width: rowWidth/3.9,

                                      child: Row(
                                        children: [
                                          Text("Credit", style:MyFontStyles.statementHeaderFontStyle(context).copyWith(fontSize: 16,color: Colors.red)),
                                          Text("/", style:MyFontStyles.statementHeaderFontStyle(context).copyWith(fontSize: 16)),
                                          Text("Debit", style:MyFontStyles.statementHeaderFontStyle(context).copyWith(fontSize: 16,color: Colors.green)),
                                        ],
                                      ),
                                    ),
                                    Container(alignment: Alignment.center,
                                      width: rowWidth/4.5,
                                      child: Text("Balance", style:MyFontStyles.statementHeaderFontStyle(context)),
                                    ),SizedBox(height: 50,)
                                  ],
                                ),
                              ),
                              Divider(),
                              Container(
                                height: screenHeight/1.45,
                                child: AnimatedList(
                                    scrollDirection: Axis.vertical,
                                    initialItemCount: accountStatementEntrys.data.length,
                                    itemBuilder: (context, index, animation) {
                                      AccountStatementEntry ASE =
                                      accountStatementEntrys.data[index];

                                      return Column(
                                        children: [

                                          Container(
                                              width:MediaQuery.of(context).size.width,
                                              child: EntryItem(ASE))
                                        ],
                                      );
                                    }),
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
                          alignment: Alignment.bottomCenter,
                          height: screenHeight/14,
                          child: Row(
                            children: [
                              Container(alignment: Alignment.center,
                                width: rowWidth/4,
                                child: Text("Total:", style:MyFontStyles.statementHeaderFontStyle(context)),
                              ),
                              Container(alignment: Alignment.center,
                                width: rowWidth/4,
                                child: Text(DatabaseAPI.totals.totalDebit.toString(), style:MyFontStyles.statementHeaderFontStyle(context).copyWith(color: Colors.red)),
                              ),
                              Container(alignment: Alignment.center,
                                width: rowWidth/4,
                                child: Text(DatabaseAPI.totals.totalCredit.toString(), style:MyFontStyles.statementHeaderFontStyle(context).copyWith(color: Colors.green)),
                              ),
                              Container(alignment: Alignment.center,
                                width: rowWidth/4,
                                child: Text(getIt<SessionData>().doctor.balance, style:MyFontStyles.statementHeaderFontStyle(context)),
                              )
                            ],

                          ),),
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
