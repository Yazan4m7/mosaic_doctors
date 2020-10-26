// Create the Widget for the row
import 'package:flutter/material.dart';
import 'package:mosaic_doctors/models/AccountStatementEntry.dart';
import 'package:mosaic_doctors/models/job.dart';
import 'package:mosaic_doctors/services/DatabaseAPI.dart';
import 'package:mosaic_doctors/shared/font_styles.dart';

import 'package:mosaic_doctors/views/caseDetailsView.dart';

class EntryItem extends StatefulWidget {
  EntryItem(this.entry);
  final AccountStatementEntry entry;

  @override
  _EntryItemState createState() => _EntryItemState();
}

class _EntryItemState extends State<EntryItem> {
  static bool isEven = false;
  Widget _buildTiles(AccountStatementEntry root) {
    double rowWidth = MediaQuery.of(context).size.width*1.3;
    isEven = !isEven;
    print("width of single Entry : $rowWidth");

    return InkWell(
      child: Container(
        decoration:
            BoxDecoration(color: isEven ? Colors.white : Colors.transparent),

        child: Row(
          children: [
            Container(
              width: rowWidth / 5,
              child: Text(
                root.createdAt.substring(0, 10),
                style: MyFontStyles.statementEntryFontStyle(context),
              ),
            ),
            Container(

              width: rowWidth / 5,
              child: Text(

                root.patientName,
                style: MyFontStyles.statementEntryFontStyle(context),
              textAlign: TextAlign.right,),
            ),
            Container(
                  padding: EdgeInsets.symmetric(horizontal: rowWidth / 5 / 3),
              width: rowWidth / 5,
              child: Text(

                root.credit == "N/A" ? root.debit : root.credit,
                style:
                     MyFontStyles.statementEntryFontStyle(context),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: rowWidth / 5 / 3),
              width: rowWidth / 5,
              child: Text(
                root.debit,
                style: MyFontStyles.statementEntryFontStyle(context),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: rowWidth / 5 / 4),
              width: rowWidth / 5,
              child: Text(
                root.balance,
                style: MyFontStyles.statementEntryFontStyle(context),
                textAlign: TextAlign.left,
              ),
            )
          ],
        ),
      ),
      onTap: () {

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => CaseDetailsView(
                  caseId: root.orderId,
                )));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(widget.entry);
  }
}
