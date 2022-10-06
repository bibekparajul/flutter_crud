import 'package:flutter/material.dart';
import 'package:noteme/screens/note_detail.dart';
import 'package:noteme/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

import '../models/note.dart';

//ignore_for_file:prefer_const_constructors

class NoteList extends StatefulWidget {

  

  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  int count = 0;
 List<Note> noteList =[];
  
  @override
  Widget build(BuildContext context) {

    if(noteList ==null){
      noteList = <Note>[];
      updateListView();

    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
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

  ListView getNodeListView() {
    // TextStyle titleStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
        itemCount: count,
        itemBuilder: (BuildContext context, int position) {
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: getPriorityColor(this.noteList[position].priority),
                child: getPriorityIcon(this.noteList[position].priority),
              ),
              title: Text(
                this.noteList[position].title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              subtitle: Text(this.noteList[position].date),
              trailing: 
              GestureDetector(child:  Icon(Icons.delete),
              
              onTap: (){
                _delete(context, noteList[position]);
              },
              ),
             
              onTap: () {
                navigateToDetail(this.noteList[position],"Edit Notes");


                // print("ListTile Pressed");
              },
            ),
          );
        });
  }


  // Returns the priority color
	Color getPriorityColor(int priority) {
		switch (priority) {
			case 1:
				return Colors.red;
				break;
			case 2:
				return Colors.yellow;
				break;

			default:
				return Colors.yellow;
		}
	}

	// Returns the priority icon
	Icon getPriorityIcon(int priority) {
		switch (priority) {
			case 1:
				return Icon(Icons.play_arrow);
				break;
			case 2:
				return Icon(Icons.keyboard_arrow_right);
				break;

			default:
				return Icon(Icons.keyboard_arrow_right);
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



  void navigateToDetail(Note note, String title) async{
                  bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return NoteDetail(note, title);
                }));
                if(result ==true){
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
