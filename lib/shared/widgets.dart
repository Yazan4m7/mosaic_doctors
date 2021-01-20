
import 'package:flutter/material.dart';
import 'package:mosaic_doctors/shared/customDialogBox.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'font_styles.dart';

class SharedWidgets {


  static Widget getAppBarUI(BuildContext context,GlobalKey<ScaffoldState> scaffoldKey,String title,[Widget leftAppbarWidget, Function onBackButtonTap]) {
    return Container(
      height: AppBar().preferredSize.height,
      decoration: BoxDecoration(
color: Colors.white,

        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              offset: const Offset(0, 2),
              blurRadius: 8.0),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: Material(
              color: Colors.white,
              child: InkWell(

                borderRadius: const BorderRadius.all(
                  Radius.circular(50.0),
                ),
                onTap: onBackButtonTap ?? (){Navigator.pop(context);},
                child: Padding(
                  padding: const EdgeInsets.only(left:5.0,top:10,bottom: 10,right: 10),
                  child: onBackButtonTap ==null ?  Icon(Icons.arrow_back) : Icon(Icons.clear_rounded),
                ),
              ),
            ),
          ),

          Flexible(
           flex:9,
            child: Row(

              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right:0.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(

                      onTap: () {},
                      child: Text('  '+title,style: MyFontStyles.titleBlackFontStyle(context),),
                    ),
                  ),
                ),

              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Container (
              child:   leftAppbarWidget ?? SizedBox(),
            ),
          )
        ],
      ),
    );
  }
  static loadingCircle(String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black)),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(color: Colors.black),
          )
        ],
      ),
    );
  }

  static showMOSAICDialog(String text,BuildContext context) {
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


}