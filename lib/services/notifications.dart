import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as notifs;
import 'package:mosaic_doctors/shared/date_helper.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifications {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static BuildContext BContext;
  static initialize(BuildContext context) async {
    BContext = context;
    try {
      // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project

      // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('mipmap/mosaic_logo_1cmt');
      final IOSInitializationSettings initializationSettingsIOS =
          IOSInitializationSettings(
              onDidReceiveLocalNotification: onDidReceiveLocalNotification);
      final InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onSelectNotification: showLastMonthAccountStatement);
    } catch (e) {
      throw e;
    }
  }

  static Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    print("Notification fired");
  }

  requestIOSPermissions() async {
    final bool result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static void showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('1', 'MOSAIC', 'MOSAIC_DESC',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');
  }

  static Future showLastMonthAccountStatement(String payload) async {
    var date = new DateTime.now();
    String prev = new DateTime(date.year, date.month - 1).toString();

    String prevYear = prev.substring(2, 4);
    String prevMonth = prev.substring(5, 7);
    String prevFullDate = prevYear + "-" + prevMonth;
//    Navigator.of(BContext).push(MaterialPageRoute(
//        builder: (context) => MonthlyAccountStatementView(
//              month: prevFullDate,
//            )));
    debugPrint('notification payload: ' + payload);
  }

  static Future<void> scheduleNotification({String title, String body}) async {
    flutterLocalNotificationsPlugin.cancelAll();

    int daysUntilNextMonth = DateHelper.daysUntilNxtMonth();

    print("Days until next month : $daysUntilNextMonth");
    tz.initializeTimeZones();

    var androidSpecifics = notifs.AndroidNotificationDetails(
      '1', // This specifies the ID of the Notification
      'Scheduled notification', // This specifies the name of the notification channel
      'A scheduled notification', //This specifies the description of the channel
      icon: 'mipmap/mosaic_logo_1cmt',
    );

    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var iOSSpecifics = notifs.IOSNotificationDetails();

    var platformChannelSpecifics = notifs.NotificationDetails(
        android: androidSpecifics, iOS: iOSSpecifics);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Your account statement for last month is ready!',
        'Click here to view',
        tz.TZDateTime.now(tz.local).add( Duration(days: daysUntilNextMonth)),
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }
}
