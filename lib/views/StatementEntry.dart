// Create the Widget for the row
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mosaic_doctors/models/AccountStatementEntry.dart';

import 'package:mosaic_doctors/models/previousMonthBalance.dart';

import 'package:mosaic_doctors/shared/customDialogBox.dart';
import 'package:mosaic_doctors/shared/font_styles.dart';

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
    double rowWidth = MediaQuery.of(context).size.width-16;
    isEven = !isEven;

    return Card(

      elevation: 0,
      child: InkWell(

        child: Container(
        padding: EdgeInsets.only(left: 1),
          decoration:
              BoxDecoration(color: isEven ? Colors.grey.shade200 : Colors.transparent),

          child: Row(
            children: [
              Container(
                width: rowWidth / 4.7,
                child: Text( root is PreviousMonthBalance ?  "":
                  root.createdAt.length > 10 ? root.createdAt.substring(8, 11) + Jiffy([0000,int.parse(root.createdAt.substring(5, 7))+1,00]).format("MMM")
                      + "-" + root.createdAt.substring(2, 4) : root.createdAt,
                  style: MyFontStyles.statementEntryFontStyle(context),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left :rowWidth / 5 / 10),
                width: rowWidth / 4.0,
                child: Text(

                  root is AccountStatementEntry ? root.patientName :  "Payment",
                  style: MyFontStyles.statementPatientNameFontStyle(context),
                textAlign: TextAlign.right,),
              ),
              Container(
                    padding: EdgeInsets.symmetric(horizontal: rowWidth / 5 / 5),
                width: rowWidth / 5.4,
                child: Text(

                  root.credit =="N/A" ? "" :addBracketsIfNegative(root.credit),
                  style:
                       MyFontStyles.statementEntryFontStyle(context).copyWith(color:Colors.green),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left :rowWidth / 5 / 5),
                width: rowWidth / 5.4,
                child: Text(
                    root.debit =="N/A" ? "" : addBracketsIfNegative(root.debit),
                  style: MyFontStyles.statementEntryFontStyle(context),
                  textAlign: TextAlign.left,
                ),
              ),
              Container(
                padding: EdgeInsets.only(left :rowWidth / 5 / 10),
                width: rowWidth / 6,
                child: Text( addBracketsIfNegative(root.balance),
                  style: MyFontStyles.statementEntryFontStyle(context),
                  textAlign: TextAlign.left,
                ),
              )
            ],
          ),
        ),
        onTap: () {
          if(root.debit !="N/A") // its a case
              {
                if(root.caseId == "N/A") {showMOSAICDialog("Case information currently unavailable.");return;}
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    CaseDetailsView(
                        caseId: root.caseId.toString(),
                        patientName: root.patientName,
                        deliveryDate: root.createdAt
                    )));
          }
          else // its a payment
            {showMOSAICDialog("You can view payment details in our next update, stay tuned!");return;}
          },
      ),
    );
  }
  showMOSAICDialog(String text){
    showDialog(context: context,
        builder: (BuildContext context){
          return CustomDialogBox(title:"Alert",descriptions: text,text: "Ok",
          );
        }
    );

  }
  @override
  Widget build(BuildContext context) {
    return _buildTiles(widget.entry);
  }

  addBracketsIfNegative(String number){
  int num = int.parse(number);
  if(num.isNegative)
  return ("(${num.abs()})");
  return number;
  }

}
