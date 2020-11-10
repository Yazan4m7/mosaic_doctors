import 'package:flutter/material.dart';
import 'package:mosaic_doctors/views/monthlyAccountStatement.dart';
import 'package:workmanager/workmanager.dart';

const checkForEndOfMonth = "checkForEndOfMonth";
void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    switch (task) {
      case checkForEndOfMonth:
        var date = new DateTime.now();
        String currentMonth = date.month.toString() + "-"+ date.year.toString().substring(2,4);

        print("$checkForEndOfMonth was executed. inputData = $inputData");
        break;
    }

    return Future.value(true);
  });
}

class MOSAICWorkManager {

  static void startChecking() {
    Workmanager.cancelAll();

    Workmanager.initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    Workmanager.registerPeriodicTask(
      "5",
      checkForEndOfMonth,
      frequency: Duration(days: 1),
    );
    print("Registered Notification Task");
  }
}
