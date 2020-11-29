import 'package:flutter/material.dart';
import 'package:mosaic_doctors/shared/responsive_helper.dart';


class MyFontStyles {
  static TextStyle textHeadingFontStyle(BuildContext context) {
    return Theme.of(context).textTheme.headline1.copyWith(
        fontFamily: "montserrat", fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black87);
  }
  static TextStyle textValueheadingFontStyle(BuildContext context) {
    return Theme.of(context).textTheme.headline1.copyWith(
        fontFamily: "montserrat", fontSize: 16.0,fontWeight: FontWeight.w400, color: Colors.black87);
  }
  static TextStyle titleBlackFontStyle(BuildContext context) {
    return Theme
        .of(context)
        .textTheme
        .headline1
        .copyWith(
      fontFamily: "montserrat",
      fontSize: 22.0,
      letterSpacing: 1,
      fontWeight: FontWeight.w400,
      color: Colors.black,);
  }
  static TextStyle valueFontStyle(BuildContext context) {
    return Theme
        .of(context)
        .textTheme
        .headline1
        .copyWith(
      fontFamily: "montserrat",
      fontSize: 18.0,
      fontWeight: FontWeight.w400,
      color: Colors.black,);
  }
  static TextStyle statementEntryFontStyle(BuildContext context) {
    return Theme
        .of(context)
        .textTheme
        .headline1
        .copyWith(
      fontFamily: "droid",
      fontSize: Responsiveness.entryFontSize,

      color: Colors.black,);
  }
  static TextStyle statementHeaderFontStyle(BuildContext context) {
    return Theme.of(context).textTheme.headline1.copyWith(
        fontSize: Responsiveness.entryFontSize,
        fontWeight: FontWeight.w600,
        color: Colors.black,
       );
  }
  static TextStyle textFieldsLabelStyle(BuildContext context){
    return Theme.of(context).textTheme.headline1.copyWith(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.grey);



  }
  static TextStyle doctorNameFontStyle(BuildContext context) {
    return Theme.of(context).textTheme.headline1.copyWith(
        fontFamily: "droid", fontSize:Responsiveness.docNameFontSize, fontWeight: FontWeight.bold, color: Colors.black87);
  }


}
