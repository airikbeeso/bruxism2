import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:developer';
import 'package:intl/intl.dart';

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({Key? key}) : super(key: key);

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  final LocalStorage storage = LocalStorage('questions');
  bool initialized = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var items = storage.getItem("initial_date_time");
    storage.ready.then((value) => log(value.toString()));
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
                    return Text(DateFormat('MM/dd/yyyy hh:mm a')
                        .format(DateTime.fromMillisecondsSinceEpoch(items)));
                  }
                  initialized = true;
                }
                return const Text("Wwww");
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
