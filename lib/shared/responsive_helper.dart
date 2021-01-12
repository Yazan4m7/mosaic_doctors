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
      logoWidth= 70.0;
      entryFontSize=13;
      patientNameFontSize=13;
    }else if (screenWidth > 321 && screenWidth < 412){
      docNameFontSize= 25.0;
      logoWidth= 170.0;
      entryFontSize=15.0;
      patientNameFontSize=12;
    }else if (screenWidth >= 412 && screenWidth < 600){
      docNameFontSize= 30.0;
      logoWidth= 190.0;
      entryFontSize=16.0;
      patientNameFontSize=14;
    }else if (screenWidth >= 600){
      docNameFontSize= 40.0;
      logoWidth= 200.0;
      entryFontSize=24.0;
      patientNameFontSize=24.0;
    }


  }



}