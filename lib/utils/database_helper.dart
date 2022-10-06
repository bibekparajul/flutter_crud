import 'package:noteme/models/note.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static  DatabaseHelper? _databaseHelper; //singleton databaseHelper
  static Database? _database; //singleton database

  String noteTable = 'note_table';
  String cId = 'id';
  String cTitle = 'title';
  String cDescription = 'description';
  String cPriority = 'priority';
  String cDate = 'date';

  DatabaseHelper._createInstance(); //named cons to create instance of database helper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {       
      _databaseHelper = DatabaseHelper._createInstance();         //executed only once, singleton object 
    }
    return _databaseHelper!;
  }

Future<Database> get database async{
  if(_database ==null){
    _database = await initializeDatabase();
  }
  
  return _database!;

}


  Future <Database>initializeDatabase() async{

      //get the directory path for both android and ios to store database.

      Directory directory = await getApplicationSupportDirectory();
      String path = directory.path + 'notes.db';

      //open the databse at a given path
     var notesDatabase = openDatabase(path, version: 1, onCreate: _createDb);
      return notesDatabase;

  }


  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $noteTable($cId INTEGER PRIMARY KEY AUTOINCREMENT, $cTitle TEXT,$cDescription TEXT,'
        '$cPriority INTEGER, $cDate text)');
  }



  //fetch operation

  Future<List<Map<String, dynamic>>>getNoteMapList() async{
    Database db = await this.database;


   //we can write query in two ways using the raqQuery and the other is using the helper function 
    // var result = await db.rawQuery('Select *from $noteTable order by $cPriority');

    var result = await db.query(noteTable, orderBy: '$cPriority ASC');   //helper function
    return result;
  }

// Insert Operation: Insert a Note object to database
	Future<int> insertNote(Note note) async {
		Database db = await this.database;
		var result = await db.insert(noteTable, note.toMap());
		return result;
	}

	// update Operation:
	Future<int> updateNote(Note note) async {
		var db = await this.database;
		var result = await db.update(noteTable, note.toMap(), where: '$cId = ?', whereArgs: [note.id]);
		return result;
	}

	// delete Operation
	Future<int> deleteNote(int id) async {
		var db = await this.database;
		int result = await db.rawDelete('delete from $noteTable where $cId = $id');
		return result;
	}

  // Get number of Note objects in database 
	Future<int?> getCount() async {
		Database db = await this.database;
		List<Map<String, dynamic>> x = await db.rawQuery('Select count (*) from $noteTable');
		int? result = Sqflite.firstIntValue(x);
		return result;
	}

// Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
	Future<List<Note>> getNoteList() async {

		var noteMapList = await getNoteMapList(); // Get 'Map List' from database
		int count = noteMapList.length;         // Count the number of map entries in db table

		List<Note> noteList = [];
		// For loop to create a 'Note List' from a 'Map List'
		for (int i = 0; i < count; i++) {
			noteList.add(Note.fromMapObject(noteMapList[i]));
		}

		return noteList;
	}

}
