import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/Network/styles/colors.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {

  var scaffoldKey= GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();

  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return BlocConsumer<TodoCubit,AppStates>(
      listener: (context,state){
           if(state is AppInsertDatabaseState)
             {
               Navigator.pop(context);
             }
      },

      builder: (context,state){
        var cubit = TodoCubit.get(context);

        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(cubit.titles[cubit.currentIndex]),
            backgroundColor: defaultColor,
          ),
          body: ConditionalBuilder(
            condition: state is! AppGetDatabaseLoadingState,
            builder: (context)=>cubit.Screens[cubit.currentIndex],
            fallback:(context)=>Center(child: CircularProgressIndicator()),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if(cubit.isBottomSheetShown){
                if(formKey.currentState!.validate())
                {
                  cubit.inserToDatabase(
                      title: titleController.text,
                      time: timeController.text,
                      date: dateController.text);
                }

              }
              else {
                titleController.text='';
                timeController.text='';
                dateController.text='';
                scaffoldKey.currentState!.showBottomSheet((context) =>
                    Container(
                        padding: EdgeInsetsDirectional.all(15.0),
                        child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                    controller: titleController,
                                    type: TextInputType.text,
                                    validate: (value) {
                                      if (value.isEmpty) {
                                        return 'title mustn\'t be empty';
                                      }
                                    },
                                    label: 'Task Title',
                                    prefix: Icons.title),
                                SizedBox(
                                  height: 10.0,
                                ),
                                defaultFormField(
                                    controller: timeController,
                                    type: TextInputType.datetime,
                                    validate: (value) {
                                      if (value.isEmpty) {
                                        return 'time mustn\'t be empty';
                                      }
                                    },
                                    label: 'Task Time',
                                    onTap: () {
                                      showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                      ).then((value) {
                                        timeController.text=value!.format(context).toString();
                                      });
                                    },
                                    prefix: Icons.watch_later_outlined),
                                SizedBox(
                                  height: 10.0,
                                ),
                                defaultFormField(
                                    controller: dateController,
                                    type: TextInputType.datetime,
                                    validate: (value) {
                                      if (value.isEmpty) {
                                        return 'date mustn\'t be empty';
                                      }
                                    },
                                    label: 'Task date',
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.parse(
                                            '2022-12-31'),
                                      ).then((value) {
                                        dateController.text =
                                            DateFormat.yMMMd().format(value!);
                                      });
                                    },
                                    prefix: Icons.calendar_today)
                              ],

                            ),
                          ),
                        )


                    )).closed.then((value) {
                  cubit.changeBottomSheetState(isShown: false, icon: Icons.edit);
                });

                cubit.changeBottomSheetState(isShown: true, icon: Icons.add);

              }
            },
            backgroundColor: defaultColor,
            child: Icon(cubit.fabIcon),
          ),
          bottomNavigationBar: CurvedNavigationBar(
            color: defaultColor,
            animationDuration: Duration(milliseconds: 300),
            onTap: (index){
              cubit.changeIndex(index);
            },
            index: cubit.currentIndex,
            backgroundColor: Colors.white,
            items: [
              Icon(
                Icons.menu,
                color: Colors.white,
              ),
              Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
              ),
              Icon(
                  Icons.archive_outlined,
                  color: Colors.white,
              ),
            ],
          ),
        );

      },
    );
  }
}
