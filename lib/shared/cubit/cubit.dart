import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/screens/archived_tasks.dart';
import 'package:todo_app/screens/done_tasks.dart';
import 'package:todo_app/screens/new_tasks.dart';
import 'package:todo_app/shared/cubit/states.dart';

class TodoCubit extends Cubit<AppStates>{

  TodoCubit(): super(AppInitialStates());

  static TodoCubit get(context)=>BlocProvider.of(context);

  int currentIndex =0;

  List Screens=[
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  List <String> titles=[
    'NewTasks',
    'DoneTasks',
    'ArchivedTasks',
  ];

  void changeIndex(int index){
    currentIndex= index;
    emit(AppChangeBottomNavBarStates());


}
  bool isBottomSheetShown = false;
  IconData fabIcon= Icons.edit;


  void changeBottomSheetState(
  {
  required bool isShown,
    required IconData icon
 }
      )
  {
    isBottomSheetShown = isShown;
    fabIcon= icon;
    emit(AppChangeBottomSheetState());

  }
  
  late Database database;

  void createDatabase(){
    openDatabase(
      'todo.dp',
      version: 1,
      onCreate: (database,version)
        {
          print('database created');
          database.execute(
              'CREATE TABLE Tasks(id INTEGER PRIMARY KEY,title TEXT,time TEXT,date TEXT,status TEXT)')
              .then((value) {
            print('table created');
          }).catchError((error){
            print('error while creating table ${error.toString()}');
          });
        },
      onOpen: (database){
        getDataFromDatabase(database);
        print('database opened');

      }
      
    ).then((value) {
      database =value;
      emit(AppCreateDatabaseState());
    });

  }

  inserToDatabase({
    required String title,
    required String time,
    required String date,

  })async{

    await database.transaction(
            (txn){

          return txn.rawInsert(
              'INSERT INTO Tasks(title,time,date,status) VALUES("$title","$time","$date","new")')
              .then((value) {
            print('$value inserted successfully');
            emit(AppInsertDatabaseState());
            getDataFromDatabase(database);
          }).catchError((error){
            print('error when insert new record ${error.toString()}');
          });
        });

  }
  
  List <Map> NewTasks=[];
  List <Map> DoneTasks=[];
  List <Map> ArchivedTasks=[];
  void getDataFromDatabase(database){
    NewTasks=[];
    DoneTasks=[];
    ArchivedTasks=[];
     emit(AppGetDatabaseLoadingState());
     database.rawQuery('SELECT * FROM Tasks',)
         .then((value) {
           value.forEach((element){
             if(element['status']=='new') {
               NewTasks.add(element);
             }
             else if(element['status']=='done') {
               DoneTasks.add(element);
             }
             else
               ArchivedTasks.add(element);
           });
       emit(AppGetSuccessDatebaseState());
     }
     ).catchError((error){
       print(error.toString());
       emit(AppGetErrorDatebaseState());
     });
    
    
  }

  void updateDatabase(
  {
    required String status,
    required int id,
  })async{
     await database.rawUpdate(
        'UPDATE Tasks SET status = ? WHERE id = ?',
       ['$status',id]
     )
         .then((value){
           getDataFromDatabase(database);
           emit(AppUpdateDatebaseState());
     }
     );
  }
  void deleteFromDatabase(
      {
        required int id,
      })async{
    await database.rawDelete(
        'DELETE FROM Tasks WHERE id = ?',[id]
    )
        .then((value){
      getDataFromDatabase(database);
      emit(AppDeleteDatebaseState());
    }
    );
  }

}