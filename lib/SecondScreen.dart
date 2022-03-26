import 'package:flutter/material.dart';

class SecondScreen extends StatefulWidget {
  final String title;
  final String description;
  final String id;
  SecondScreen({Key? key, required this.title, required this.description, required this.id}) : super(key: key)
  @override
  State<StatefulWidget> createState() => _SecondScreenState();
  
}
class _SecondScreenState extends State<SecondScreen> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(child: Text(widget.description)),
    );
  }
  
}