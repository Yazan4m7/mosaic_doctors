import 'dart:io';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
as notifs;
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:mosaic_doctors/models/sessionData.dart';
import 'package:mosaic_doctors/services/labDatabase.dart';
import 'package:mosaic_doctors/shared/Constants.dart';
import 'package:mosaic_doctors/shared/date_helper.dart';
import 'package:mosaic_doctors/shared/globalVariables.dart';
import 'package:mosaic_doctors/shared/locator.dart';
import 'package:mosaic_doctors/views/labStatementMainScreen.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
class Notifications {

  /// To verify things are working, check out the native platform logs.
   static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();
    print('Handling a background message ${message.messageId}');
  }

  /// Create a [AndroidNotificationChannel] for heads up notifications
  static AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
 static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin  = FlutterLocalNotificationsPlugin();


  static initializeFCM() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null ) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
    });

  }

  static Future<void> scheduleNotification({String title, String body}) async {
//    flutterLocalNotificationsPlugin.cancelAll();
//
//    bool scheduledBefore = Global.prefs.getBool("febNotificationScheduled") ?? false;
//    var date = new DateTime.now();
//    var month = date.month;
//    print("Scheduling notification : current month : ${date.month}");
//    if (month == 3 && !scheduledBefore && Platform.isIOS) {
//      print("Scheduling notification!!");
//      int daysUntilNextMonth = DateHelper.daysUntilNxtMonth();
//
//      print("Days until next month : $daysUntilNextMonth");
//      tz.initializeTimeZones();
//
//      var androidSpecifics = notifs.AndroidNotificationDetails(
//        '1', // This specifies the ID of the Notification
//        'Scheduled notification',
//        // This specifies the name of the notification channel
//        'A scheduled notification',
//        //This specifies the description of the channel
//        icon: 'mipmap/mosaic_logo_1cmt',
//      );
//
//      final IOSInitializationSettings initializationSettingsIOS =
//      IOSInitializationSettings(
//          onDidReceiveLocalNotification: onDidReceiveLocalNotification);
//      var iOSSpecifics = notifs.IOSNotificationDetails();
//
//      var platformChannelSpecifics = notifs.NotificationDetails(
//          android: androidSpecifics, iOS: iOSSpecifics);
//
//      await flutterLocalNotificationsPlugin.zonedSchedule(
//          0,
//          'Your account statement for last month is ready!',
//          'Click here to view',
//          tz.TZDateTime.now(tz.local).add(Duration(minutes: 5)),
//          platformChannelSpecifics,
//          androidAllowWhileIdle: true,
//          uiLocalNotificationDateInterpretation:
//          UILocalNotificationDateInterpretation.absoluteTime,payload: "02-2021");
//      Global.prefs.setBool("febNotificationScheduled",true);
//    }
//  }
}


}