import 'package:flutter/material.dart';

import 'font_styles.dart';

class SharedWidgets {
  static Widget getAppBarUI(BuildContext context,GlobalKey<ScaffoldState> scaffoldKey,String title) {
    return Container(
      decoration: BoxDecoration(

        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 8.0),
        ],
      ),
      child: Row(
        children: <Widget>[
          Material(
            color: Colors.white,
            child: InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(0.0),
              ),
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Icon(Icons.arrow_back),
              ),
            ),
          ),

          Container(
            width: MediaQuery.of(context).size.width-40,
            height: AppBar().preferredSize.height,
            child: Row(

              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(5.0),

                    ),
                    onTap: () {},
                    child: Text(title,style: MyFontStyles.titleBlackFontStyle(context),),
                  ),
                ),

              ],
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

}