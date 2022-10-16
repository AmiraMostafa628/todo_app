import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/Network/styles/colors.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultFormField(
{
  required String label,
  required IconData prefix,
  FormFieldValidator? validate,
  Function? onTap,
  required TextEditingController controller,
  required TextInputType type,


}
    )=>TextFormField(
  controller: controller,
  keyboardType: type,
  validator:validate,
  onTap: (){
    if (onTap != null)
     return onTap();
    else
      return;
  },
  decoration: InputDecoration(
    labelText: label,
    prefixIcon: Icon(prefix),
    border: OutlineInputBorder()

  ),


);

Widget myDivider() =>Padding(
  padding: const EdgeInsetsDirectional.only(start: 10.0),
  child: Container(
    width: double.infinity,
    height: 1.0,
    color: Colors.grey[300],
  ),
);


Widget buildTaskItem(Map model,context){
  return Dismissible(
      key: Key(model['id'].toString()),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius:40,
            backgroundColor: defaultColor,
            child: Text(
              '${model['time']}',
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${model['title']}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                ),
              ),
              Text('${model['date']}',
                style: TextStyle(
                    color: Colors.grey
                ),
              ),
            ],
          ),
          Spacer(),
          IconButton(
              onPressed: (){
                TodoCubit.get(context).updateDatabase(status: 'done', id: model['id']);
              },
              icon: Icon(Icons.check_box,
                color: Colors.green,
              )),
          IconButton(
              onPressed: (){
                TodoCubit.get(context).updateDatabase(status: 'archive', id: model['id']);
              },
              icon: Icon(Icons.archive_outlined,
                color: Colors.black54,
              )),

        ],
      ),
    ),
    onDismissed: (direction){
      TodoCubit.get(context).deleteFromDatabase(id: model['id']);
    },

  );
}

Widget taskBuilder({required task})
{
  return ConditionalBuilder(
    condition: task.length>0,
    builder: (context)=>ListView.separated(
        itemBuilder:(context,index)=>buildTaskItem(task[index],context) ,
        separatorBuilder:(context,index)=> myDivider(),
        itemCount: task.length),
    fallback:(context)=> Center(child:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('assets/images/icon.png'),
              height: 100.0,
              width: 100.0,
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'No Tasks yet,Please add some Tasks ',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w800
              ),

            )
          ],
        )
    ) ,

  );
}