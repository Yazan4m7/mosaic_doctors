import 'package:flutter/cupertino.dart';
import 'package:mosaic_doctors/shared/globalVariables.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Responsiveness {
  static double docNameFontSize;
  static double logoWidth;
  static double entryFontSize;
  static double patientNameFontSize;

  static setResponsiveProperties(BuildContext context){
      double screenWidth = MediaQuery.of(context).size.width;
//    if (screenWidth <= 321){
//      docNameFontSize = 20.0;
//      logoWidth = 70.0;
//      entryFontSize = 13;
//      patientNameFontSize = 13;
//    }else if (screenWidth > 321 && screenWidth < 412){
//      docNameFontSize = 25.0;
//      logoWidth = 170.0;
//      entryFontSize = 15.0;
//      patientNameFontSize = 12;
//    }else if (screenWidth >= 412 && screenWidth < 600){
////      docNameFontSize = 30.0;
////      logoWidth = 190.0;
////      entryFontSize = 15.0;
////      patientNameFontSize = 13;
    docNameFontSize = 55.0;
    logoWidth = 480.0;

    if(!Global.prefs.containsKey('entryFontSize'))
      entryFontSize = 39.0;
    else
      entryFontSize = Global.prefs.getDouble('entryFontSize');
    if(!Global.prefs.containsKey('patientNameFontSize'))
      patientNameFontSize = 34.0;
    else
      patientNameFontSize = Global.prefs.getDouble('patientNameFontSize');


//    }else if (screenWidth >= 600){
//      docNameFontSize = 31.0;
//      logoWidth = 230.0;
//      entryFontSize = 15.0;
//      patientNameFontSize = 13.0;
//    }
  }

  static increaseSize(){
    entryFontSize++;
    patientNameFontSize++;
    Global.prefs.setDouble("entryFontSize", entryFontSize);
    Global.prefs.setDouble("patientNameFontSize", patientNameFontSize);
  }
  static decreaseSize(){
    entryFontSize--;
    patientNameFontSize--;
    Global.prefs.setDouble("entryFontSize", entryFontSize);
    Global.prefs.setDouble("patientNameFontSize", patientNameFontSize);
  }
}