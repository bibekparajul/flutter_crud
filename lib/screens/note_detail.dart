import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:noteme/models/note.dart';
import 'package:noteme/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteDetail extends StatefulWidget {

 final String appBarTitle;
 final Note note;

  NoteDetail(this.note,this.appBarTitle);
  

  @override
  State<NoteDetail> createState() {

    return NoteDetailState(this.note,this.appBarTitle);
  } 
}

class NoteDetailState extends State<NoteDetail> {

  static var _priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;
 
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  //constructor for appbar title 
  
  NoteDetailState(this.note,this.appBarTitle);

  @override
  Widget build(BuildContext context) {

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(
      
      onWillPop: () async {
        
        moveToLastScreen();
        return true;
        
      },
      child: 
    Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        leading: IconButton(icon: Icon(Icons.arrow_back,),
        onPressed: (){
          moveToLastScreen();
        },),
      
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: DropdownButton(
                items: _priorities.map((String dropDownStringItem) {
                  return DropdownMenuItem<String>(
                    value: dropDownStringItem,
                    child: Text(dropDownStringItem),
                  );
                }).toList(),
                value: getPriorityAsString(note.priority),
                onChanged: (valueSelectedByUser) {
                  setState(() {
                    // print("User selected $valueSelectedByUser");
                    updatePriorityAsInt(valueSelectedByUser!);
                  });
                },
              ),
            ),

            //second elements ie the textform field
            Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: titleController,
                onChanged: (value) {
                  print("TitleTextField");
                  updateTitle();
                },
                decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: descriptionController,
                onChanged: (value) {
                  print("descTextField");
                  updateDescription();
                },
                decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),

//For the button

            Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      child: Text(
                        "Save",
                        textScaleFactor: 1.5,
                      ),
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      onPressed: () {
                        // setState(() {
                          print("SaveClicked");
                          _save();
                        // });
                      },
                    ),
                  ),
                  Container(
                    width: 5.0,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      child: Text(
                        "Delete",
                        textScaleFactor: 1.5,
                      ),
                      style: ElevatedButton.styleFrom(primary: Colors.green),
                      onPressed: () {
                        setState(() {
                          print("DeleteClicked");
                          _delete();
                        });
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  void moveToLastScreen(){

    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to Database
	void updatePriorityAsInt(String value) {
		switch (value) {
			case 'High':
				note.priority = 1;
				break;
			case 'Low':
				note.priority = 2;
				break;
		}
	}

	// Convert int priority to String priority and display it to user in DropDown
	String getPriorityAsString(int value) {
		late String priority ;
		switch (value) {
			case 1:
				priority = _priorities[0];  // 'High'
				break;
			case 2:
				priority = _priorities[1];  // 'Low'
				break;
		}
		return priority;
	}

  	// Update the title of Note object
  void updateTitle(){
    note.title = titleController.text;
  }

	// Update the description of Note object
	void updateDescription() {
		note.description = descriptionController.text;
	}

  // Save data to database
	void _save() async {

		moveToLastScreen();

		note.date = DateFormat.yMMMd().format(DateTime.now());
		int result;
		if (note.id != null) {  // Case 1: Update operation
			result = await helper.updateNote(note);
		} else { // Case 2: Insert Operation
			result = await helper.insertNote(note);
		}

		if (result != 0) {  // Success
			_showAlertDialog('Status', 'Note Saved Successfully');
		} else {  // Failure
			_showAlertDialog('Status', 'Problem Saving Note');
		}
}



void _delete() async {

		moveToLastScreen();

		// Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
		// the detail page by pressing the FAB of NoteList page.
		// ignore: unnecessary_null_comparison
		if (note.id == null) {
			_showAlertDialog('Status', 'No Note was deleted');
			return;
		}

		// Case 2: User is trying to delete the old note that already has a valid ID.
		int result = await helper.deleteNote(note.id!);
		if (result != 0) {
			_showAlertDialog('Status', 'Note Deleted Successfully');
		} else {
			_showAlertDialog('Status', 'Error Occured while Deleting Note');
		}
	}

  void _showAlertDialog(String title, String message) {

		AlertDialog alertDialog = AlertDialog(
			title: Text(title),
			content: Text(message),
		);
		showDialog(
				context: context,
				builder: (_) => alertDialog
		);
	}



}
