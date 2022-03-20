import 'package:bruxism2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:rxdart/subjects.dart';

class LocalNotifyManager {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var initSettings;
  BehaviorSubject<ReceiveNotification> get didReceiveLocalNotificationSubject =>
      BehaviorSubject<ReceiveNotification>();
      
   LocalNotifyManager.init() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      requestIOSPermission();
    }
    initializePlatform();
  }
  requestIOSPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  initializePlatform() {
    var initSettingAndroid =
        const AndroidInitializationSettings('ic_launcher_background');
    // var initSettingIOS = const IOSInitializationSettings(
    //   requestAlertPermission: true,
    //   requestBadgePermission: true,
    //   requestSoundPermission: true,
    //   // onDidReceiveLocalNotification: (id,title,body,payload) async {
    //   //   ReceiveNotification notification = ReceiveNotification(
    //   //     id: id, title: title, body: body, payload: payload
    //   //     );
    //   // }
    // );
    initSettings = InitializationSettings(
        android: initSettingAndroid);
  }

  setOnNotificationReceive(Function onNotificationReceive) {
    didReceiveLocalNotificationSubject.listen((notification) {
      onNotificationReceive(notification);
    });
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: (String? payload) async {
      onNotificationClick(payload);
    });
  }

  Future<void> showNotification() async {
    var androidChannel = const AndroidNotificationDetails(
        'CHANNEL_ID', 'CHANNEL_NAME',
        importance: Importance.max, priority: Priority.high, playSound: true);
        // var iosChannel = const IOSNotificationDetails();
        var platformChannel = NotificationDetails(android: androidChannel);
        await flutterLocalNotificationsPlugin.show(0, 'Test Title', 'body', platformChannel, payload: 'Net Payload');

  }
}
LocalNotifyManager localNotifyManager = LocalNotifyManager.init();
class ReceiveNotification {
  final int id;
  final String title;
  final String body;
  final String payload;
  ReceiveNotification(
      {required this.id,
      required this.title,
      required this.body,
      required this.payload});
}