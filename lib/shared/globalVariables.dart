import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Global {

  static SharedPreferences prefs;

  static initializeSharedPreferences() async{
    prefs = await SharedPreferences.getInstance();
  }

}