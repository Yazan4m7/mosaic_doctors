// Create the Widget for the row
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mosaic_doctors/models/AccountStatementEntry.dart';
import 'package:mosaic_doctors/models/job.dart';
import 'package:mosaic_doctors/models/payment.dart';
import 'package:mosaic_doctors/models/previousMonthBalance.dart';
import 'package:mosaic_doctors/services/DatabaseAPI.dart';
import 'package:mosaic_doctors/shared/font_styles.dart';

import 'package:mosaic_doctors/views/caseDetailsView.dart';
import 'package:mosaic_doctors/views/monthlyAccountStatement.dart';

class EntryItem extends StatefulWidget {
  EntryItem(this.entry);
  final dynamic entry;

  @override
  _EntryItemState createState() => _EntryItemState();
}

class _EntryItemState extends State<EntryItem> {
  static bool isEven = false;
  Widget _buildTiles(dynamic root) {
    double rowWidth = MediaQuery.of(context).size.width-16;
    isEven = !isEven;


    return InkWell(
      child: Container(
        decoration:
            BoxDecoration(color: isEven ? Colors.white : Colors.transparent),

        child: Row(
          children: [
            Container(
              width: rowWidth / 4.7,
              child: Text( root is PreviousMonthBalance ?  Jiffy([0000,int.parse(root.date.substring(3, 5))+1,00]).format("MMM") +"-"+ root.date.substring(0,2):
                root.createdAt.length > 10 ? root.createdAt.substring(8, 11) + Jiffy([0000,int.parse(root.createdAt.substring(5, 7))+1,00]).format("MMM")
                    + "-" + root.createdAt.substring(2, 4) : root.createdAt,
                style: MyFontStyles.statementEntryFontStyle(context),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left :rowWidth / 5 / 10),
              width: rowWidth / 4.0,
              child: Text(

                root is AccountStatementEntry ? root.patientName : root is PreviousMonthBalance? "رصيد سابق":  "Payment",
                style: MyFontStyles.statementEntryFontStyle(context),
              textAlign: TextAlign.right,),
            ),
            Container(
                  //padding: EdgeInsets.symmetric(horizontal: rowWidth / 5 / 5),
              width: rowWidth / 5.4,
              child: Text(

                root is Payment ? root.amount : "",
                style:
                     MyFontStyles.statementEntryFontStyle(context).copyWith(color:Colors.green),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: EdgeInsets.only(left :rowWidth / 5 / 5),
              width: rowWidth / 5.4,
              child: Text(
                  root is AccountStatementEntry ? root.amount : root is Payment ? "" : root.amount,
                style: MyFontStyles.statementEntryFontStyle(context),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: EdgeInsets.only(left :rowWidth / 5 / 10),
              width: rowWidth / 6,
              child: Text( root is PreviousMonthBalance ? "" :
                root.balance ??  "",
                style: MyFontStyles.statementEntryFontStyle(context),
                textAlign: TextAlign.left,
              ),
            )
          ],
        ),
      ),
      onTap: () {

        if (root is PreviousMonthBalance)
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MonthlyAccountStatementView(
                  month: root.date,
              )));
        else
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CaseDetailsView(
                  caseId: root.orderId,patientName: root.patientName,deliveryDate:root.createdAt
                )));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(widget.entry);
  }
}
