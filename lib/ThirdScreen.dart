import 'dart:convert';
import 'dart:math';

import 'package:bruxism2/LocalNotifyManager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:localstorage/localstorage.dart';
import 'package:intl/intl.dart';

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({Key? key}) : super(key: key);

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  final LocalStorage storage = LocalStorage('questions');
  bool initialized = false;
  String userId = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var items = storage.getItem("initial_date_time");
    storage.ready.then((value) => print(value.toString()));
    Firebase.initializeApp()
        .then((value) => userId = FirebaseAuth.instance.currentUser!.uid);
  }

  Future<dynamic> checkForAnswer(String id) async {
    return FirebaseFirestore.instance.collection("alerts").doc(id).get();
  }

  openQuestion(int time) async {
    var dt = DateTime.fromMillisecondsSinceEpoch(time);
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
    var inputFormat = DateFormat('dd/MM/yyyy HH:mm');

    var inputDate = inputFormat
        .parse('${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString()}:00');
    var genId =
        "${dt.year}-${dt.month}-${dt.day}-${dt.hour.toString()}-${FirebaseAuth.instance.currentUser!.uid}";
    var context = {
      "mode": dt.hour.toString(),
      "ih": dt.hour,
      "im": dt.minute,
      "is": dt.second,
      "init": dt.millisecondsSinceEpoch,
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
    await LocalNotifyManager.init().dailyAtTimeNotification(
        rng.nextInt(1000),
        dt.hour,
        dt,
        jsonEncode(context),
        "Bruxism Notificaiton",
        "Rate your pain, Jam ${dt.hour}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("List questions"),
        ),
        body: GlassmorphicContainer(
          width: 350,
          height: 350,
          borderRadius: 20,
          blur: 20,
          alignment: Alignment.bottomCenter,
          border: 2,
          linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFffffff).withOpacity(0.1),
                const Color(0xFFFFFFFF).withOpacity(0.05),
              ],
              stops: const [
                0.1,
                1,
              ]),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFffffff).withOpacity(0.5),
              const Color((0xFFFFFFFF)).withOpacity(0.5),
            ],
          ),
          child: FutureBuilder(
              future: storage.ready,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (!initialized) {
                  var items = storage.getItem("initial_date_time");
                  if (items != null) {
                    var current = DateTime(2022, 8, 5, 17, 0, 0);
                    var before = DateTime.fromMillisecondsSinceEpoch(items);
                    print("userId: $userId");
                    var dayAdd = 1;

                    bool bb = false;
                    var b = before.add(Duration(days: dayAdd));

                    print("${b.month} ${b.day}");

                    var first = DateTime(b.year, b.month, b.day, 9, 0, 0);
                    var second = DateTime(b.year, b.month, b.day, 12, 0, 0);
                    var third = DateTime(b.year, b.month, b.day, 15, 0, 0);
                    var forth = DateTime(b.year, b.month, b.day, 18, 0, 0);
                    var fifth = DateTime(b.year, b.month, b.day, 21, 0, 0);

                    if (before.millisecondsSinceEpoch <
                            first.millisecondsSinceEpoch &&
                        first.millisecondsSinceEpoch <
                            current.millisecondsSinceEpoch) {
                      var id = userId +
                          "_" +
                          first.millisecondsSinceEpoch.toString();
                      print("IKD $id");
                      checkForAnswer(id).then((value) {
                        print("mmmmm 2 ${value.data()}");
                        print(value.data());
                        if (null == value.data()) {
                          return InkWell(
                            onTap: () => print("WWWWWWW____"),
                            child: const Text("WEELLL"),
                          );
                        } else {
                          return Text(DateFormat('MM/dd/yyyy hh:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(items)));
                        }
                      });
                    }

                    if (before.millisecondsSinceEpoch <
                            second.millisecondsSinceEpoch &&
                        second.millisecondsSinceEpoch <
                            current.millisecondsSinceEpoch) {
                      var id = userId +
                          "_" +
                          second.millisecondsSinceEpoch.toString();
                      print("IKD $id");
                      checkForAnswer(id).then((value) {
                        print("mmmmm 3 $value");
                        if (null == value.data()) {
                          return InkWell(
                            onTap: () => print("WWWWWWW____"),
                            child: const Text("WEELLL"),
                          );
                        } else {
                          return Text(DateFormat('MM/dd/yyyy hh:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(items)));
                        }
                      });
                    }

                    if (before.millisecondsSinceEpoch <
                            third.millisecondsSinceEpoch &&
                        third.millisecondsSinceEpoch <
                            current.millisecondsSinceEpoch) {
                      var id = userId +
                          "_" +
                          third.millisecondsSinceEpoch.toString();
                      print("IKD $id");
                      checkForAnswer(id).then((value) {
                        print("mmmmm 4 $value");
                        if (null == value.data()) {
                          return InkWell(
                            onTap: () => print("WWWWWWW____"),
                            child: const Text("WEELLL"),
                          );
                        } else {
                          return Text(DateFormat('MM/dd/yyyy hh:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(items)));
                        }
                      });
                    }

                    if (before.millisecondsSinceEpoch <
                            forth.millisecondsSinceEpoch &&
                        forth.millisecondsSinceEpoch <
                            current.millisecondsSinceEpoch) {
                      var id = userId +
                          "_" +
                          forth.millisecondsSinceEpoch.toString();
                      print("IKD $id");
                      checkForAnswer(id).then((value) {
                        print("mmmmm 5 $value");
                        if (null == value.data()) {
                          return InkWell(
                            onTap: () => print("WWWWWWW____"),
                            child: const Text("WEELLL"),
                          );
                        } else {
                          return Text(DateFormat('MM/dd/yyyy hh:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(items)));
                        }
                      });
                    }

                    if (before.millisecondsSinceEpoch <
                            fifth.millisecondsSinceEpoch &&
                        fifth.millisecondsSinceEpoch <
                            current.millisecondsSinceEpoch) {
                      var id = userId +
                          "_" +
                          fifth.millisecondsSinceEpoch.toString();
                      print("IKD 10 $id");
                      checkForAnswer(id).then((value) {
                        print(value.data());
                        if (null == value.data()) {
                          return InkWell(
                            onTap: () => print("WWWWWWW____"),
                            child: const Text("WEELLL"),
                          );
                        } else {
                          return Text(DateFormat('MM/dd/yyyy hh:mm a').format(
                              DateTime.fromMillisecondsSinceEpoch(items)));
                        }
                      });
                    }

                    // print("tukar......");

                    // return InkWell(
                    //     onTap: () => print("WWWWWWW____"),
                    //     child: Text(
                    //       DateFormat('MM/dd/yyyy hh:mm a').format(
                    //           DateTime.fromMillisecondsSinceEpoch(items)),
                    //     ));
                    // return Text(DateFormat('MM/dd/yyyy hh:mm a')
                    //     .format(DateTime.fromMillisecondsSinceEpoch(items)));
                  }
                  initialized = true;
                }
                return const Text("nothing");
              }),
        ));
    // Scaffold(
    //   appBar: AppBar(
    //     title: const Text("List questions"),
    //   ),
    //   body: FutureBuilder(
    //       future: storage.ready,
    //       builder: (BuildContext context, AsyncSnapshot snapshot) {
    //         if (snapshot.data == null) {
    //           return const Center(
    //             child: CircularProgressIndicator(),
    //           );
    //         }
    //         if (!initialized) {
    //           var items = storage.getItem("initial_date_time");
    //           if (items != null) {
    //             return Text(DateFormat('MM/dd/yyyy hh:mm a')
    //                 .format(DateTime.fromMillisecondsSinceEpoch(items)));
    //           }
    //           initialized = true;
    //         }
    //         return const Text("Wwww");
    //       }),
    // );
  }
}
