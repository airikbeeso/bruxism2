import 'dart:convert';

import 'package:bruxism2/ViewQuestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class SecondScreen extends StatefulWidget {
  final String title;
  final String description;
  final String id;
  final Function selectPage;
  const SecondScreen(
      {Key? key,
      required this.title,
      required this.description,
      required this.id,
      required this.selectPage})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  String name = "";
  String groupValue = "";

  @override
  initState() {
    super.initState();
    Firebase.initializeApp();
    groupValue = "";

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
    var context2 = jsonDecode(widget.id);
    // print(context);
    print(context2["listQuestions"]);

    String selected = "";
    showAlertDialog() {
      // set up the buttons
      Widget cancelButton = TextButton(
        child: const Text("Cancel"),
        onPressed: () {},
      );
      Widget continueButton = TextButton(
        child: const Text("Continue"),
        onPressed: () {
          Navigator.pop(context);
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        title: const Text("Your answers have been save!"),
        content: const Text("Thank you, for the answers"),
        actions: [
          cancelButton,
          continueButton,
        ],
      );

      // show the dialog
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    Future<void> updateAnswer() async {
      await FirebaseFirestore.instance.collection("alerts").add(context2);
      showAlertDialog().then((value) => Navigator.pop(context));
      // Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            itemBuilder: (body, index) {
              var data = context2["listQuestions"][index];
              var items = data["option"].join(', ');

              return Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ViewQuestion(data: data, index: index),
                    // Text(data["question"],
                    //     style: const TextStyle(
                    //         fontSize: 16.0, fontWeight: FontWeight.bold)),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: List<Widget>.generate(
                    //       data["option"].length,
                    //       (int i) => ListTile(
                    //             title: Text(data["option"][i]),
                    //             leading: Radio<String>(
                    //               value: index.toString() + "_" + i.toString(),
                    //               groupValue: groupValue,
                    //               onChanged: (String? val) {
                    //                 setState(() {
                    //                   groupValue = val!;
                    //                   // radioButtonItem = 'ONE';
                    //                   // id = 1;
                    //                 });
                    //               },
                    //             ),
                    //           )),
                    // )
                  ],
                ),
              );
            },
            itemCount: context2["listQuestions"].length,
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // print("FACE...");
          // print(context2);
          updateAnswer();
          widget.selectPage(0);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.send, semanticLabel: "Send"),
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(title: Text(widget.title)),
    //   body: Container(
    //     padding: const EdgeInsets.all(10.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       children: [
    //         Padding(
    //           padding: const EdgeInsets.only(top: 15, bottom: 15),
    //           child: Text(
    //             context["question"],
    //             style: const TextStyle(fontSize: 25),
    //           ),
    //         ),
    //         ListView.builder(
    //           itemBuilder: (body, index) {
    //             var data = context["listQuestions"][index];

    //             return Container(
    //               padding: const EdgeInsets.all(10.0),
    //               child: Row(
    //                 children: [
    //                   Text(data["question"]),

    //                 ],
    //               ),
    //             );
    //           },
    //           itemCount: context["listQuestions"].length,
    //         ),
    //         Row(
    //           mainAxisAlignment: MainAxisAlignment.start,
    //           children: [
    //             Radio(
    //               value: 0,
    //               groupValue: _radioValue,
    //               onChanged: _handleRadioValueChange,
    //             ),
    //             const Text('1', style: TextStyle(fontSize: 16.0)),
    //             Radio(
    //               value: 1,
    //               groupValue: _radioValue,
    //               onChanged: _handleRadioValueChange,
    //             ),
    //             const Text(
    //               '2',
    //               style: TextStyle(
    //                 fontSize: 16.0,
    //               ),
    //             ),
    //             Radio(
    //               value: 2,
    //               groupValue: _radioValue,
    //               onChanged: _handleRadioValueChange,
    //             ),
    //             const Text(
    //               '3',
    //               style: TextStyle(fontSize: 16.0),
    //             ),
    //           ],
    //         )
    //       ],
    //     ),
    //   ),
    // );

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
