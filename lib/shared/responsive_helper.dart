import 'package:flutter/cupertino.dart';

class Responsiveness {
  static double docNameFontSize;
  static double logoWidth;
  static double entryFontSize;

  static setResponsiveProperties(BuildContext context){
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth <= 321){
      docNameFontSize = 20.0;
      logoWidth= 200.0;
      entryFontSize=12;
    }else if (screenWidth > 321 && screenWidth < 412){
      docNameFontSize= 25.0;
      logoWidth= 300.0;
      entryFontSize=15.0;
    }else if (screenWidth >= 412 && screenWidth < 600){
      docNameFontSize= 35.0;
      logoWidth= 400.0;
      entryFontSize=20.0;
    }else if (screenWidth >= 600){
      docNameFontSize= 40.0;
      logoWidth= 500.0;
      entryFontSize=25.0;
    }


  }



}