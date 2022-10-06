import 'package:flutter/material.dart';
import 'package:noteme/screens/note_detail.dart';
import 'package:noteme/screens/note_list.dart';


//ignore_for_file:prefer_const_constructors

void main(){

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NoteMe",
      debugShowCheckedModeBanner: false,
      home: NoteList(),
    );
  }
}
