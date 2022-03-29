import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class SecondScreen extends StatefulWidget {
  final String title;
  final String description;
  final String id;
  const SecondScreen(
      {Key? key,
      required this.title,
      required this.description,
      required this.id})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  String name = "";

  @override
  initState() {
    super.initState();
    Firebase.initializeApp();

    // loadData().then((value) {
    //   name = value["answer"];
    // });
  }

  Future<dynamic> loadData() async {
    return FirebaseFirestore.instance.collection("alerts").doc(widget.id).get();
  }

  int _radioValue = 0;

  void _handleRadioValueChange(int? value) {
    setState(() {
      _radioValue = value as int;

      switch (_radioValue) {
        case 0:
          break;

        case 1:
          break;

        case 2:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var context = jsonDecode(widget.id);
    print(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: Text(
                context["question"],
                style: const TextStyle(fontSize: 25),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Radio(
                  value: 0,
                  groupValue: _radioValue,
                  onChanged: _handleRadioValueChange,
                ),
                const Text('1', style: TextStyle(fontSize: 16.0)),
                Radio(
                  value: 1,
                  groupValue: _radioValue,
                  onChanged: _handleRadioValueChange,
                ),
                const Text(
                  '2',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
                Radio(
                  value: 2,
                  groupValue: _radioValue,
                  onChanged: _handleRadioValueChange,
                ),
                const Text(
                  '3',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            )
          ],
        ),
      ),
    );

    // FutureBuilder(
    //   future:
    //       FirebaseFirestore.instance.collection("alerts").doc(widget.id).get(),
    //   builder:
    //       (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
    //     // as DocumentSnapshot<Map<String, dynamic>>;

    //     if (snapshot.hasError) {
    //       return Text("Something went wrong");
    //     }

    //     if (snapshot.hasData && !snapshot.data!.exists) {
    //       return Text("Document does not exist");
    //     }

    //     if (snapshot.connectionState == ConnectionState.done) {
    //       Map<String, dynamic> data =
    //           snapshot.data!.data() as Map<String, dynamic>;
    //       // return Text("Full Name: ${data['full_name']} ${data['last_name']}");

    //       return Scaffold(
    //         appBar: AppBar(title: Text(widget.title)),
    //         body: Center(child: Text(data["answer"])),
    //       );
    //     }

    //     return Scaffold(
    //         appBar: AppBar(title: const Text("Notification")),
    //         body: const Text("loading"));
    //   },
    // );
  }
}
