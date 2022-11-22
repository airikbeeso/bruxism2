import 'dart:convert';
import 'dart:ffi';

import 'dart:math';

import 'package:bruxism2/SecondScreen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'forgotPassword.dart';
import 'notificationservice.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LocalNotifyManager.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;

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

  String? _token;

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
    // _token = await FirebaseMessaging.instance.getAPNSToken();
    _token = await FirebaseMessaging.instance.getToken();

    print("token....${_token.toString()}");

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
    LocalStorage storage = LocalStorage('questions');
    final QitemList list = QitemList();

    // var list = [];
    var now = DateTime.now();
    var inputFormat = DateFormat('dd/MM/yyyy HH:mm');
    var inputDate = inputFormat.parse(
        '${dt.day}/${dt.month}/${dt.year} ${mode.toString()}:00'); // <-- dd/MM 24H format

    var genId =
        "${dt.year}-${dt.month}-${dt.day}-${mode.toString()}-${FirebaseAuth.instance.currentUser!.uid}";

    var qa = storage.getItem("questions");

    _clearStorage() async {
      await storage.clear();
      setState(() {
        list.items = storage.getItem('questions') ?? [];
      });
    }

    _saveToStorage() {
      storage.setItem('questions', list.toJSONEncodable());
    }

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
        "form": "radio",
        "isOptional": "false"
      },
      {
        "id": 1,
        "question": "Kondisi otot wajah/rahang (?) anda saat ini",
        "option": [
          "Rileks",
          "Otot wajah/rahang tegang dan rahang terasa kencang tanpa ada gigi yang berkontak"
        ],
        "form": "radio",
        "isOptional": "false"
      },
      {
        "id": 2,
        "question": "Apakah anda merasakan nyeri di daerah wajah",
        "option": ["Ya", "Tidak"],
        "form": "radio",
        "isOptional": "false"
      },
      {
        "id": 3,
        "question":
            "Bila nyeri, berapa skala nyeri anda? 0 - tidak nyeri ;  10 - nyeri yang tidak tertahankan",
        "option": 5,
        "form": "scale",
        "isOptional": "false"
      },
      {
        "id": 4,
        "question": "Kondisi anda hari ini",
        "option": [
          "Merasa gugup atau tegang",
          "Sulit mengontrol kawatir",
          "Merasa sedih, depresi",
          "Merasa malas melakukan sesuatu"
        ],
        "form": "check",
        "isOptional": "yes"
      }
    ];
    var rng = Random();
    int rn = rng.nextInt(100);
    var chosenQuestion =
        packOfQuestions2; // rn % 2 == 0 ? packOfQuestions2 : packOfQuestions;
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

    // Qitem context2 = {
    //   "mode": mode,
    //   "ih": dt.hour,
    //   "im": dt.minute,
    //   "isec": dt.second,
    //   "init": now.millisecondsSinceEpoch,
    //   "end": inputDate.millisecondsSinceEpoch,
    //   "date": dt.toIso8601String(),
    //   "timestamp": dt.millisecondsSinceEpoch,
    //   "status": "onSchedule",
    //   "question": "default question",
    //   "answer": "default answer",
    //   "listQuestions": chosenQuestion,
    //   'userId': FirebaseAuth.instance.currentUser!.uid,
    //   'genId': genId,
    //   'email': FirebaseAuth.instance.currentUser!.email,
    //   'name': FirebaseAuth.instance.currentUser!.displayName,
    //   'answerOn': 0
    // } as Qitem;

    // list.items.add(context2);

    FirebaseFirestore.instance
        .collection("questions")
        .doc(genId)
        // .doc('settings/' + FirebaseAuth.instance.currentUser!.uid)
        .set(context);

    // String? token = await FirebaseMessaging.instance.getAPNSToken();
    // print("token: ${token.toString()}");

    ///////////*Firebase message *//////////
    // sendPushMessage("Please change", context);
    ////////////////////////////////////////
    // _saveToStorage();

    await LocalNotifyManager.init().dailyAtTimeNotification(
        _id,
        mode,
        dt,
        jsonEncode(context),
        "Bruxism Notification",
        "Rate your pain, Jam $mode");
  }

  String constructFCMPayload(String? token, String msg, dynamic context) {
    return jsonEncode({
      'token': token,
      'data': {
        'via': 'FlutterFire Cloud Messaging!!!',
        'count': "2",
      },
      'notification': {
        'title': 'Firebase message',
        'body': msg,
      },
    });
  }

  Future<void> sendPushMessage(String msg, dynamic context) async {
    // String? token = await FirebaseMessaging.instance.getAPNSToken();
    // _token = token;

    _token = await FirebaseMessaging.instance.getToken();

    if (_token == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://api.rnfirebase.io/messaging/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(_token, msg, context),
      );
      print('FCM request for device sent!');
    } catch (e) {
      print(e);
    }
  }

  Future<void> startSessions_test(
      bool isActive, DateTime dt, bool repeat) async {
    LocalStorage storage = LocalStorage('questions');
    storage.setItem("initial_date_time", DateTime.now().millisecondsSinceEpoch);

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
      for (var i = 1; i <= 14; i++) {
        dt = dt.add(Duration(days: i));
        print(dt);

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

  Future<int> checkOnPendingNotification() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotificationRequests.length;
  }

  Future<void> _checkPendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content:
            Text('${pendingNotificationRequests.length} pending notification '
                'requests'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showOngoingNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ongoing: true,
            autoCancel: false);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'ongoing notification title',
        'ongoing notification body', platformChannelSpecifics);
  }

  Future<void> _startForegroundServiceWithBlueBackgroundNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'color background channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      color: Colors.blue,
      colorized: true,
    );

    /// only using foreground service can color the background
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.startForegroundService(
            1, 'colored background text title', 'colored background text body',
            notificationDetails: androidPlatformChannelSpecifics,
            payload: 'item x');
  }

  int i = 0;

  int pending = 0;
  setSwitch(bool s) async {
    setState(() {
      checkOnPendingNotification().then((value) {
        pending = value;
        isSwitched = s;

        var now = DateTime.now();
        // var now2 = DateTime.utc(now.year, now.month, now.day, 15);

        startSessions(isSwitched, now, false);
      });

      // print("WWWWWWW");
      // startSessions_test(isSwitched, now, false);
    });
    return pending;
  }

  Future getBruxUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    return auth.currentUser;
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
    // var m = "init date";
    // bool initialized = false;

    // final LocalStorage storage = LocalStorage('questions');
    // var img = Image.asset(
    //   "assets/images/Brux_core.png",
    //   height: 120,
    //   width: 120,
    // );

    // checkOnPendingNotification().then((value) {
    //   if (value == 0) {
    //     var now = DateTime.now();
    //     // var now2 = DateTime.utc(now.year, now.month, now.day, 15);

    //     startSessions(true, now, false);
    //   }
    // });

    switch (_pageMode) {
      case 0:
        // var img = Image.asset(
        //   "assets/images/Brux_core.png",
        //   height: 120,
        //   width: 120,
        // );
        var ret = Scaffold(
            bottomNavigationBar: BruxismBottomNavigation(
              selectPage: _selectPage,
              idx: 0,
            ),

            // persistentFooterButtons: <Widget>[
            //   IconButton(
            //       icon: const Icon(Icons.logout), onPressed: () => signOut()),
            // ],
            body: Center(
              child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: Image.asset("assets/images/bg.png").image,
                        fit: BoxFit.cover),
                  ),
                  child:

                      // GlassmorphicContainer(
                      //   width: MediaQuery.of(context).size.width * 0.9,
                      //   height: MediaQuery.of(context).size.height * 0.9,
                      //   borderRadius: 0,
                      //   blur: 7,
                      //   alignment: Alignment.bottomCenter,
                      //   border: 0,
                      //   linearGradient: LinearGradient(
                      //       begin: Alignment.topLeft,
                      //       end: Alignment.bottomRight,
                      //       colors: [
                      //         const Color(0xFFF75035).withAlpha(55),
                      //         const Color(0xFFffffff).withAlpha(45),
                      //       ],
                      //       stops: const [
                      //         0.3,
                      //         1
                      //       ]),
                      //   borderGradient: LinearGradient(
                      //       begin: Alignment.bottomRight,
                      //       end: Alignment.topLeft,
                      //       colors: [
                      //         const Color(0xFF4579C5).withAlpha(100),
                      //         const Color(0xFFffffff).withAlpha(55),
                      //         const Color(0xFFF75035).withAlpha(10),
                      //       ],
                      //       stops: const [
                      //         0.06,
                      //         0.95,
                      //         1
                      //       ]),
                      //   child: Column(children: [
                      //     // Expanded(
                      //     //     child: Stack(
                      //     //   fit: StackFit.expand,
                      //     //   children: [
                      //     Positioned(
                      //       bottom: MediaQuery.of(context).size.height * 0.3 * 70,
                      //       left: 40,
                      //       child: Container(
                      //         width: 100,
                      //         height: 100.0,
                      //         decoration: const BoxDecoration(
                      //             shape: BoxShape.circle,
                      //             gradient: LinearGradient(colors: [
                      //               Color(0xFFBC1642),
                      //               Color(0xFFCB5AC6),
                      //             ])),
                      //       ),
                      //     ),
                      //     Positioned(
                      //       bottom: 50,
                      //       left: 30,
                      //       child: Container(
                      //         width: 80,
                      //         height: 40,
                      //         decoration: const BoxDecoration(
                      //             shape: BoxShape.rectangle,
                      //             gradient: LinearGradient(colors: [
                      //               Color(0xFFFDFC47),
                      //               Color(0xFF24FE41),
                      //             ])),
                      //       ),
                      //     ),
                      // Column(children: [
                      // SizedBox(
                      //     height: 30, width: MediaQuery.of(context).size.width),
                      // img,
                      // SizedBox(
                      //     height: 10, width: MediaQuery.of(context).size.width),
                      GlassmorphicContainer(
                    width: MediaQuery.of(context).size.width * 0.9 - 20,
                    height: MediaQuery.of(context).size.height * 0.7 - 20,
                    borderRadius: 35,
                    margin: const EdgeInsets.all(10),
                    blur: 10,
                    alignment: Alignment.bottomCenter,
                    border: 1,
                    linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFFFFF).withAlpha(0),
                          const Color(0xFFFFFFFF).withAlpha(0),
                        ],
                        stops: const [
                          0.3,
                          1,
                        ]),
                    borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFFFFFF).withAlpha(01),
                          const Color(0xFFFFFFFF).withAlpha(100),
                          const Color(0xFFFFFFFF).withAlpha(01),
                        ],
                        stops: const [
                          0.2,
                          0.9,
                          1
                        ]),
                    child: GridView.count(
                        primary: false,
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 10),
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                        crossAxisCount: 1,
                        children: <Widget>[
                          Image.asset(
                            "assets/images/Brux_core.png",
                            height: 120,
                            width: 120,
                          ),
                          GlassContainer(
                            height: 200,
                            width: 200,
                            blur: 4,
                            color: Colors.white.withOpacity(0.7),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.blue.withOpacity(0.3),
                              ],
                            ),
                            //--code to remove border
                            border:
                                const Border.fromBorderSide(BorderSide.none),
                            shadowStrength: 5,
                            shape: BoxShape.circle,
                            borderRadius: BorderRadius.circular(16),
                            shadowColor: Colors.white.withOpacity(0.24),
                            child: SlideSchedule(
                                startSessions: startSessions,
                                checkPending: checkOnPendingNotification,
                                pending: pending,
                                getStatus: () => readSettings(),
                                setSwitch: setSwitch),
                            // ],
                          ),

                          // GlassContainer(
                          //     height: 200,
                          //     width: 200,
                          //     blur: 4,
                          //     color: Colors.white.withOpacity(0.7),
                          //     gradient: LinearGradient(
                          //       begin: Alignment.topLeft,
                          //       end: Alignment.bottomRight,
                          //       colors: [
                          //         Colors.white.withOpacity(0.2),
                          //         Colors.blue.withOpacity(0.3),
                          //       ],
                          //     ),
                          //     //--code to remove border
                          //     border: const Border.fromBorderSide(
                          //         BorderSide.none),
                          //     shadowStrength: 5,
                          //     shape: BoxShape.rectangle,
                          //     borderRadius: BorderRadius.circular(16),
                          //     shadowColor: Colors.white.withOpacity(0.24),
                          //     child: TextButton(
                          //         onPressed:
                          //             _checkPendingNotificationRequests,
                          //         child: const Text(
                          //           "Pending Notification",
                          //           style: TextStyle(fontSize: 12),
                          //         ))),

                          // GlassContainer(
                          //     height: 200,
                          //     width: 200,
                          //     blur: 4,
                          //     color: Colors.white.withOpacity(0.7),
                          //     gradient: LinearGradient(
                          //       begin: Alignment.topLeft,
                          //       end: Alignment.bottomRight,
                          //       colors: [
                          //         Colors.white.withOpacity(0.2),
                          //         Colors.blue.withOpacity(0.3),
                          //       ],
                          //     ),
                          //     //--code to remove border
                          //     border: const Border.fromBorderSide(
                          //         BorderSide.none),
                          //     shadowStrength: 5,
                          //     shape: BoxShape.rectangle,
                          //     borderRadius: BorderRadius.circular(16),
                          //     shadowColor: Colors.white.withOpacity(0.24),
                          //     child: TextButton(
                          //         onPressed:
                          //             _startForegroundServiceWithBlueBackgroundNotification,
                          //         child: const Text(
                          //           "Active Notification",
                          //           style: TextStyle(fontSize: 12),
                          //         ))),

                          // const Center(
                          //   child: Padding(
                          //       padding: EdgeInsets.only(left: 30),
                          //       child: Text(
                          //         "Ver. 17",
                          //         style: TextStyle(
                          //             color: Colors.white,
                          //             fontSize: 30),
                          //       )),
                          // ),

                          // GlassContainer(
                          //     height: 200,
                          //     width: 200,
                          //     blur: 4,
                          //     color: Colors.white.withOpacity(0.7),
                          //     gradient: LinearGradient(
                          //       begin: Alignment.topLeft,
                          //       end: Alignment.bottomRight,
                          //       colors: [
                          //         Colors.white.withOpacity(0.2),
                          //         Colors.blue.withOpacity(0.3),
                          //       ],
                          //     ),
                          //     //--code to remove border
                          //     border: const Border.fromBorderSide(
                          //         BorderSide.none),
                          //     shadowStrength: 5,
                          //     shape: BoxShape.rectangle,
                          //     borderRadius: BorderRadius.circular(16),
                          //     shadowColor: Colors.white.withOpacity(0.24),
                          //     child: Flex(
                          //       crossAxisAlignment:
                          //           CrossAxisAlignment.start,
                          //       mainAxisAlignment:
                          //           MainAxisAlignment.spaceBetween,
                          //       direction: Axis.horizontal,
                          //       children: const [
                          //         // Padding(
                          //         //   padding: const EdgeInsets.only(
                          //         //       top: 35.0, left: 20.0),
                          //         //   child: BackButton(
                          //         //       color: Colors.white,
                          //         //       onPressed: () => _selectPage(0)),
                          //         // ),
                          //         Center(
                          //           child: Padding(
                          //               padding: EdgeInsets.only(left: 30),
                          //               child: Text(
                          //                 "version 14",
                          //                 style: TextStyle(
                          //                     color: Colors.white),
                          //               )),
                          //         ),
                          //       ],
                          //     )),

                          // TextButton(
                          //     onPressed: () async {
                          //       // await localNotifyManager.showNotification();
                          //       // await localNotifyManager.repeatNotification();

                          //       var now = DateTime.now();
                          //       var dt = DateTime.now();
                          //       var mode = 9;
                          //       var inputFormat =
                          //           DateFormat('dd/MM/yyyy HH:mm');
                          //       var inputDate = inputFormat.parse(
                          //           '${dt.day}/${dt.month}/${dt.year} ${mode.toString()}:00'); // <-- dd/MM 24H format

                          //       var genId =
                          //           "${dt.year}-${dt.month}-${dt.day}-${mode.toString()}-${FirebaseAuth.instance.currentUser!.uid}";

                          //       var packOfQuestions = [
                          //         {
                          //           "id": 0,
                          //           "question":
                          //               "Kondisi gigi geligi anda saat ini",
                          //           "option": [
                          //             "Terpisah",
                          //             "Berkontak ringan",
                          //             "Berkontak erat",
                          //             "Bergemeretak"
                          //           ],
                          //           "form": "radio"
                          //         },
                          //         {
                          //           "id": 1,
                          //           "question":
                          //               "Kondisi otot wajah/rahang (?) anda saat ini",
                          //           "option": [
                          //             "Rileks",
                          //             "Otot wajah/rahang tegang dan rahang terasa kencang tanpa ada gigi yang berkontak"
                          //           ],
                          //           "form": "radio"
                          //         },
                          //         {
                          //           "id": 2,
                          //           "question":
                          //               "Apakah anda merasakan nyeri di daerah wajah",
                          //           "option": ["Ya", "Tidak"],
                          //           "form": "radio"
                          //         },
                          //         {
                          //           "id": 3,
                          //           "question":
                          //               "Bila nyeri, berapa skala nyeri anda?",
                          //           "option": 5,
                          //           "form": "scale"
                          //         }
                          //       ];

                          //       var packOfQuestions2 = [
                          //         {
                          //           "id": 0,
                          //           "question":
                          //               "Kondisi gigi geligi anda saat ini",
                          //           "option": [
                          //             "Terpisah",
                          //             "Berkontak ringan",
                          //             "Berkontak erat",
                          //             "Bergemeretak"
                          //           ],
                          //           "form": "radio"
                          //         },
                          //         {
                          //           "id": 1,
                          //           "question":
                          //               "Kondisi otot wajah/rahang (?) anda saat ini",
                          //           "option": [
                          //             "Rileks",
                          //             "Otot wajah/rahang tegang dan rahang terasa kencang tanpa ada gigi yang berkontak"
                          //           ],
                          //           "form": "radio"
                          //         },
                          //         {
                          //           "id": 2,
                          //           "question":
                          //               "Apakah anda merasakan nyeri di daerah wajah",
                          //           "option": ["Ya", "Tidak"],
                          //           "form": "radio"
                          //         },
                          //         {
                          //           "id": 3,
                          //           "question": "Kondisi anda hari ini",
                          //           "option": [
                          //             "Merasa gugup atau tegang",
                          //             "Sulit mengontrol kawatir",
                          //             "Merasa sedih, depresi",
                          //             "Merasa malas melakukan sesuatu"
                          //           ],
                          //           "form": "check"
                          //         }
                          //       ];
                          //       var rng = Random();
                          //       int rn = rng.nextInt(100);
                          //       var chosenQuestion = rn % 2 == 0
                          //           ? packOfQuestions2
                          //           : packOfQuestions;

                          //       var contextz = {
                          //         "mode": mode,
                          //         "ih": dt.hour,
                          //         "im": dt.minute,
                          //         "is": dt.second,
                          //         "init": now.millisecondsSinceEpoch,
                          //         "end": inputDate.millisecondsSinceEpoch,
                          //         "date": dt.toIso8601String(),
                          //         "timestamp": dt.millisecondsSinceEpoch,
                          //         "status": "onSchedule",
                          //         "question": "default question",
                          //         "answer": "default answer",
                          //         "listQuestions": chosenQuestion,
                          //         'userId': FirebaseAuth
                          //             .instance.currentUser!.uid,
                          //         'genId': genId,
                          //         'email': FirebaseAuth
                          //             .instance.currentUser!.email,
                          //         'name': FirebaseAuth
                          //             .instance.currentUser!.displayName
                          //       };

                          //       await LocalNotifyManager.init()
                          //           .dailyAtTimeNotification2(
                          //               999,
                          //               21,
                          //               tz.TZDateTime.now(tz.local).add(
                          //                   const Duration(seconds: 5)),
                          //               jsonEncode(contextz),
                          //               "Bruxism Notification",
                          //               "Rate your pain 1-10");

                          //       sendPushMessage("Please change", contextz);
                          //     },
                          //     child: const Text("Notification")),

                          // TextButton(
                          //     onPressed: () {
                          //       Navigator.push(context, MaterialPageRoute(
                          //         builder: (context) {
                          //           return const ViewAlerts();
                          //         },
                          //       ));
                          //     },
                          //     child: const Text("View")),
                          // ClipRRect(
                          //   borderRadius: BorderRadius.circular(25),
                          //   child: BackdropFilter(
                          //     filter:
                          //         ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          //     child: Container(
                          //       height: 250,
                          //       width: 350,
                          //       decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular(25),
                          //           color: Colors.black45),
                          //       child: TextButton(
                          //           onPressed: () {
                          //             var storage =
                          //                 LocalStorage("questions");
                          //             storage.clear();
                          //           },
                          //           child: const Text("CLEAR")),
                          //     ),
                          //   ),
                          // ),

                          // Container(
                          //   padding: const EdgeInsets.all(10.0),
                          //   constraints: const BoxConstraints.expand(),
                          //   child: FutureBuilder(
                          //       future: storage.ready,
                          //       builder: (BuildContext context,
                          //           AsyncSnapshot snapshot) {
                          //         if (snapshot.data == null) {
                          //           return const Center(
                          //             child: CircularProgressIndicator(),
                          //           );
                          //         }
                          //         if (!initialized) {
                          //           var items = storage
                          //               .getItem("initial_date_time");
                          //           if (items != null) {
                          //             return Text(DateFormat(
                          //                     'MM/dd/yyyy hh:mm a')
                          //                 .format(DateTime
                          //                     .fromMillisecondsSinceEpoch(
                          //                         items)));
                          //           }
                          //           initialized = true;
                          //         }
                          //         return const Text("Wwww");
                          //       }),
                          // )
                        ]),
                  )
                  // ]),
                  // ],
                  // ))
                  // ]),
                  //   ),
                  ),
            ));

/*

      case 44:
        //readSettings().then((val) => isSwitched = val);

        return ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.8)
                      ],
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                      width: 1.5, color: Colors.white.withOpacity(0.2))),
              child: Scaffold(
                appBar: AppBar(title: const Text("Create Alert")),
                backgroundColor: Colors.greenAccent,
                body: GridView.count(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                              "question":
                                  "Bila nyeri, berapa skala nyeri anda?",
                              "option": 5,
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
                            'name':
                                FirebaseAuth.instance.currentUser!.displayName
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

                          await LocalNotifyManager.init()
                              .dailyAtTimeNotification2(
                                  999,
                                  21,
                                  tz.TZDateTime.now(tz.local)
                                      .add(const Duration(seconds: 5)),
                                  jsonEncode(contextz),
                                  "Bruxism Notification",
                                  "Rate your pain 1-10");

                          sendPushMessage("Please change", contextz);

                          // await LocalNotifyManager.init().dailyAtTimeNotification2(
                          //     998,
                          //     12,
                          //     tz.TZDateTime.now(tz.local)
                          //         .add(const Duration(seconds: 5)),
                          //     jsonEncode(contextz),
                          //     "Bruxism Notification",
                          //     "Rate your pain 1-10");

                          // await LocalNotifyManager.init().dailyAtTimeNotification2(
                          //     997,
                          //     12,
                          //     tz.TZDateTime.now(tz.local)
                          //         .add(const Duration(seconds: 5)),
                          //     jsonEncode(contextz),
                          //     "Bruxism Notification",
                          //     "Rate your pain 1-10");

                          // await localNotifyManager.dailyAtTimeNotification(
                          //     1,
                          //     '2022-3-26-12-JWfkws6uSReUCvYVzmcSyY69esJ3',
                          //     'Bruxism Notification',
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          height: 250,
                          width: 350,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.black45),
                          child: TextButton(
                              onPressed: () {
                                var storage = LocalStorage("questions");
                                storage.clear();
                              },
                              child: const Text("CLEAR")),
                        ),
                      ),
                    ),
                    // TextButton(
                    //     onPressed: () {
                    //       var storage = LocalStorage("questions");
                    //       storage.clear();
                    //     },
                    //     child: const Text("CLEAR")),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      constraints: const BoxConstraints.expand(),
                      child: FutureBuilder(
                          future: storage.ready,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.data == null) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!initialized) {
                              var items = storage.getItem("initial_date_time");
                              if (items != null) {
                                return Text(DateFormat('MM/dd/yyyy hh:mm a')
                                    .format(DateTime.fromMillisecondsSinceEpoch(
                                        items)));
                              }
                              initialized = true;
                            }
                            return const Text("Wwww");
                          }),
                    )
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
                          padding: EdgeInsets.all(10.0),
                          child: Text("version 10")),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
        */
        return ret; //Expanded(flex: 1, child: ret);

      case 2:
        return Scaffold(
            bottomNavigationBar: BruxismBottomNavigation(
              selectPage: _selectPage,
              idx: 2,
            ),
            appBar: AppBar(title: const Text("Nofication")),
            body: Column(
              children: const [
                // InkWell(
                //     child: IconButton(
                //   onPressed: () {
                //     _sendNotification(context);
                //   },
                //   icon: const Icon(Icons.access_alarms_outlined, size: 60),
                // )),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Ver. 20\n\nNote:\n\nTurn the slider On will get\nnotification",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'roboto'),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 6,
                    )),
              ],
            ));
      case 3:
        return Scaffold(
            // appBar: AppBar(
            //   title: const Text("Login"),
            // ),
            body: Center(
                child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: Image.asset("assets/images/bg.png").image,
                          fit: BoxFit.cover),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        PasswordForm(
                          email: "",
                          login: (email, password) {
                            signInWithEmailAndPassword2(
                                email,
                                password,
                                (e) => _showErrorDialog(
                                    context, 'Failed to sign in', e));
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
                    ))));
      case 4:
        return GlassContainer(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width,
            blur: 4,
            color: Colors.white.withOpacity(0.7),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.blue.withOpacity(0.3),
              ],
            ),
            //--code to remove border
            border: const Border.fromBorderSide(BorderSide.none),
            shadowStrength: 5,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            shadowColor: Colors.white.withOpacity(0.24),
            child: Scaffold(
                body: Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: Image.asset("assets/images/bg.png").image,
                    fit: BoxFit.cover),
              ),
              child: RegisterForm(
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
                      (e) => _showErrorDialog(
                          context, 'Failed to create account', e));
                },
              ),
            )));

      case 1:
        const double gheight = 180;
        return Scaffold(
            bottomNavigationBar: BruxismBottomNavigation(
              selectPage: _selectPage,
              idx: 1,
            ),
            // appBar: AppBar(
            //   // Here we take the value from the MyHomePage object that was created by
            //   // the App.build method, and use it to set our appbar title.
            //   title: Text(widget.title),
            // ),
            body: Center(
              child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: Image.asset("assets/images/bg.png").image,
                        fit: BoxFit.cover),
                  ),
                  child: GlassmorphicContainer(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.9,
                      borderRadius: 0,
                      margin: const EdgeInsets.fromLTRB(10, 50, 10, 10),
                      blur: 7,
                      alignment: Alignment.bottomCenter,
                      border: 0,
                      linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFF75035).withAlpha(55),
                            const Color(0xFFffffff).withAlpha(45),
                          ],
                          stops: const [
                            0.3,
                            1
                          ]),
                      borderGradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          end: Alignment.topLeft,
                          colors: [
                            const Color(0xFF4579C5).withAlpha(100),
                            const Color(0xFFffffff).withAlpha(55),
                            const Color(0xFFF75035).withAlpha(10),
                          ],
                          stops: const [
                            0.06,
                            0.95,
                            1
                          ]),
                      child: GridView(
                        controller: ScrollController(),
                        physics: const ScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.all(24.0),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400.0,
                          mainAxisExtent: 140.0,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                        ),
                        children: [
                          GlassContainer(
                              height: gheight,
                              width: MediaQuery.of(context).size.width,
                              blur: 4,
                              color: Colors.white.withOpacity(0.7),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.blue.withOpacity(0.3),
                                ],
                              ),
                              //--code to remove border
                              border:
                                  const Border.fromBorderSide(BorderSide.none),
                              shadowStrength: 5,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(16),
                              shadowColor: Colors.white.withOpacity(0.24),
                              child: BruxUser(getUser: getBruxUser)),
                          GlassContainer(
                            height: gheight,
                            width: MediaQuery.of(context).size.width,
                            blur: 4,
                            color: Colors.white.withOpacity(0.7),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.blue.withOpacity(0.3),
                              ],
                            ),
                            //--code to remove border
                            border:
                                const Border.fromBorderSide(BorderSide.none),
                            shadowStrength: 5,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(16),
                            shadowColor: Colors.white.withOpacity(0.24),
                            child: InkWell(
                                onTap: (() =>
                                    _checkPendingNotificationRequests()),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _checkPendingNotificationRequests(),
                                      icon: const Icon(Icons.notifications,
                                          color: Colors.white, size: 45),
                                    ),
                                    const InkWell(
                                      child: Center(
                                          child: Padding(
                                        padding: EdgeInsets.only(top: 30),
                                        child: Text(
                                          "Pending Notifications",
                                          style: TextStyle(
                                              fontSize: 26,
                                              color: Colors.white30),
                                        ),
                                      )),
                                    ),
                                  ],
                                )),
                          ),
                          GlassContainer(
                            height: gheight,
                            width: MediaQuery.of(context).size.width,
                            blur: 4,
                            color: Colors.white.withOpacity(0.7),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.2),
                                Colors.blue.withOpacity(0.3),
                              ],
                            ),
                            //--code to remove border
                            border:
                                const Border.fromBorderSide(BorderSide.none),
                            shadowStrength: 5,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(16),
                            shadowColor: Colors.white.withOpacity(0.24),
                            child: InkWell(
                                onTap: (() => signOut()),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 20.0,
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.logout,
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
                                      style: TextStyle(
                                          fontSize: 25.0,
                                          color: Colors.white24),
                                    )
                                  ],
                                )),
                          ),
                        ],
                      ))),
            ));

      case 5:
        return StreamBuilder<Object>(
            stream: null,
            builder: (context, snapshot) {
              return Center(child: ForgotPassword());
            });
      default:
        return Scaffold(
          appBar: AppBar(title: const Text("Info")),
          body:
              const Padding(padding: EdgeInsets.all(10.0), child: Text("SSSS")),
        );
    }
  }
}

class BruxUser extends StatelessWidget {
  final Function getUser;
  const BruxUser({Key? key, required this.getUser});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // print(snapshot.data);
          User user = snapshot.data as User;

          return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    user.displayName.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text("Email : " + user.email.toString(),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 20)),
                  Text("Varified: " + user.emailVerified.toString(),
                      style:
                          const TextStyle(color: Colors.white, fontSize: 20)),
                ],
              ));
        } else {
          return const Text("");
        }
      },
      future: getUser(),
    );
  }
}

class SlideSchedule extends StatelessWidget {
  SlideSchedule(
      {Key? key,
      required this.getStatus,
      required this.setSwitch,
      required this.checkPending,
      required this.startSessions,
      required this.pending})
      : super(key: key);
  late Function getStatus;
  late Function(bool a) setSwitch;
  late Function checkPending;
  late Function startSessions;
  late int pending;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Padding(
                        padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: Text(
                          "OFF",
                          style: TextStyle(
                              fontSize: 25.0,
                              fontFamily: 'roboto',
                              color: Colors.white),
                        )),
                    Switch(
                        value: snapshot.data as bool,
                        onChanged: (value) {
                          setSwitch(value).then((r) => pending = r);
                          // print(pending);
                          // if(true == value && pending == 0)
                          // {
                          //   setSwitch(false);

                          // }

                          // checkPending().then((r) {
                          //   pending = r;
                          //   if (pending == 0) {
                          //     setSwitch(false);
                          //   }
                          // });

                          // if (value) {
                          //   checkPending().then((value) {
                          //     if (value == 0) {
                          //       var now = DateTime.now();
                          //       // var now2 = DateTime.utc(now.year, now.month, now.day, 15);

                          //       startSessions(true, now, false);
                          //     }
                          //   });
                          // }
                        }),
                    const Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: Text("ON",
                            style: TextStyle(
                                fontSize: 25.0,
                                fontFamily: 'roboto',
                                color: Colors.white))),
                  ],
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      "$pending pending",
                      style:
                          const TextStyle(color: Colors.orange, fontSize: 25),
                    ),
                  ),
                ),
              ]);
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

class BruxismBottomNavigation extends StatelessWidget {
  final Function selectPage;
  final int idx;

  const BruxismBottomNavigation(
      {Key? key, required this.idx, required this.selectPage})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
        initialActiveIndex: idx,
        items: const [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.people, title: 'Discovery'),
          TabItem(icon: Icons.message, title: 'Message'),
          // TabItem(icon: Icons.people, title: 'Profile'),
          // TabItem(icon: Icons.settings, title: 'Settings'),
        ],
        onTap: (int i) {
          switch (i) {
            case 0:
              {
                selectPage(0);
              }
              break;
            case 1:
              {
                selectPage(1);
              }
              break;
            case 2:
              {
                selectPage(2);
              }
              break;

            default:
              {}
              break;
          }
        });
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
    return Expanded(
        child: GlassContainer(
            height: MediaQuery.of(context).size.height * 0.8,
            width: MediaQuery.of(context).size.width,
            blur: 4,
            color: Colors.white.withOpacity(0.7),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.blue.withOpacity(0.3),
              ],
            ),
            //--code to remove border
            border: const Border.fromBorderSide(BorderSide.none),
            shadowStrength: 5,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            shadowColor: Colors.white.withOpacity(0.24),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                GlassContainer(
                  height: 120,
                  width: 120,
                  blur: 4,
                  color: Colors.white.withOpacity(0.7),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.blue.withOpacity(0.3),
                    ],
                  ),
                  //--code to remove border
                  border: const Border.fromBorderSide(BorderSide.none),
                  shadowStrength: 5,
                  shape: BoxShape.circle,
                  borderRadius: BorderRadius.circular(16),
                  shadowColor: Colors.white.withOpacity(0.24),
                  child: const Padding(
                      padding: EdgeInsets.only(top: 35, left: 15),
                      child: Header('Sign in')),
                ),
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
                            style: const TextStyle(color: Colors.white),
                            controller: _emailController,
                            decoration: const InputDecoration(
                                hintText: 'Enter your email',
                                hintStyle: TextStyle(color: Colors.white)),
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
                            style: const TextStyle(color: Colors.white),
                            controller: _passwordController,
                            decoration: const InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(color: Colors.white)),
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
                                      padding: const EdgeInsets.only(
                                          right: lsMargin, left: lsMargin),
                                      child: StyledButton(
                                        onPressed: () {
                                          widget.selectPage(4);
                                        },
                                        child: const Text(
                                          'REGISTER',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: lsMargin),
                                      child: StyledButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            widget.login(
                                              _emailController.text,
                                              _passwordController.text,
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'SIGN IN',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )

                                    // const SizedBox(width: 3),
                                  ],
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: TextButton(
                                      onPressed: () {
                                        widget.selectPage(5);
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
            )));
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
          style: const TextStyle(
              fontSize: 24, color: Colors.white, fontFamily: 'roboto'),
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
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 50,
                ),
                GlassContainer(
                    height: 80,
                    width: MediaQuery.of(context).size.width,
                    blur: 4,
                    color: Colors.white.withOpacity(0.7),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.blue.withOpacity(0.3),
                      ],
                    ),
                    //--code to remove border
                    border: const Border.fromBorderSide(BorderSide.none),
                    shadowStrength: 5,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(16),
                    shadowColor: Colors.white.withOpacity(0.24),
                    child: const Center(
                        child: Text("Registration",
                            style: TextStyle(
                                color: Colors.lightBlue, fontSize: 30)))),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    controller: _emailController,
                    decoration: const InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: Colors.white)),
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
                    style: const TextStyle(color: Colors.white),
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                        hintText: 'First & last name',
                        hintStyle: TextStyle(color: Colors.white)),
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
                    style: const TextStyle(color: Colors.white),
                    controller: _passwordController,
                    decoration: const InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.white)),
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
            )));
  }
}

class Qitem {
  String mode;
  Int ih;
  Int im;
  Int isec;
  Int init;
  Int end;
  Int date;
  Int timestamp;
  String status;
  String question;
  dynamic listQuestions;
  String userId;
  String genId;
  String email;
  String name;
  Int answerOn;

  Qitem(
      {required this.mode,
      required this.ih,
      required this.im,
      required this.isec,
      required this.init,
      required this.end,
      required this.date,
      required this.timestamp,
      required this.status,
      required this.question,
      required this.listQuestions,
      required this.userId,
      required this.genId,
      required this.email,
      required this.name,
      required this.answerOn});

  toJSONEncodable() {
    Map<String, dynamic> m = {};

    m['mode'] = mode;
    m['ih'] = ih;
    m['im'] = im;
    m['isec'] = isec;
    m['init'] = init;
    m['end'] = end;
    m['date'] = date;
    m['timestamp'] = timestamp;
    m['status'] = status;
    m['question'] = question;
    m['listQuestions'] = listQuestions;
    m['userId'] = userId;
    m['genId'] = genId;
    m['email'] = email;
    m['name'] = name;
    m['answerOn'] = answerOn;
    return m;
  }
}

class QitemList {
  List<Qitem> items = [];

  toJSONEncodable() {
    return items.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }
}
