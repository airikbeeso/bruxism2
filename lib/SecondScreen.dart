import 'dart:convert';
import 'dart:io';

import 'package:bruxism2/ViewQuestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:survey_kit/survey_kit.dart';

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readCounter() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }
}

class SecondScreen extends StatefulWidget {
  final String title;
  final String description;
  final String id;
  final Function selectPage;
  final CounterStorage storage;

  const SecondScreen(
      {Key? key,
      required this.title,
      required this.description,
      required this.id,
      required this.selectPage,
      required this.storage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  String name = "";
  String groupValue = "";
  LocalStorage storage = LocalStorage("questions");

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
    var list = [];
    if (null != storage.getItem("questions")) {
      if (storage.getItem("questions") is String) {
        list = [];
      } else {
        list = json.decode(storage.getItem("questions"));
      }

      if (list
          .where((element) => element["genId"] == context2["genId"])
          .isEmpty) {
        list.add(context2);
        storage.setItem("questions", json.encode(list));
      } else {
        list.add(context2);
        storage.setItem("questions", json.encode(list));
      }
    } else {
      list.add(context2);
      storage.setItem("questions", json.encode(list));
    }

    // print(context);
    // print(context2["listQuestions"]);

    String selected = "";
    showAlertDialog() {
      // set up the buttons
      Widget cancelButton = TextButton(
        child: const Text("Cancel"),
        onPressed: () {
          // Navigator.push(context, MaterialPageRoute(
          //   builder: (context) {
          //     return const ViewAlerts();
          //   },
          // ));

          Navigator.pop(context);
        },
      );
      Widget continueButton = TextButton(
        child: const Text("Continue"),
        onPressed: () {
          try {
            if (null != storage.getItem("questions")) {
              var qa = storage.getItem("questions");

              List<dynamic> list = json.decode(qa);
              list.removeWhere((element) => element.genId == context2.genId);
              storage.setItem("questions", json.encode(list));
            }
          } catch (ex) {
            print(ex);
          }

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
      // showAlertDialog().then((value) => Navigator.pop(context));
      Navigator.pop(context);
    }

    Future<Task> getSampleTask() {
      var task = NavigableTask(
        id: TaskIdentifier(),
        steps: [
          InstructionStep(
            title: 'Welcome to the\nQuickBird Studios\nHealth Survey',
            text: 'Get ready for a bunch of super random questions!',
            buttonText: 'Let\'s go!',
          ),
          QuestionStep(
            title: 'How old are you?',
            answerFormat: const IntegerAnswerFormat(
              defaultValue: 25,
              hint: 'Please enter your age',
            ),
            isOptional: true,
          ),
          QuestionStep(
            title: 'Medication?',
            text: 'Are you using any medication',
            answerFormat: const BooleanAnswerFormat(
              positiveAnswer: 'Yes',
              negativeAnswer: 'No',
              result: BooleanResult.POSITIVE,
            ),
          ),
          QuestionStep(
            title: 'Tell us about you',
            text:
                'Tell us about yourself and why you want to improve your health.',
            answerFormat: const TextAnswerFormat(
              maxLines: 5,
              validationRegEx: "^(?!\s*\$).+",
            ),
          ),
          QuestionStep(
            title: 'Select your body type',
            answerFormat: const ScaleAnswerFormat(
              step: 1,
              minimumValue: 1,
              maximumValue: 5,
              defaultValue: 3,
              minimumValueDescription: '1',
              maximumValueDescription: '5',
            ),
          ),
          QuestionStep(
            title: 'Known allergies',
            text: 'Do you have any allergies that we should be aware of?',
            isOptional: false,
            answerFormat: const MultipleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Penicillin', value: 'Penicillin'),
                TextChoice(text: 'Latex', value: 'Latex'),
                TextChoice(text: 'Pet', value: 'Pet'),
                TextChoice(text: 'Pollen', value: 'Pollen'),
              ],
            ),
          ),
          QuestionStep(
            title: 'Done?',
            text: 'We are done, do you mind to tell us more about yourself?',
            isOptional: true,
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'Yes', value: 'Yes'),
                TextChoice(text: 'No', value: 'No'),
              ],
              defaultSelection: TextChoice(text: 'No', value: 'No'),
            ),
          ),
          QuestionStep(
            title: 'When did you wake up?',
            answerFormat: const TimeAnswerFormat(
              defaultValue: TimeOfDay(
                hour: 12,
                minute: 0,
              ),
            ),
          ),
          QuestionStep(
            title: 'When was your last holiday?',
            answerFormat: DateAnswerFormat(
              minDate: DateTime.utc(1970),
              defaultDate: DateTime.now(),
              maxDate: DateTime.now(),
            ),
          ),
          CompletionStep(
            stepIdentifier: StepIdentifier(id: '321'),
            text: 'Thanks for taking the survey, we will contact you soon!',
            title: 'Done!',
            buttonText: 'Submit survey',
          ),
        ],
      );
      task.addNavigationRule(
        forTriggerStepIdentifier: task.steps[6].stepIdentifier,
        navigationRule: ConditionalNavigationRule(
          resultToStepIdentifierMapper: (input) {
            switch (input) {
              case "Yes":
                return task.steps[0].stepIdentifier;
              case "No":
                return task.steps[7].stepIdentifier;
              default:
                return null;
            }
          },
        ),
      );
      return Future.value(task);
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        color: Colors.white,
        child: FutureBuilder<Task>(
          future: getSampleTask(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData &&
                snapshot.data != null) {
              final task = snapshot.data!;
              return SurveyKit(
                task: task,
                onResult: (SurveyResult result) {
                  print(result.finishReason);
                },
                showProgress: true,
                localizations: const {'cancel': 'Cancel', 'next': 'Next'},
                themeData: Theme.of(context).copyWith(
                  colorScheme:
                      ColorScheme.fromSwatch(primarySwatch: Colors.cyan)
                          .copyWith(onPrimary: Colors.white),
                  primaryColor: Colors.cyan,
                  backgroundColor: Colors.white,
                  appBarTheme: const AppBarTheme(
                    color: Colors.white,
                    iconTheme: IconThemeData(color: Colors.cyan),
                    titleTextStyle: TextStyle(color: Colors.cyan),
                  ),
                  iconTheme: const IconThemeData(color: Colors.cyan),
                  textSelectionTheme: const TextSelectionThemeData(
                      cursorColor: Colors.cyan,
                      selectionColor: Colors.cyan,
                      selectionHandleColor: Colors.cyan),
                  cupertinoOverrideTheme:
                      const CupertinoThemeData(primaryColor: Colors.cyan),
                  outlinedButtonTheme: const OutlinedButtonThemeData(),
                  textButtonTheme: TextButtonThemeData(
                    style: ButtonStyle(
                      textStyle: MaterialStateProperty.all(
                        Theme.of(context).textTheme.button?.copyWith(
                              color: Colors.cyan,
                            ),
                      ),
                    ),
                  ),
                  textTheme: const TextTheme(
                    headline2: TextStyle(
                      fontSize: 28.0,
                      color: Colors.black,
                    ),
                    headline5: TextStyle(
                      fontSize: 24.0,
                      color: Colors.black,
                    ),
                    bodyText2: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                    subtitle1: TextStyle(
                      fontSize: 18.0,
                      color: Colors.black,
                    ),
                  ),
                  inputDecorationTheme: const InputDecorationTheme(
                    labelStyle: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                surveyProgressbarConfiguration: SurveyProgressConfiguration(
                  backgroundColor: Colors.white,
                ),
              );
            }
            return const CircularProgressIndicator.adaptive();
          },
        ),
      ),

      // Container(
      //     padding: const EdgeInsets.all(10.0),
      //     child: ListView.builder(
      //       itemBuilder: (body, index) {
      //         var data = context2["listQuestions"][index];
      //         var items = data["option"].join(', ');

      //         return Container(
      //           padding: const EdgeInsets.all(10.0),
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: [
      //               ViewQuestion(data: data, index: index),

      //             ],
      //           ),
      //         );
      //       },
      //       itemCount: context2["listQuestions"].length,
      //     )),
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
