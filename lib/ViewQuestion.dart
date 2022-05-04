import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:grouped_buttons_ns/grouped_buttons_ns.dart';

class ViewQuestion extends StatefulWidget {
  final dynamic data;
  final int index;
  const ViewQuestion({Key? key, required this.data, required this.index})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ViewQuestionState();
}

class _ViewQuestionState extends State<ViewQuestion> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var data = widget.data;
    var index = widget.index;
    var groupValue;
    var listOption = <String>[];

    for (var m in data["option"]) {
      listOption.add(m);
    }

    //use flexible api

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data["question"],
            style:
                const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),

        if (data["form"] == "check")
          CheckboxGroup(
              labels: listOption,
              onChange: (bool ch, String label, int index) {
                print("GREAT ::::: $ch : $label : $index");
              },
              itemBuilder: (rd, txt, idx) {
                return Row(
                  children: [
                    rd,
                    Flexible(
                        child: Text(
                      txt.data.toString(),
                      style: const TextStyle(fontSize: 19.0),
                    ))
                  ],
                );
              },
              onSelected: (List<String> checked) =>
                  data["answer"] = checked.toString()),

        if (data["form"] == "radio")
          RadioButtonGroup(
            labelStyle: const TextStyle(
                leadingDistribution: TextLeadingDistribution.proportional),
            labels: listOption,
            onChange: (String label, int index) =>
                print('label: $label index: $index'),
            onSelected: (String label) {
              data["answer"] = label;
              print(data);
            },
            itemBuilder: (rd, txt, idx) {
              return Row(
                children: [
                  rd,
                  Flexible(
                      child: Text(
                    txt.data.toString(),
                    style: const TextStyle(fontSize: 19.0),
                  ))
                ],
              );
            },
          )

        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: List<Widget>.generate(
        //       data["option"].length,
        //       (int i) =>

        //       ListTile(
        //             title: Text(data["option"][i]),
        //             leading: Radio<int>(
        //               value: i,
        //               groupValue: groupValue,
        //               onChanged: (int? val) {
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
    );
  }
}
