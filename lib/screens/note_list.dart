import 'package:flutter/material.dart';
import 'package:noteme/screens/note_detail.dart';
import 'package:noteme/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:velocity_x/velocity_x.dart';
import 'package:noteme/widget/theme.dart';

import '../models/note.dart';

//ignore_for_file:prefer_const_constructors

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  bool isGrid = true;

  DatabaseHelper databaseHelper = DatabaseHelper();
  int count = 0;
  List<Note> noteList = [];

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = <Note>[];
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
          title: Center(
            child: Text(
              "Notes",
              textScaleFactor: 1.5,
              style: TextStyle(color: Theme.of(context).accentColor),
              
              
              
            ),
          ),
          backgroundColor: Theme.of(context).canvasColor,
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                setState(() {
                  isGrid = !isGrid;
                });
              },
            )
          ]),
      body: getNodeListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Note('', '', 2), "Add Note");
          print("button clicked");
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget getNodeListView() => isGrid
      // TextStyle titleStyle = Theme.of(context).textTheme.subhead;
      ? Padding(
          padding: const EdgeInsets.all(9.0),
          child: ListView.builder(
              itemCount: count,
              itemBuilder: (BuildContext context, int position) {
                return Card(
                   shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                  color: Theme.of(context).cardColor,
                  elevation: 2.0,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          getPriorityColor(this.noteList[position].priority),
                      child: getPriorityIcon(this.noteList[position].priority),
                    ),
                    title: Text(
                      this.noteList[position].title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Theme.of(context).accentColor),
                    ),
                    subtitle: Text(this.noteList[position].date),
                    trailing: GestureDetector(
                      child: Icon(Icons.delete),
                      onTap: () {
                        _delete(context, noteList[position]);
                      },
                    ),
                    onTap: () {
                      navigateToDetail(this.noteList[position], "Edit Notes");

                      // print("ListTile Pressed");
                    },
                  ),
                );
              }),
        )
      : Padding(
          padding: const EdgeInsets.all(9.0),
          child: GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: count,
              itemBuilder: (BuildContext context, int position) {
                return InkWell(
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 3.0,
                    child: GridTile(
                      child: Center(
                        child: Text(
                          this.noteList[position].title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                      header: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircleAvatar(
                          backgroundColor: getPriorityColor(
                              this.noteList[position].priority),
                          child:
                              getPriorityIcon(this.noteList[position].priority),
                        ),
                      ),
                      footer: GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(Icons.delete),
                        ),
                        onTap: () {
                          _delete(context, noteList[position]);
                        },
                      ),
                    ),
                  ),
                  onTap: () {
                    navigateToDetail(this.noteList[position], "Edit Notes");

                    // print("ListTile Pressed");
                  },
                );
              }),
        );

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.green;
        break;

      default:
        return Colors.green;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(
          Icons.dangerous,
          color: Colors.white,
        );
        break;
      case 2:
        return Icon(
          Icons.access_time,
          color: Colors.white,
        );
        break;

      default:
        return Icon(Icons.access_time);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id!);
    if (result != 0) {
      // ignore: use_build_context_synchronously
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    // Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}
