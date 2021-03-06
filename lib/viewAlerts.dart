import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class ViewAlerts extends StatefulWidget {
  const ViewAlerts({Key? key}) : super(key: key);

  @override
  State<ViewAlerts> createState() => _ViewAlertsState();
}

class _ViewAlertsState extends State<ViewAlerts> {
  List ls = [];

  @override
  void initState() {
    // TODO: implement initState
    Firebase.initializeApp();

    super.initState();
  }

  saveFb() {
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
        ]
      },
      {
        "id": 1,
        "question": "Kondisi otot wajah/rahang (?) anda saat ini",
        "option": [
          "Rileks",
          "Otot wajah/rahang tegang dan rahang terasa kencang tanpa ada gigi yang berkontak"
        ]
      },
      {
        "id": 2,
        "question": "Apakah anda merasakan nyeri di daerah wajah",
        "option": ["Ya", "Tidak"]
      },
      {
        "id": 3,
        "question": "Apakah anda merasakan nyeri di daerah wajah",
        "option": ["Ya", "Tidak"]
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
        ]
      },
      {
        "id": 1,
        "question": "Kondisi otot wajah/rahang (?) anda saat ini",
        "option": [
          "Rileks",
          "Otot wajah/rahang tegang dan rahang terasa kencang tanpa ada gigi yang berkontak"
        ]
      },
      {
        "id": 2,
        "question": "Apakah anda merasakan nyeri di daerah wajah",
        "option": ["Ya", "Tidak"]
      },
      {
        "id": 3,
        "question": "erasa gugup atau tegang",
        "option": ["Ya", "Tidak"]
      },
      {
        "id": 4,
        "question": "Kondisi anda hari ini",
        "option": [
          "Merasa gugup atau tegang",
          "Sulit mengontrol kawatir",
          "Merasa sedih, depresi",
          "Merasa malas melakukan sesuatu",
          "Lewatkan"
        ]
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
      "status": "onSchedule",
      "question": "default question",
      "answer": "default answer",
      "listQuestions": chosenQuestion,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'genId': genId
    };
    FirebaseFirestore.instance.collection("questions").add(context);
  }

  Future<List> loadLocalStorage() async {
    LocalStorage storage = LocalStorage("questions");
    if (null != storage.getItem("questions")) {
      print(storage.getItem("questions"));
      ls = json.decode(storage.getItem("questions") as String); //json.decode();
      return ls;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Save")),
      body: FutureBuilder(
          builder: (context, snapshot) {
            print("build");

            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && (snapshot.data as List).isNotEmpty) {
                var data = snapshot.data as List<dynamic>;
                return ListView.builder(
                  itemBuilder: (context, index) {
                    final item = data[index];

                    return ListTile(
                      title: Text(item["question"]),
                      subtitle: Text(item["date"]),
                    );
                  },
                  itemCount: data.length,
                );
              } else {
                return const Text("DATA empty");
              }
            } else {
              return const Text("DATA empty");
            }
          },
          future: loadLocalStorage()),
    );
  }
}
