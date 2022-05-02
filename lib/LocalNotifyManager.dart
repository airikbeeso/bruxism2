import 'package:bruxism2/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotifyManager {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var initSettings;
  int genId = 0;
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
    initSettings = InitializationSettings(android: initSettingAndroid);
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
    await flutterLocalNotificationsPlugin
        .show(0, 'Test Title', 'body', platformChannel, payload: 'Net Payload');
  }

  Future<void> repeatNotification() async {
    var androidChannel = const AndroidNotificationDetails(
        'CHANNEL_ID', 'CHANNEL_NAME',
        importance: Importance.max, priority: Priority.high, playSound: true);
    // var iosChannel = const IOSNotificationDetails();
    var platformChannel = NotificationDetails(android: androidChannel);

    await flutterLocalNotificationsPlugin.periodicallyShow(
        0, 'Test Title', 'body', RepeatInterval.everyMinute, platformChannel,
        payload: 'Net Payload');
  }

  Future<void> dailyAtTimeNotification(int _id, int hour, DateTime dt2,
      String id, String title, String description) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);
    var dt = tz.TZDateTime.now(tz.local);
    var currentDateTime = tz.TZDateTime.utc(dt.year, dt.month, dt.day, hour);
    var dtn = DateTime.now();
    print("currentDateTime $currentDateTime $dtn");
    var h = dtn.hour;
    var m = dtn.minute;
    var s = dtn.second;

    if (h > hour) {
      var second = (h - hour) * 3600;
      second += ((60 - m) * 60);
      second += (60 - s);
      print("seconds $second");

      currentDateTime =
          tz.TZDateTime.now(tz.local).add(Duration(seconds: (second * 3600)));
    } else {
      // var dtn2 =
      //     DateTime(dt.year, dt.month, dt.day + 1, h, dtn.minute, dtn.second);

      var second = (h + 24) - hour;
      second += ((60 - m) * 60);
      second += (60 - s);

      print("seconds $second");
      currentDateTime =
          tz.TZDateTime.now(tz.local).add(Duration(seconds: (second * 3600)));
    }

    // if (dt.hour < hour) {
    //   currentDateTime = tz.TZDateTime.utc(dt.year, dt.month, dt.day, hour);
    // } else {
    //   currentDateTime = tz.TZDateTime.utc(dt.year, dt.month, dt.day + 1, hour);

    // }

    // final String timeZoneName =
    //     await platform.invokeMethod('getTimeZoneName');
    // tz.setLocalLocation(tz.getLocation(timeZoneName));
    // Duration offsetTime = tz.TZDateTime.now(tz.local).timeZoneOffset;

    // var dt3 = tz.TZDateTime.now(tz.local);
    // // var dt3 = DateTime.now();
    // currentDateTime = tz.TZDateTime.utc(
    //     dt3.year, dt3.month, dt3.day, dt3.hour, dt3.minute, dt3.second + 5);

    // currentDateTime = dt.add(const Duration(seconds: 5));
    // currentDateTime = tz.TZDateTime.utc(
    //     dt3.year, dt3.month, dt3.day, dt3.hour, dt3.minute, dt3.second + 3);
    // print("current Date Time ${tz.local} ${currentDateTime}");

    var androidChannel = const AndroidNotificationDetails(
        'CHANNEL_ID', 'CHANNEL_NAME',
        importance: Importance.max, priority: Priority.high, playSound: true);
    // var iosChannel = const IOSNotificationDetails();
    var platformChannel = NotificationDetails(android: androidChannel);

    print("gen Id : $_id");

    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //     _id + 1000 + 1,
    //     title,
    //     description,
    //     // currentDateTime,
    //     dt.add(const Duration(minutes: 5)),
    //     platformChannel,
    //     payload: id,
    //     uiLocalNotificationDateInterpretation:
    //         UILocalNotificationDateInterpretation.wallClockTime,
    //     androidAllowWhileIdle: true);
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //     _id += 1000 + 1,
    //     title,
    //     description,
    //     // currentDateTime,
    //     dt.add(const Duration(seconds: 5 + 1)),
    //     platformChannel,
    //     payload: id,
    //     uiLocalNotificationDateInterpretation:
    //         UILocalNotificationDateInterpretation.wallClockTime,
    //     androidAllowWhileIdle: true);
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //     _id += 1000 + 1,
    //     title,
    //     description,
    //     // currentDateTime,
    //     dt.add(const Duration(seconds: 5 + 2)),
    //     platformChannel,
    //     payload: id,
    //     uiLocalNotificationDateInterpretation:
    //         UILocalNotificationDateInterpretation.wallClockTime,
    //     androidAllowWhileIdle: true);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        _id,
        title,
        description,
        currentDateTime,
        // dt.add(const Duration(seconds: 5)),
        platformChannel,
        payload: id,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true);
  }

  Future<void> dailyAtTimeNotification2(int _id, int hour, DateTime dt2,
      String id, String title, String description) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);
    var dt = tz.TZDateTime.now(tz.local);
    var currentDateTime = tz.TZDateTime.utc(dt.year, dt.month, dt.day, hour);
    var dtn = DateTime.now();
    print("currentDateTime $currentDateTime $dtn");
    var h = dtn.hour;
    var m = dtn.minute;
    var s = dtn.second;

    if (h > hour) {
      var second = (h - hour) * 3600;
      second -= (m * 60);
      second -= s;

      currentDateTime =
          tz.TZDateTime.now(tz.local).add(Duration(seconds: (second * 3600)));
    } else {
      // var dtn2 =
      //     DateTime(dt.year, dt.month, dt.day + 1, h, dtn.minute, dtn.second);

      var second = (h + 24) - hour;
      second -= (m * 60);
      second -= s;
      currentDateTime =
          tz.TZDateTime.now(tz.local).add(Duration(seconds: (second * 3600)));
    }

    // if (dt.hour < hour) {
    //   currentDateTime = tz.TZDateTime.utc(dt.year, dt.month, dt.day, hour);
    // } else {
    //   currentDateTime = tz.TZDateTime.utc(dt.year, dt.month, dt.day + 1, hour);

    // }

    // final String timeZoneName =
    //     await platform.invokeMethod('getTimeZoneName');
    // tz.setLocalLocation(tz.getLocation(timeZoneName));
    // Duration offsetTime = tz.TZDateTime.now(tz.local).timeZoneOffset;

    // var dt3 = tz.TZDateTime.now(tz.local);
    // // var dt3 = DateTime.now();
    // currentDateTime = tz.TZDateTime.utc(
    //     dt3.year, dt3.month, dt3.day, dt3.hour, dt3.minute, dt3.second + 5);

    // currentDateTime = dt.add(const Duration(seconds: 5));
    // currentDateTime = tz.TZDateTime.utc(
    //     dt3.year, dt3.month, dt3.day, dt3.hour, dt3.minute, dt3.second + 3);
    // print("current Date Time ${tz.local} ${currentDateTime}");

    var androidChannel = const AndroidNotificationDetails(
        'CHANNEL_ID', 'CHANNEL_NAME',
        importance: Importance.max, priority: Priority.high, playSound: true);
    // var iosChannel = const IOSNotificationDetails();
    var platformChannel = NotificationDetails(android: androidChannel);

    print("gen Id : $_id");

    await flutterLocalNotificationsPlugin.zonedSchedule(
        _id + 1000 + 1,
        title,
        description,
        // currentDateTime,
        dt.add(const Duration(minutes: 5)),
        platformChannel,
        payload: id,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        _id += 1000 + 1,
        title,
        description,
        // currentDateTime,
        dt.add(const Duration(seconds: 5 + 1)),
        platformChannel,
        payload: id,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true);
    await flutterLocalNotificationsPlugin.zonedSchedule(
        _id += 1000 + 1,
        title,
        description,
        // currentDateTime,
        dt.add(const Duration(seconds: 5 + 2)),
        platformChannel,
        payload: id,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.wallClockTime,
        androidAllowWhileIdle: true);
  }

  Future<void> cancelAllScheduled() async {
    await flutterLocalNotificationsPlugin.cancelAll();
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
