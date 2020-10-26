import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mosaic_doctors/models/case.dart';
import 'package:mosaic_doctors/models/job.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/services/DatabaseAPI.dart';
import 'package:mosaic_doctors/shared/font_styles.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:mosaic_doctors/shared/styles.dart';
import 'package:mosaic_doctors/shared/widgets.dart';

class CaseDetailsView extends StatefulWidget {
  String caseId;
  CaseDetailsView({this.caseId});

  @override
  _CaseDetailsViewState createState() => _CaseDetailsViewState();
}

class _CaseDetailsViewState extends State<CaseDetailsView> {
  Future jobsList;
  Future caseItem;
  getCaseDetails() {
    jobsList = DatabaseAPI.getCaseJobs(widget.caseId);
    caseItem = DatabaseAPI.getCase(widget.caseId);
  }

  @override
  void initState() {
    getCaseDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
    double screenWidth = MediaQuery.of(context).size.width-40;
    double screenHeight= MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: GlobalTheme.caseDetailsViewBoxDec,

        key: _scaffoldKey,

        child: Column(
          children: [
            SafeArea(child: SharedWidgets.getAppBarUI(context, _scaffoldKey, "Case Info")),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(children: <Widget>[
                      FutureBuilder(
                        future: caseItem,
                        builder: (context, caseItem) {
                          if (caseItem.connectionState ==
                                  ConnectionState.none ||
                              caseItem.connectionState ==
                                  ConnectionState.waiting) {
                            return SharedWidgets.loadingCircle('Loading');
                          }
                          if (caseItem.data == null) {
                            return Center(
                                child: Text(
                              "No Data",
                            ));
                          }
                          Case caseObject = caseItem.data;
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 6,
                            child: Column(
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          Container(
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2 -
                                                  20,
                                              child: Text(
                                                "Patient Name",
                                                style: MyFontStyles
                                                    .textHeadingFontStyle(
                                                        context),
                                              )),
                                          Container(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2 -
                                                20,
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              caseObject.patientName ?? "N/A",
                                              style: MyFontStyles
                                                      .doctorNameFontStyle(
                                                          context)
                                                  .copyWith(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // SizedBox(width: screenAwareSize(10, context)),
//                          SizedBox(
//                            width: screenAwareSize(30, context),
//                          ),

                                    ]),
                                SizedBox(height: 25),
                                Column(
                                  children: [
                                    Container(
                                        alignment: Alignment.topLeft,
                                        child: Text("Delivery Date",
                                            style: MyFontStyles
                                                .textHeadingFontStyle(
                                                    context))),
                                    Container(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                            caseObject.deliveryDate == null
                                                ? "N/A "
                                                : caseObject.deliveryDate
                                                    .substring(0, 10),
                                            style: MyFontStyles
                                                    .textValueheadingFontStyle(
                                                        context)
                                                .copyWith(fontSize: 19)))
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30),
                      Row(children: <Widget>[
                        Container(

                            child: Text("Jobs :",
                                style: MyFontStyles.textHeadingFontStyle(
                                    context))),
                      ]),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            width: screenWidth / 4,
                            child: Text('Total Units',
                                style: MyFontStyles.valueFontStyle(context).copyWith(fontWeight: FontWeight.w700)),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: screenWidth / 4,
                            child: Text('Type',
                                style: MyFontStyles.valueFontStyle(context).copyWith(fontWeight: FontWeight.w700)),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: screenWidth / 4,
                            child: Text('Material',
                                style: MyFontStyles.valueFontStyle(context).copyWith(fontWeight: FontWeight.w700)),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: screenWidth / 5,
                            child: Text('Price',
                                style: MyFontStyles.valueFontStyle(context).copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                      Divider(),
                      Container(
                        height: screenHeight/2.16,
                        child: FutureBuilder(
                          future: jobsList,
                          builder: (context, projectSnap) {
                            switch (projectSnap.connectionState) {
                              case ConnectionState.none:
                                return SharedWidgets.loadingCircle(
                                    'Connection failed');
                              case ConnectionState.waiting:
                                return SharedWidgets.loadingCircle(
                                    'Waiting Connection');
                              case ConnectionState.active:
                                break;
                              case ConnectionState.done:
                                {
                                  if (projectSnap == null) {
                                    return CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white));
                                  }
                                  if (!projectSnap.hasData)
                                    return Text('No Jobs',
                                        style: MyFontStyles.textHeadingFontStyle(
                                            context));
                                }
                                break;
                            }
                            return ListView.builder(
                              //scrollDirection: Axis.vertical,
                              padding: EdgeInsets.all(0),
                              shrinkWrap: true,
                              itemCount: projectSnap.data.length,
                              itemBuilder: (context, index) {
                                Job job = projectSnap.data[index];
                                print(
                                    "snap length is : ${projectSnap.data.length} index is $index");
                                String numOfUnits =
                                    (','.allMatches(job.unitNum).length + 1)
                                        .toString();
                                if (numOfUnits == '0') numOfUnits = '1';
                                return SingleChildScrollView(
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.center,
                                            width: screenWidth / 4,
                                            child: Text(numOfUnits ,
                                                style: MyFontStyles.valueFontStyle(
                                                    context)),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            width: screenWidth / 4,
                                            child: Text(

                                                DatabaseAPI
                                                    .jobTypes[int.parse(job.typeId)-1]
                                                    .name,
                                                style: MyFontStyles.valueFontStyle(
                                                    context),textAlign:TextAlign.center,),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            width: screenWidth / 4,
                                            child: Text(
                                                DatabaseAPI
                                                    .materials[
                                                        int.parse(job.materialId)-1]
                                                    .name,
                                                style: MyFontStyles.valueFontStyle(
                                                    context)),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            width: screenWidth / 5,
                                            child: Text(DatabaseAPI.materials[
                                  int.parse(job.materialId)-1]
                                      .price,
                                                style: MyFontStyles.valueFontStyle(
                                                    context)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
