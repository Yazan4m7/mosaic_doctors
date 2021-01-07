// Create the Widget for the row
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mosaic_doctors/models/AccountStatementEntry.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mosaic_doctors/models/previousMonthBalance.dart';
import 'package:mosaic_doctors/shared/Constants.dart';

import 'package:mosaic_doctors/shared/customDialogBox.dart';
import 'package:mosaic_doctors/shared/font_styles.dart';
import 'package:mosaic_doctors/shared/responsive_helper.dart';

import 'package:mosaic_doctors/views/caseDetailsView.dart';

class EntryItem extends StatefulWidget {
  EntryItem(this.entry);
  final dynamic entry;

  @override
  _EntryItemState createState() => _EntryItemState();
}

class _EntryItemState extends State<EntryItem> {
  static bool isEven = false;
  Widget _buildTiles(AccountStatementEntry root) {
    double rowWidth = MediaQuery.of(context).size.width - 16;
    isEven = !isEven;

    return InkWell(
      child: Container(
        padding: EdgeInsets.only(left: 0),
        decoration: BoxDecoration(
            color: isEven ? Colors.grey.shade200 : Colors.transparent),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(left: 3),
              width: rowWidth / dateCellWidthFactor,
              child: Text(
                root is PreviousMonthBalance
                    ? ""
                    : root.createdAt.length > 10
                        ? root.createdAt.substring(8, 10) + '-'+
                            Jiffy([
                              0000,
                              int.parse(root.createdAt.substring(5, 7)) + 1,
                              00
                            ]).format("MM") +
                            "-" +
                            root.createdAt.substring(2, 4)
                        : root.createdAt,
                style: MyFontStyles.statementEntryFontStyle(context),
              ),
            ),
            Container(

              width: rowWidth / entryCellWidthFactor,
              child: Text(
                root.patientName ,
                style: root.patientName == "Payment"
                    ? MyFontStyles.statementPatientNameFontStyle(context)
                    .copyWith(
                    fontSize:
                    Responsiveness.patientNameFontSize.sp + 2)
                    : MyFontStyles.statementPatientNameFontStyle(context),
                textAlign: TextAlign.right,
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 16),
              width: rowWidth / creditCellWidthFactor,
              child: Text(
                root.credit == "N/A"
                    ? ""
                    : addBracketsIfNegative(root.credit),
                style: MyFontStyles.statementEntryFontStyle(context)
                    .copyWith(color: Colors.green),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10),
              width: rowWidth / debitCellWidthFactor,
              child: Text(
                root.debit == "N/A" ? "" : addBracketsIfNegative(root.debit),
                style: MyFontStyles.statementEntryFontStyle(context),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 15),
              width: rowWidth / balanceCellWidthFactor,
              child: Text(
                addBracketsIfNegative(root.balance),
                style: MyFontStyles.statementEntryFontStyle(context),
                textAlign: TextAlign.left,
              ),
            )
          ],
        ),
      ),
      onTap: () {
        if (root.debit != "N/A") // its a case
        {
          if(int.parse(root.debit).isNegative){
            showMOSAICDialog(
                "Case Details unavailable");
          return;}
          if (root.caseId == "N/A") {
            showMOSAICDialog("Case information currently unavailable.");
            return;
          }
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => CaseDetailsView(
                  caseId: root.caseId.toString(),
                  patientName: root.patientName,
                  deliveryDate: root.createdAt)));
        } else // its a payment
        {
          showMOSAICDialog(
              "You can view payment details in our next update, stay tuned!");
          return;
        }
      },
    );
  }

  showMOSAICDialog(String text) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomDialogBox(
            title: "Alert",
            descriptions: text,
            text: "Ok",
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(widget.entry);
  }

  addBracketsIfNegative(String number) {
    int num = int.parse(number);
    if (num.isNegative) return ("(${num.abs()})");
    return number;
  }
}
