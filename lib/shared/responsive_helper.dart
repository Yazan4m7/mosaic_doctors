import 'package:flutter/cupertino.dart';

class Responsiveness {
  static double docNameFontSize;
  static double logoWidth;
  static double entryFontSize;
  static double patientNameFontSize;
  static setResponsiveProperties(BuildContext context){
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth <= 321){
      docNameFontSize = 20.0;
      logoWidth= 220.0;
      entryFontSize=12;
      patientNameFontSize=12;
    }else if (screenWidth > 321 && screenWidth < 412){
      docNameFontSize= 25.0;
      logoWidth= 320.0;
      entryFontSize=14.0;
      patientNameFontSize=11;
    }else if (screenWidth >= 412 && screenWidth < 600){
      docNameFontSize= 35.0;
      logoWidth= 420.0;
      entryFontSize=17.0;
      patientNameFontSize=17;
    }else if (screenWidth >= 600){
      docNameFontSize= 40.0;
      logoWidth= 520.0;
      entryFontSize=25.0;
      patientNameFontSize=25.0;
    }


  }



}