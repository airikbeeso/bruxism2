import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:survey_kit/src/steps/step.dart' as mm;
import 'package:intl/intl.dart';

import 'LocalNotifyManager.dart';

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

  Future<void> startSessions(bool isActive, DateTime dt, bool repeat) async {
    // print("hour: ${dt.hour} : ${dt.minute} : ${dt.second}");

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
          var dt2 = dt.add(const Duration(days: 1));
          var nd9 = DateTime(dt2.year, dt2.month, dt2.day, 9, 0, 0);
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
          var dt2 = dt.add(const Duration(days: 1));
          var nd9 = DateTime(dt2.year, dt2.month, dt2.day, 9, 0, 0);
          saveSchedule(nd9, 9, _id);
          _id++;

          print("next day: ${nd9.toIso8601String()}");
          var nd12 = DateTime(dt2.year, dt2.month, dt2.day, 12, 0, 0);
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
          var dt2 = dt.add(const Duration(days: 1));
          var nd9 = DateTime(dt2.year, dt2.month, dt2.day, 9, 0, 0);
          saveSchedule(nd9, 9, _id);
          _id++;

          print("next day: ${nd9.toIso8601String()}");
          var nd12 = DateTime(dt2.year, dt2.month, dt2.day, 12, 0, 0);
          saveSchedule(nd12, 12, _id);
          _id++;

          print("next day: ${nd12.toIso8601String()}");
          var nd15 = DateTime(dt2.year, dt2.month, dt2.day, 15, 0, 0);
          saveSchedule(nd15, 15, _id);
          _id++;

          print("next day: ${nd15.toIso8601String()}");
        } else if (dt.hour >= 18 && dt.hour < 21) {
          var nd21 = DateTime(dt.year, dt.month, dt.day, 21, 0, 0);
          saveSchedule(nd21, 21, _id);
          _id++;

          print("next day: ${nd21.toIso8601String()}");

          ///schedule next day
          var dt2 = dt.add(const Duration(days: 1));
          var nd9 = DateTime(dt2.year, dt2.month, dt2.day, 9, 0, 0);
          saveSchedule(nd9, 9, _id);
          _id++;

          print("next day: ${nd9.toIso8601String()}");
          var nd12 = DateTime(dt2.year, dt2.month, dt2.day, 12, 0, 0);
          saveSchedule(nd12, 12, _id);
          _id++;

          print("next day: ${nd12.toIso8601String()}");
          var nd15 = DateTime(dt2.year, dt2.month, dt2.day, 15, 0, 0);
          saveSchedule(nd15, 15, _id);
          _id++;

          print("next day: ${nd15.toIso8601String()}");

          var nd18 = DateTime(dt2.year, dt2.month, dt2.day, 18, 0, 0);
          saveSchedule(nd18, 18, _id);
          _id++;

          print("next day: ${nd18.toIso8601String()}");
        }
      }
    } else {
      localNotifyManager.cancelAllScheduled();
      LocalStorage storage = LocalStorage("questions");
      storage.clear();
      storage.dispose();
    }
  }

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
          "Merasa malas melakukan sesuatu",
          "Lewatkan"
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
        "Bruxism Notification",
        "Rate your pain, Jam $mode");
  }

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
    final LocalStorage storage = LocalStorage('questions');

    // if (21 == context2["mode"]) {
    //   var now = DateTime.now();
    //   localNotifyManager.cancelAllScheduled();

    //   startSessions(true, now, false).then((value) => print("done"));
    // }

    // var list = [];
    // if (null != storage.getItem("questions")) {
    //   if (storage.getItem("questions") is String) {
    //     list = [];
    //   } else {
    //     list = json.decode(storage.getItem("questions"));
    //   }

    //   if (list
    //       .where((element) => element["genId"] == context2["genId"])
    //       .isEmpty) {
    //     list.add(context2);
    //     storage.setItem("questions", json.encode(list));
    //   } else {
    //     list.add(context2);
    //     storage.setItem("questions", json.encode(list));
    //   }
    // } else {
    //   list.add(context2);
    //   storage.setItem("questions", json.encode(list));
    // }

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
      context2["answerOn"] = DateTime.now().millisecondsSinceEpoch;

      await FirebaseFirestore.instance.collection("alerts").add(context2);
      // showAlertDialog().then((value) => Navigator.pop(context));
      // Navigator.pop(context);
    }

    Future<Task> getSampleTask() {
      var rng = Random();
      int rn = rng.nextInt(100);
      List<mm.Step> ls = [];

      for (var i = 0; i < context2["listQuestions"].length; i++) {
        var data = context2["listQuestions"][i];
        switch (data["form"]) {
          case "radio":
            List<TextChoice> ls2 = [];
            for (var i2 = 0; i2 < data["option"].length; i2++) {
              String d = data["option"][i2];

              ls2.add(TextChoice(text: d.toString(), value: d.toString()));
            }
            ls.add(QuestionStep(
                title: data["question"],
                answerFormat: SingleChoiceAnswerFormat(textChoices: ls2)));
            break;
          case "check":
            List<TextChoice> ls2 = [];
            for (var i2 = 0; i2 < data["option"].length; i2++) {
              String d = data["option"][i2];

              ls2.add(TextChoice(text: d.toString(), value: d.toString()));
            }
            ls.add(QuestionStep(
                title: data["question"],
                answerFormat: MultipleChoiceAnswerFormat(textChoices: ls2)));
            break;
          case "scale":
            // List<TextChoice> ls2 = [];
            // for (var i2 = 0; i2 < data.option.length; i++) {
            //   var d = data!.option[i2] as String;

            //   ls2.add(TextChoice(text: d.toString(), value: d.toString()));
            // }
            double v = double.tryParse(data["option"].toString())!;
            ls.add(QuestionStep(
                title: data["question"],
                answerFormat: ScaleAnswerFormat(
                  step: 1,
                  minimumValue: 0,
                  maximumValue: v,
                  defaultValue: 5,
                  minimumValueDescription: '0',
                  maximumValueDescription: '10',
                )));
            break;
          default:
            break;
        }
      }

      ls.add(CompletionStep(
        stepIdentifier: StepIdentifier(id: '321'),
        text: 'Terima kasih',
        title: 'Done!',
        buttonText: 'Submit survey',
      ));

      var task = NavigableTask(id: TaskIdentifier(), steps: ls);
      /*  
        [
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
              maximumValue: 10,
              defaultValue: 5,
              minimumValueDescription: '1',
              maximumValueDescription: '10',
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
        ],*/
      // );
      // task.addNavigationRule(
      //   forTriggerStepIdentifier: task.steps[6].stepIdentifier,
      //   navigationRule: ConditionalNavigationRule(
      //     resultToStepIdentifierMapper: (input) {
      //       switch (input) {
      //         case "Yes":
      //           return task.steps[0].stepIdentifier;
      //         case "No":
      //           return task.steps[7].stepIdentifier;
      //         default:
      //           return null;
      //       }
      //     },
      //   ),
      // );
      // Task.fromJson()
      return Future.value(task);
    }

    var idx10 = 0;
    var items = storage.getItem("initial_date_time");

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),

      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(10.0),
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
                  var finalResult = result.results[0].results;

                  for (var i = 0; i < result.results.length; i++) {
                    if (result.results[i].results[0].valueIdentifier !=
                        "completion") {
                      var update = context2["listQuestions"][i];
                      update["answer"] =
                          result.results[i].results[0].valueIdentifier;
                    }
                  }
                  updateAnswer();
                  // for (var i = 0; i < finalResult.length; i++) {

                  //   var finalData = finalResult[i];

                  //   print("save this");

                  // }

                  Navigator.pop(context);
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
                    titleTextStyle:
                        TextStyle(color: Colors.cyan, fontFamily: 'neucha'),
                  ),
                  iconTheme: const IconThemeData(color: Colors.cyan),
                  textSelectionTheme: const TextSelectionThemeData(
                    cursorColor: Colors.cyan,
                    selectionColor: Colors.cyan,
                    selectionHandleColor: Colors.cyan,
                  ),
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
                        fontSize: 22.0,
                        color: Colors.black,
                        fontFamily: 'neucha'),
                    headline5: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black,
                        fontFamily: 'neucha'),
                    bodyText2: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                        fontFamily: 'neucha'),
                    subtitle1: TextStyle(
                        fontSize: 22.0,
                        color: Colors.black,
                        fontFamily: 'neucha'),
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

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // print("FACE...");
      //     // print(context2);
      //     updateAnswer();
      //     widget.selectPage(0);
      //   },
      //   backgroundColor: Colors.green,
      //   child: const Icon(Icons.send, semanticLabel: "Send"),
      // ),
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
