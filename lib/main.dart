import 'package:flutter/material.dart';
import 'package:noteme/screens/note_detail.dart';
import 'package:noteme/screens/note_list.dart';
import 'package:noteme/widget/theme.dart';


//ignore_for_file:prefer_const_constructors

void main(){

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: MyTheme.lightTheme(context),
      darkTheme: MyTheme.darkTheme(context),
      title: "NoteMe",
      debugShowCheckedModeBanner: false,
      home: NoteList(),
    );
  }
}
