import 'dart:developer' as dev;
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static void initialize() {
    InitializationSettings initializationSettings =
        const InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async {
    if (message.notification!.title.toString() != "Message from Support Team") {
      try {
        dev.log("In Notification method");
        // int id = DateTime.now().microsecondsSinceEpoch ~/1000000;
        Random random = Random();
        int id = random.nextInt(1000);
        NotificationDetails notificationDetails = const NotificationDetails(
            android: AndroidNotificationDetails(
          "mychanel",
          "my chanel",
          icon: "@mipmap/ic_launcher",
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          channelShowBadge: true,
          largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(''),
        ));
        dev.log("my id is ${id.toString()}");
        await _flutterLocalNotificationsPlugin.show(
          id,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails,
        );
      } on Exception catch (e) {
        dev.log('Error>>>$e');
      }
    }
  }
}
