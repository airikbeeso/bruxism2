import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:io' show Platform;

import 'dart:developer' as developer;
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:bruxism2/SecondScreen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:group_button/group_button.dart';
import 'firebase_options.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'notificationservice.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LocalNotifyManager.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'viewAlerts.dart';
import 'package:localstorage/localstorage.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();
const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initNotification();
  // FirebaseMessaging.instance.subscribeToTopic("all");
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await localNotifyManager.initializePlatform();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
        child: MaterialApp(
      title: 'Bruxism',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Bruxism'),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _pageMode = 0;
  TimeOfDay selectedTime = TimeOfDay.now();
  late int _totalNotifications;
  late final FirebaseMessaging _messaging;
  late PushNotification _notificationInfo;
  late String? email;
  late void Function(
    String email,
    String password,
    void Function(Exception e) error,
  ) signInWithEmailAndPassword;

  late String? loginStatus;
  bool isSwitched = false;
  String? country;

  @override
  void initState() {
    super.initState();
    // Firebase.initializeApp();

    tz.initializeTimeZones();
    _totalNotifications = 0;

    //registerNotification();

    //FirebaseAuth auth = FirebaseAuth.instance;

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        _selectPage(3);
        loginStatus = "logout";
      } else {
        _selectPage(0);
        loginStatus = "loggedIn";
        // readSettings().then((value) {
        //   print("DT");
        //   print(value.docs.length);
        //   if (value.docs.isNotEmpty) {
        //     value.docs.forEach((element) {
        //       // isSwitched = Bool.par element["active"];

        //       print(element["active"] == true);
        //     });
        //   }
        //   // for (int i = 0; i < value.docs.length; i++) {
        //   //   print(value.docs[i]["data"]);
        //   // }
        // });
      }
    });

    // FirebaseAnalytics analytics = FirebaseAnalytics.instance;

    //await registerNotification();
    initFB();
    // startSchedule();

    localNotifyManager.setOnNotificationReceive(onNotificationReceive);
    localNotifyManager.setOnNotificationClick(onNotificationClick);
  }

  onNotificationReceive(ReceivedNotification notification) {
    print('Notification Received: ${notification.id}');
  }

  onNotificationClick(String? payload) {
    print('Payload xxx ::::: $payload');
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return SecondScreen(
            id: payload as String,
            description: "",
            title: "Bruxism",
            selectPage: _selectPage,
            storage: CounterStorage());
      },
    ));
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> signInWithEmailAndPassword2(
    String email,
    String password,
    void Function(FirebaseAuthException e) errorCallback,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void cancelRegistration() {
    _selectPage(3);
  }

  Future<void> registerAccount(
      String email,
      String displayName,
      String password,
      void Function(FirebaseAuthException e) errorCallback) async {
    try {
      var credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await credential.user!.updateDisplayName(displayName);
      var _user = credential.user;

      var _super = {
        "email": _user!.email,
        "uid": _user.uid,
        "photoUrl": "",
        "role": "1",
        "displayName": displayName,
        "emailVerified": credential.user!.emailVerified
      };

      await FirebaseFirestore.instance
          .collection("users")
          .doc(_user.uid)
          .set(_super);
    } on FirebaseAuthException catch (e) {
      errorCallback(e);
    }
  }

  void initFB() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      //_selectPage(0);
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      print("message recieved");
      print(event.notification!.body);
      NotificationService().showNotification(
          1,
          event.notification!.title as String,
          event.notification!.body as String,
          1);

      // showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return AlertDialog(
      //         title: const Text("Notification"),
      //         content: Text(event.notification!.body!),
      //         actions: [
      //           TextButton(
      //             child: const Text("Ok"),
      //             onPressed: () {
      //               Navigator.of(context).pop();
      //             },
      //           )
      //         ],
      //       );
      //     });
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });

    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    country = notificationAppLaunchDetails!.payload;
    if (null != country) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return SecondScreen(
              id: country as String,
              description: "",
              title: "Bruxism",
              selectPage: _selectPage,
              storage: CounterStorage());
        },
      ));
    }
  }

  void _createAlert() {
    setState(() {
      _pageMode = 1;
    });
  }

  void _selectPage(int page) {
    setState(() {
      _pageMode = page;
    });
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        selectedTime = timeOfDay;
      });
      //timeFunction(selectedTime);
    }
  }

  void _sendNotification(BuildContext context) async {
    await NotificationService().showNotification(1, "title", "body", 1);
  }

  Future<void> registerNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();

    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );
        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });

        showSimpleNotification(
          Text(_notificationInfo.title.toString()),
          leading: NotificationBadge(totalNotifications: _totalNotifications),
          subtitle: Text(_notificationInfo.body.toString()),
          background: Colors.cyan.shade700,
          duration: const Duration(seconds: 2),
        );
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void _showErrorDialog(BuildContext context, String title, Exception e) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontSize: 24),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  '${(e as dynamic).message}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            StyledButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
  }

  // Future<DocumentReference>

  Future<void> saveSchedule(DateTime dt, int mode, int _id) async {
    // LocalStorage storage = LocalStorage('questions');

    var list = [];
    var now = DateTime.now();
    var inputFormat = DateFormat('dd/MM/yyyy HH:mm');
    var inputDate = inputFormat.parse(
        '${dt.day}/${dt.month}/${dt.year} ${mode.toString()}:00'); // <-- dd/MM 24H format

    var genId =
        "${dt.year}-${dt.month}-${dt.day}-${mode.toString()}-${FirebaseAuth.instance.currentUser!.uid}";

    // var qa = storage.getItem("questions");

    var packOfQuestions = [
      {
        "id": 0,
        "question": "Kondisi gigi geligi anda saat ini",
        "option": [
          "Terpisah",
          "Berkontak ringan",
          "Berkontak erat",
          "Bergemeretak"
        ],
        "form": "radio"
      },
      {
        "id": 1,
        "question": "Kondisi otot wajah/rahang (?) anda saat ini",
        "option": [
          "Rileks",
          "Otot wajah/rahang tegang dan rahang terasa kencang tanpa ada gigi yang berkontak"
        ],
        "form": "radio"
      },
      {
        "id": 2,
        "question": "Apakah anda merasakan nyeri di daerah wajah",
        "option": ["Ya", "Tidak"],
        "form": "radio"
      },
      {
        "id": 3,
        "question": "Bila nyeri, berapa skala nyeri anda?",
        "option": 10,
        "form": "scale"
      }
    ];

    var packOfQuestions2 = [
      {
        "id": 0,
        "question": "Kondisi gigi geligi anda saat ini",
        "option": [
          "Terpisah",
          "Berkontak ringan",
          "Berkontak erat",
          "Bergemeretak"
        ],
        "form": "radio"
      },
      {
        "id": 1,
        "question": "Kondisi otot wajah/rahang (?) anda saat ini",
        "option": [
          "Rileks",
          "Otot wajah/rahang tegang dan rahang terasa kencang tanpa ada gigi yang berkontak"
        ],
        "form": "radio"
      },
      {
        "id": 2,
        "question": "Apakah anda merasakan nyeri di daerah wajah",
        "option": ["Ya", "Tidak"],
        "form": "radio"
      },
      // {
      //   "id": 3,
      //   "question": "erasa gugup atau tegang",
      //   "option": ["Ya", "Tidak"]
      // },
      {
        "id": 3,
        "question": "Kondisi anda hari ini",
        "option": [
          "Merasa gugup atau tegang",
          "Sulit mengontrol kawatir",
          "Merasa sedih, depresi",
          "Merasa malas melakukan sesuatu"
        ],
        "form": "check"
      }
    ];
    var rng = Random();
    int rn = rng.nextInt(100);
    var chosenQuestion = rn % 2 == 0 ? packOfQuestions2 : packOfQuestions;
    var context = {
      "mode": mode,
      "ih": dt.hour,
      "im": dt.minute,
      "is": dt.second,
      "init": now.millisecondsSinceEpoch,
      "end": inputDate.millisecondsSinceEpoch,
      "date": dt.toIso8601String(),
      "timestamp": dt.millisecondsSinceEpoch,
      "status": "onSchedule",
      "question": "default question",
      "answer": "default answer",
      "listQuestions": chosenQuestion,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'genId': genId,
      'email': FirebaseAuth.instance.currentUser!.email,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'answerOn': 0
    };

    // FirebaseFirestore.instance
    //     .collection("alerts")
    //     .doc(genId)
    //     // .doc('settings/' + FirebaseAuth.instance.currentUser!.uid)
    //     .set(context);

    await LocalNotifyManager.init().dailyAtTimeNotification(
        _id,
        mode,
        dt,
        jsonEncode(context),
        "Bruxism Notificaiton",
        "Rate your pain, Jam $mode");

  }

  Future<void> startSessions_test(
      bool isActive, DateTime dt, bool repeat) async {
    if (loginStatus == "logout") {
      throw Exception('Must be logged in');
    } else {
      if (!repeat) {
        FirebaseFirestore.instance
            .collection("settings")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            // .doc('settings/' + FirebaseAuth.instance.currentUser!.uid)
            .set({
          'data': "",
          'active': isActive,
          'start': dt.toIso8601String(),
          'end': 0,
          'userId': FirebaseAuth.instance.currentUser!.uid,
        });
      }
    }
    print("hour: ${dt.hour} : ${dt.minute} : ${dt.second}");

    if (isActive) {
      int _id = 0;

      var nd9 =
          DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
      nd9 = nd9.add(const Duration(seconds: 3));
      saveSchedule(nd9, 9, _id);
      _id++;
      print("next day: ${nd9.toIso8601String()}");

      var nd12 =
          DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
      nd12 = nd12.add(const Duration(seconds: 5));
      saveSchedule(nd12, 12, _id);
      _id++;
      print("next day: ${nd12.toIso8601String()}");

      var nd15 =
          DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
      nd15 = nd15.add(const Duration(seconds: 10));

      print("next day: ${nd15.toIso8601String()}");
      saveSchedule(nd15, 15, _id);
      _id++;

      var nd18 =
          DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
      nd18 = nd18.add(const Duration(seconds: 15));

      print("next day: ${nd18.toIso8601String()}");
      saveSchedule(nd18, 18, _id);
      _id++;

      var nd21 =
          DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
      nd21 = nd21.add(const Duration(seconds: 15));
      saveSchedule(nd21, 21, _id);
      _id++;
      print("next day: ${nd21.toIso8601String()}");
    } else {
      localNotifyManager.cancelAllScheduled();
      // LocalStorage storage = LocalStorage("questions");
      // storage.clear();
      // storage.dispose();
    }
  }

  Future<void> startSessions(bool isActive, DateTime dt, bool repeat) async {
    if (loginStatus == "logout") {
      throw Exception('Must be logged in');
    } else {
      if (!repeat) {
        FirebaseFirestore.instance
            .collection("settings")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            // .doc('settings/' + FirebaseAuth.instance.currentUser!.uid)
            .set({
          'data': "",
          'active': isActive,
          'start': dt.toIso8601String(),
          'end': 0,
          'userId': FirebaseAuth.instance.currentUser!.uid,
        });
      }
    }
    print("hour: ${dt.hour} : ${dt.minute} : ${dt.second}");

    if (isActive) {
      int _id = 0;
      // var ndT = DateTime.utc(dt.year, dt.month, dt.day, 14);
      // saveSchedule(ndT, 14, 8888);

      if (dt.hour >= 21) {
        ///set next day for hours

        var nd9 = DateTime(dt.year, dt.month, dt.day + 1, 9, 0, 0);
        saveSchedule(nd9, 9, _id);
        _id++;

        print("next day: ${nd9.toIso8601String()}");
        var nd12 = DateTime(dt.year, dt.month, dt.day + 1, 12, 0, 0);
        saveSchedule(nd12, 12, _id);
        _id++;

        print("next day: ${nd12.toIso8601String()}");
        var nd15 = DateTime(dt.year, dt.month, dt.day + 1, 15, 0, 0);
        print("next day: ${nd15.toIso8601String()}");
        saveSchedule(nd15, 15, _id);
        _id++;

        var nd18 = DateTime(dt.year, dt.month, dt.day + 1, 18, 0, 0);
        print("next day: ${nd18.toIso8601String()}");
        saveSchedule(nd18, 18, _id);
        _id++;

        var nd21 = DateTime(dt.year, dt.month, dt.day + 1, 21, 0, 0);
        saveSchedule(nd21, 21, _id);
        _id++;

        print("next day: ${nd21.toIso8601String()}");
      } else {
        if (dt.hour < 9) {
          var nd9 = DateTime(dt.year, dt.month, dt.day, 9, 0, 0);
          saveSchedule(nd9, 9, _id);
          _id++;
          print("next day: ${nd9.toIso8601String()}");

          var nd12 = DateTime(dt.year, dt.month, dt.day, 12, 0, 0);
          saveSchedule(nd12, 12, _id);
          _id++;

          print("next day: ${nd12.toIso8601String()}");

          var nd15 = DateTime(dt.year, dt.month, dt.day, 15, 0, 0);
          saveSchedule(nd15, 15, _id);
          _id++;

          print("next day: ${nd15.toIso8601String()}");

          var nd18 = DateTime(dt.year, dt.month, dt.day, 18, 0, 0);
          saveSchedule(nd18, 18, _id);
          _id++;

          print("next day: ${nd18.toIso8601String()}");

          var nd21 = DateTime(dt.year, dt.month, dt.day, 21, 0, 0);
          saveSchedule(nd21, 21, _id);
          _id++;

          print("next day: ${nd21.toIso8601String()}");
        } else if (dt.hour >= 9 && dt.hour < 12) {
          var nd12 = DateTime(dt.year, dt.month, dt.day, 12, 0, 0);
          saveSchedule(nd12, 12, _id);
          _id++;

          print("next day: ${nd12.toIso8601String()}");

          var nd15 = DateTime(dt.year, dt.month, dt.day, 15, 0, 0);
          saveSchedule(nd15, 15, _id);
          _id++;

          print("next day: ${nd15.toIso8601String()}");

          var nd18 = DateTime(dt.year, dt.month, dt.day, 18, 0, 0);
          saveSchedule(nd18, 18, _id);
          _id++;

          print("next day: ${nd18.toIso8601String()}");

          var nd21 = DateTime(dt.year, dt.month, dt.day, 21, 0, 0);
          saveSchedule(nd21, 21, _id);
          _id++;

          print("next day: ${nd21.toIso8601String()}");

          ///schedule next day
          dt = dt.add(const Duration(days: 1));
          var nd9 = DateTime(dt.year, dt.month, dt.day, 9, 0, 0);
          saveSchedule(nd9, 9, _id);
          _id++;

          print("next day: ${nd9.toIso8601String()}");
        } else if (dt.hour >= 12 && dt.hour < 15) {
          var nd15 = DateTime(dt.year, dt.month, dt.day, 15, 0, 0);
          saveSchedule(nd15, 15, _id);
          _id++;

          print("next day: ${nd15.toIso8601String()}");

          var nd18 = DateTime(dt.year, dt.month, dt.day, 18, 0, 0);
          saveSchedule(nd18, 18, _id);
          _id++;

          print("next day: ${nd18.toIso8601String()}");

          var nd21 = DateTime(dt.year, dt.month, dt.day, 21, 0, 0);
          saveSchedule(nd21, 21, _id);
          _id++;

          print("next day: ${nd21.toIso8601String()}");

          ///schedule next day
          dt = dt.add(const Duration(days: 1));
          var nd9 = DateTime(dt.year, dt.month, dt.day, 9, 0, 0);
          saveSchedule(nd9, 9, _id);
          _id++;

          print("next day: ${nd9.toIso8601String()}");
          var nd12 = DateTime(dt.year, dt.month, dt.day, 12, 0, 0);
          saveSchedule(nd12, 12, _id);
          _id++;

          print("next day: ${nd12.toIso8601String()}");
        } else if (dt.hour >= 15 && dt.hour < 18) {
          var nd18 = DateTime(dt.year, dt.month, dt.day, 18, 0, 0);
          saveSchedule(nd18, 18, _id);
          _id++;

          print("next day: ${nd18.toIso8601String()}");

          var nd21 = DateTime(dt.year, dt.month, dt.day, 21, 0, 0);
          saveSchedule(nd21, 21, _id);
          _id++;

          print("next day: ${nd21.toIso8601String()}");

          ///schedule next day
          dt = dt.add(const Duration(days: 1));
          var nd9 = DateTime(dt.year, dt.month, dt.day, 9, 0, 0);
          saveSchedule(nd9, 9, _id);
          _id++;

          print("next day: ${nd9.toIso8601String()}");
          var nd12 = DateTime(dt.year, dt.month, dt.day, 12, 0, 0);
          saveSchedule(nd12, 12, _id);
          _id++;

          print("next day: ${nd12.toIso8601String()}");
          var nd15 = DateTime(dt.year, dt.month, dt.day, 15, 0, 0);
          saveSchedule(nd15, 15, _id);
          _id++;

          print("next day: ${nd15.toIso8601String()}");
        } else if (dt.hour >= 18 && dt.hour < 21) {
          var nd21 = DateTime(dt.year, dt.month, dt.day, 21, 0, 0);
          saveSchedule(nd21, 21, _id);
          _id++;

          print("next day: ${nd21.toIso8601String()}");

          ///schedule next day
          dt = dt.add(const Duration(days: 1));
          var nd9 = DateTime(dt.year, dt.month, dt.day, 9, 0, 0);
          saveSchedule(nd9, 9, _id);
          _id++;

          print("next day: ${nd9.toIso8601String()}");
          var nd12 = DateTime(dt.year, dt.month, dt.day, 12, 0, 0);
          saveSchedule(nd12, 12, _id);
          _id++;

          print("next day: ${nd12.toIso8601String()}");
          var nd15 = DateTime(dt.year, dt.month, dt.day, 15, 0, 0);
          saveSchedule(nd15, 15, _id);
          _id++;

          print("next day: ${nd15.toIso8601String()}");

          var nd18 = DateTime(dt.year, dt.month, dt.day, 18, 0, 0);
          saveSchedule(nd18, 18, _id);
          _id++;

          print("next day: ${nd18.toIso8601String()}");
        }
      }
    } else {
      localNotifyManager.cancelAllScheduled();
      // LocalStorage storage = LocalStorage("questions");
      // storage.clear();
      // storage.dispose();
    }
  }

  // Future<void> startSessions1(bool isActive, DateTime dt, bool repeat) async {
  //   if (loginStatus == "logout") {
  //     throw Exception('Must be logged in');
  //   } else {
  //     if (!repeat) {
  //       FirebaseFirestore.instance
  //           .collection("settings")
  //           .doc(FirebaseAuth.instance.currentUser!.uid)
  //           // .doc('settings/' + FirebaseAuth.instance.currentUser!.uid)
  //           .set({
  //         'data': "",
  //         'active': isActive,
  //         'start': dt.toIso8601String(),
  //         'end': 0,
  //         'userId': FirebaseAuth.instance.currentUser!.uid,
  //       });
  //     }
  //   }
  //   print("hour: ${dt.hour} : ${dt.minute} : ${dt.second}");

  //   if (isActive) {
  //     if (dt.hour >= 21) {
  //       ///set next day for hours

  //       var nd9 = DateTime.utc(dt.year, dt.month, dt.day + 1, 9);

  //       print("next day: ${nd9.toIso8601String()}");
  //       var nd12 = DateTime.utc(dt.year, dt.month, dt.day + 1, 12);
  //       print("next day: ${nd12.toIso8601String()}");
  //       var nd15 = DateTime.utc(dt.year, dt.month, dt.day + 1, 15);
  //       print("next day: ${nd15.toIso8601String()}");
  //       var nd18 = DateTime.utc(dt.year, dt.month, dt.day + 1, 18);
  //       print("next day: ${nd18.toIso8601String()}");
  //       var nd21 = DateTime.utc(dt.year, dt.month, dt.day + 1, 21);
  //       print("next day: ${nd21.toIso8601String()}");
  //     } else {
  //       if (dt.hour < 9) {
  //         var nd9 = DateTime.utc(dt.year, dt.month, dt.day, 9);
  //         saveSchedule(nd9, 9);
  //         print("next day: ${nd9.toIso8601String()}");

  //         var nd12 = DateTime.utc(dt.year, dt.month, dt.day, 12);
  //         saveSchedule(nd12, 12);
  //         print("next day: ${nd12.toIso8601String()}");

  //         var nd15 = DateTime.utc(dt.year, dt.month, dt.day, 15);
  //         saveSchedule(nd15, 15);
  //         print("next day: ${nd15.toIso8601String()}");

  //         var nd18 = DateTime.utc(dt.year, dt.month, dt.day, 18);
  //         saveSchedule(nd18, 18);
  //         print("next day: ${nd18.toIso8601String()}");

  //         var nd21 = DateTime.utc(dt.year, dt.month, dt.day, 21);
  //         saveSchedule(nd21, 21);
  //         print("next day: ${nd21.toIso8601String()}");
  //       } else if (dt.hour >= 9 && dt.hour < 12) {
  //         var nd12 = DateTime.utc(dt.year, dt.month, dt.day, 12);
  //         saveSchedule(nd12, 12);
  //         print("next day: ${nd12.toIso8601String()}");

  //         var nd15 = DateTime.utc(dt.year, dt.month, dt.day, 15);
  //         saveSchedule(nd15, 15);
  //         print("next day: ${nd15.toIso8601String()}");

  //         var nd18 = DateTime.utc(dt.year, dt.month, dt.day, 18);
  //         saveSchedule(nd18, 18);
  //         print("next day: ${nd18.toIso8601String()}");

  //         var nd21 = DateTime.utc(dt.year, dt.month, dt.day, 21);
  //         saveSchedule(nd21, 21);
  //         print("next day: ${nd21.toIso8601String()}");
  //       } else if (dt.hour >= 12 && dt.hour < 15) {
  //         var nd15 = DateTime.utc(dt.year, dt.month, dt.day, 15);
  //         saveSchedule(nd15, 15);
  //         print("next day: ${nd15.toIso8601String()}");

  //         var nd18 = DateTime.utc(dt.year, dt.month, dt.day, 18);
  //         saveSchedule(nd18, 18);
  //         print("next day: ${nd18.toIso8601String()}");

  //         var nd21 = DateTime.utc(dt.year, dt.month, dt.day, 21);
  //         saveSchedule(nd21, 21);
  //         print("next day: ${nd21.toIso8601String()}");
  //       } else if (dt.hour >= 15 && dt.hour < 18) {
  //         var nd18 = DateTime.utc(dt.year, dt.month, dt.day, 18);
  //         saveSchedule(nd18, 18);
  //         print("next day: ${nd18.toIso8601String()}");

  //         var nd21 = DateTime.utc(dt.year, dt.month, dt.day, 21);
  //         saveSchedule(nd21, 21);
  //         print("next day: ${nd21.toIso8601String()}");
  //       } else if (dt.hour >= 18 && dt.hour < 21) {
  //         var nd21 = DateTime.utc(dt.year, dt.month, dt.day, 21);
  //         saveSchedule(nd21, 21);
  //         print("next day: ${nd21.toIso8601String()}");
  //       }
  //     }
  //   } else {
  //     localNotifyManager.cancelAllScheduled();
  //   }
  // }

  // Future<QuerySnapshot<Map<String, dynamic>>>
  int i = 0;
  void setSwitch(bool s) {
    setState(() {
      isSwitched = s;

      var now = DateTime.now();
      // var now2 = DateTime.utc(now.year, now.month, now.day, 15);

      startSessions(isSwitched, now, false);
    });
  }

  Future<bool> readSettings() async {
    String id = FirebaseAuth.instance.currentUser!.uid;
    var e = await FirebaseFirestore.instance
        .collection('settings')
        .where("userId", isEqualTo: id)
        .get();

    return e.docs.isNotEmpty ? e.docs[0]["active"] as bool : false;

    // e.then((value) {

    //                 if (value.docs.isNotEmpty) {
    //                   value.docs.forEach((element) {
    //                     return element["active"];
    //                   });
    //                 }
    //               }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> readSession() {
    String id = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .where("userId", isEqualTo: id)
        .where("status", isEqualTo: 0)
        .where("isActive", isEqualTo: true)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    List<String> ids = [];
    ids.add("m4uAoRv8LThXzXvu0qiU");
    ids.add("a8V1hiAJWdEbyqD4FGOB");

    switch (_pageMode) {
      case 1:
        //readSettings().then((val) => isSwitched = val);

        return Scaffold(
          appBar: AppBar(title: const Text("Create Alert")),
          body: GridView.count(
            primary: false,
            padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            crossAxisCount: 2,
            children: [
              SlideSchedule(
                  getStatus: () => readSettings(), setSwitch: setSwitch),
              TextButton(
                  onPressed: () async {
                    // await localNotifyManager.showNotification();
                    // await localNotifyManager.repeatNotification();

                    var now = DateTime.now();
                    var dt = DateTime.now();
                    var mode = 9;
                    var inputFormat = DateFormat('dd/MM/yyyy HH:mm');
                    var inputDate = inputFormat.parse(
                        '${dt.day}/${dt.month}/${dt.year} ${mode.toString()}:00'); // <-- dd/MM 24H format

                    var genId =
                        "${dt.year}-${dt.month}-${dt.day}-${mode.toString()}-${FirebaseAuth.instance.currentUser!.uid}";

                    var packOfQuestions = [
                      {
                        "id": 0,
                        "question": "Kondisi gigi geligi anda saat ini",
                        "option": [
                          "Terpisah",
                          "Berkontak ringan",
                          "Berkontak erat",
                          "Bergemeretak"
                        ],
                        "form": "radio"
                      },
                      {
                        "id": 1,
                        "question":
                            "Kondisi otot wajah/rahang (?) anda saat ini",
                        "option": [
                          "Rileks",
                          "Otot wajah/rahang tegang dan rahang terasa kencang tanpa ada gigi yang berkontak"
                        ],
                        "form": "radio"
                      },
                      {
                        "id": 2,
                        "question":
                            "Apakah anda merasakan nyeri di daerah wajah",
                        "option": ["Ya", "Tidak"],
                        "form": "radio"
                      },
                      {
                        "id": 3,
                        "question": "Bila nyeri, berapa skala nyeri anda?",
                        "option": 10,
                        "form": "scale"
                      }
                    ];

                    var packOfQuestions2 = [
                      {
                        "id": 0,
                        "question": "Kondisi gigi geligi anda saat ini",
                        "option": [
                          "Terpisah",
                          "Berkontak ringan",
                          "Berkontak erat",
                          "Bergemeretak"
                        ],
                        "form": "radio"
                      },
                      {
                        "id": 1,
                        "question":
                            "Kondisi otot wajah/rahang (?) anda saat ini",
                        "option": [
                          "Rileks",
                          "Otot wajah/rahang tegang dan rahang terasa kencang tanpa ada gigi yang berkontak"
                        ],
                        "form": "radio"
                      },
                      {
                        "id": 2,
                        "question":
                            "Apakah anda merasakan nyeri di daerah wajah",
                        "option": ["Ya", "Tidak"],
                        "form": "radio"
                      },
                      // {
                      //   "id": 3,
                      //   "question": "erasa gugup atau tegang",
                      //   "option": ["Ya", "Tidak"]
                      // },
                      {
                        "id": 3,
                        "question": "Kondisi anda hari ini",
                        "option": [
                          "Merasa gugup atau tegang",
                          "Sulit mengontrol kawatir",
                          "Merasa sedih, depresi",
                          "Merasa malas melakukan sesuatu"
                        ],
                        "form": "check"
                      }
                    ];
                    var rng = Random();
                    int rn = rng.nextInt(100);
                    var chosenQuestion =
                        rn % 2 == 0 ? packOfQuestions2 : packOfQuestions;

                    var contextz = {
                      "mode": mode,
                      "ih": dt.hour,
                      "im": dt.minute,
                      "is": dt.second,
                      "init": now.millisecondsSinceEpoch,
                      "end": inputDate.millisecondsSinceEpoch,
                      "date": dt.toIso8601String(),
                      "timestamp": dt.millisecondsSinceEpoch,
                      "status": "onSchedule",
                      "question": "default question",
                      "answer": "default answer",
                      "listQuestions": chosenQuestion,
                      'userId': FirebaseAuth.instance.currentUser!.uid,
                      'genId': genId,
                      'email': FirebaseAuth.instance.currentUser!.email,
                      'name': FirebaseAuth.instance.currentUser!.displayName
                    };
                    // FirebaseFirestore.instance
                    //     .collection("alerts")
                    //     .doc(genId)
                    //     // .doc('settings/' + FirebaseAuth.instance.currentUser!.uid)
                    //     .set(context);

                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (context) {
                    //     return const ViewAlerts();
                    //   },
                    // ));

                    await LocalNotifyManager.init().dailyAtTimeNotification2(
                        999,
                        21,
                        tz.TZDateTime.now(tz.local)
                            .add(const Duration(seconds: 5)),
                        jsonEncode(contextz),
                        "Bruxism Notificaiton",
                        "Rate your pain 1-10");

                    // await LocalNotifyManager.init().dailyAtTimeNotification2(
                    //     998,
                    //     12,
                    //     tz.TZDateTime.now(tz.local)
                    //         .add(const Duration(seconds: 5)),
                    //     jsonEncode(contextz),
                    //     "Bruxism Notificaiton",
                    //     "Rate your pain 1-10");

                    // await LocalNotifyManager.init().dailyAtTimeNotification2(
                    //     997,
                    //     12,
                    //     tz.TZDateTime.now(tz.local)
                    //         .add(const Duration(seconds: 5)),
                    //     jsonEncode(contextz),
                    //     "Bruxism Notificaiton",
                    //     "Rate your pain 1-10");

                    // await localNotifyManager.dailyAtTimeNotification(
                    //     1,
                    //     '2022-3-26-12-JWfkws6uSReUCvYVzmcSyY69esJ3',
                    //     'Bruxism Notificaiton',
                    //     'Rate your pain 1-10');
                  },
                  child: const Text("Notification")),
              TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const ViewAlerts();
                      },
                    ));
                  },
                  child: const Text("View")),
              TextButton(
                  onPressed: () {
                    var storage = LocalStorage("questions");
                    storage.clear();
                  },
                  child: const Text("CLEAR")),
            ],
          ),
          persistentFooterButtons: [
            Flex(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              direction: Axis.horizontal,
              children: [
                BackButton(
                  onPressed: () => _selectPage(0),
                ),
                const Padding(
                    padding: EdgeInsets.all(10.0), child: Text("version 10")),
              ],
            )
          ],
        );
      case 2:
        return Scaffold(
            appBar: AppBar(title: const Text("Nofication")),
            body: Column(
              children: [
                InkWell(
                    child: IconButton(
                  onPressed: () {
                    _sendNotification(context);
                  },
                  icon: const Icon(Icons.access_alarms_outlined, size: 60),
                ))
              ],
            ));
      case 3:
        return Scaffold(
            appBar: AppBar(
              title: const Text("Login"),
            ),
            body: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                PasswordForm(
                  email: "",
                  login: (email, password) {
                    signInWithEmailAndPassword2(
                        email,
                        password,
                        (e) =>
                            _showErrorDialog(context, 'Failed to sign in', e));
                  },
                  selectPage: _selectPage,
                ),
                // const Divider(
                //   height: 10,
                //   thickness: 2,
                //   indent: 20,
                //   endIndent: 0,
                //   color: Colors.grey,
                // ),
                // const SizedBox(
                //   height: 30,
                // ),

                // RegisterForm(
                //   email: "",
                //   cancel: () {
                //     cancelRegistration();
                //   },
                //   registerAccount: (
                //     email,
                //     displayName,
                //     password,
                //   ) {
                //     registerAccount(
                //         email,
                //         displayName,
                //         password,
                //         (e) => _showErrorDialog(
                //             context, 'Failed to create account', e));
                //   },
                // ),
              ],
            ));
      case 4:
        return Scaffold(
          appBar: AppBar(title: const Text("Register")),
          body: RegisterForm(
            email: "",
            cancel: () {
              cancelRegistration();
            },
            registerAccount: (
              email,
              displayName,
              password,
            ) {
              registerAccount(
                  email,
                  displayName,
                  password,
                  (e) =>
                      _showErrorDialog(context, 'Failed to create account', e));
            },
          ),
        );

      case 0:
        return Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
          ),
          body: GridView.count(
              primary: false,
              padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              crossAxisCount: 2,
              children: <Widget>[
                // Container(
                //   padding: const EdgeInsets.only(top: 30, left: 0, right: 0),
                //   child: Text(country ?? "booboe"),
                //   color: Colors.teal[100],
                // ),
                Container(
                  padding: const EdgeInsets.only(top: 30, left: 0, right: 0),
                  child: InkWell(
                    onTap: (() => _selectPage(1)),
                    child: Column(
                      children: [
                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                _selectPage(1);
                              },
                              icon: const Icon(Icons.settings,
                                  color: Colors.white, size: 45),
                            ),
                            const InkWell(
                              child: Center(
                                  child: Padding(
                                padding: EdgeInsets.only(top: 30),
                                child: Text(
                                  "Your Alert ",
                                  style: TextStyle(fontSize: 26),
                                ),
                              )),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  color: Colors.teal[100],
                ),
                // Container(
                //   padding: const EdgeInsets.only(top: 25.0),
                //   child: Column(
                //     children: [
                //       Column(
                //         children: [
                //           IconButton(
                //             onPressed: () {
                //               _selectPage(2);
                //             },
                //             icon: const Icon(Icons.note_alt_outlined,
                //                 color: Colors.white, size: 45),
                //           ),
                //           const InkWell(
                //             child: Center(
                //                 child: Padding(
                //               padding: EdgeInsets.only(top: 35),
                //               child: Text(
                //                 "Heed not the rabble",
                //                 textAlign: TextAlign.center,
                //                 style: TextStyle(
                //                   fontSize: 25,
                //                 ),
                //               ),
                //             )),
                //           )
                //         ],
                //       )
                //     ],
                //   ),
                //   color: Colors.teal[200],
                // ),
                Container(
                  // padding: const EdgeInsets.all(8),
                  child: Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20.0,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.wysiwyg,
                              color: Colors.white,
                              size: 45,
                            ),
                            onPressed: () => signOut(),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          const Text(
                            "Sign Out",
                            style: TextStyle(fontSize: 25.0),
                          )
                        ],
                      )

                      // StyledButton(
                      //     child: const Text("Sign Out"),
                      //     onPressed: () => signOut()),
                      ),
                  color: Colors.grey,
                ),
                // Container(
                //   padding: const EdgeInsets.all(8),
                //   child: const Text('Who scream'),
                //   color: Colors.teal[400],
                // ),
                // Container(
                //   padding: const EdgeInsets.all(8),
                //   child: const Text('Revolution is coming...'),
                //   color: Colors.teal[500],
                // ),
                // Container(
                //   padding: const EdgeInsets.all(8),
                //   child: const Text('Revolution, they...'),
                //   color: Colors.teal[600],
                // ),
              ]),
        );
      default:
        return Scaffold(
          appBar: AppBar(title: const Text("Info")),
          body:
              const Padding(padding: EdgeInsets.all(10.0), child: Text("SSSS")),
        );
    }
  }
}

class SlideSchedule extends StatelessWidget {
  SlideSchedule({Key? key, required this.getStatus, required this.setSwitch})
      : super(key: key);
  late Function getStatus;
  late Function(bool a) setSwitch;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    "OFF",
                    style: TextStyle(fontSize: 12.0, fontFamily: 'roboto'),
                  )),
              Switch(
                  value: snapshot.data as bool,
                  onChanged: (value) {
                    setSwitch(value);
                  }),
              const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                  child: Text("ON",
                      style: TextStyle(fontSize: 12.0, fontFamily: 'roboto'))),
            ],
          );
        } else {
          return const SizedBox(
            height: 10.0,
          );
        }
      },
      future: getStatus(),
    );
  }
}

class NotificationBadge extends StatelessWidget {
  final int totalNotifications;

  const NotificationBadge({required this.totalNotifications});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Container(
      width: 40.0,
      height: 40.0,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '$totalNotifications',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}

class PushNotification {
  PushNotification({
    this.title,
    this.body,
  });
  String? title;
  String? body;
}

class AlertObj {
  AlertObj({this.start, this.title});
  String? title;
  int? start;
  String? question;
  String? answer;
}

class PasswordForm extends StatefulWidget {
  const PasswordForm(
      {required this.login, required this.email, required this.selectPage});
  final String email;
  final void Function(String email, String password) login;
  final void Function(int page) selectPage;
  @override
  _PasswordFormState createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_PasswordFormState');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static const lsMargin = 15.0;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    print(widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header('Sign in'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email address to continue';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // const SizedBox(width: 3),
                            // Padding(
                            //   padding: const EdgeInsets.only(left: lsMargin),
                            //   child: StyledButton(
                            //     onPressed: () {},
                            //     child: const Text('Register'),
                            //   ),
                            // ),
                            // const SizedBox(width: 16),

                            Padding(
                              padding: const EdgeInsets.only(right: lsMargin),
                              child: StyledButton(
                                onPressed: () {
                                  widget.selectPage(4);
                                },
                                child: const Text('REGISTER'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: lsMargin),
                              child: StyledButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    widget.login(
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                                  }
                                },
                                child: const Text('SIGN IN'),
                              ),
                            )

                            // const SizedBox(width: 3),
                          ],
                        ),
                        Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextButton(
                              onPressed: () {
                                widget.selectPage(0);
                              },
                              child: const Text("Forgot password"),
                            )),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StyledButton extends StatelessWidget {
  const StyledButton({required this.child, required this.onPressed});
  final Widget child;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.deepPurple)),
        onPressed: onPressed,
        child: child,
      );
}

class Header extends StatelessWidget {
  const Header(this.heading);
  final String heading;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          heading,
          style: const TextStyle(fontSize: 24),
        ),
      );
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    required this.registerAccount,
    required this.cancel,
    required this.email,
  });
  final String email;
  final void Function(String email, String displayName, String password)
      registerAccount;
  final void Function() cancel;
  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>(debugLabel: '_RegisterFormState');
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header('Create account'),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your email address to continue';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      hintText: 'First & last name',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your account name';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter your password';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.cancel,
                        child: const Text('CANCEL'),
                      ),
                      const SizedBox(width: 16),
                      StyledButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.registerAccount(
                              _emailController.text,
                              _displayNameController.text,
                              _passwordController.text,
                            );
                          }
                        },
                        child: const Text('SAVE'),
                      ),
                      const SizedBox(width: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
