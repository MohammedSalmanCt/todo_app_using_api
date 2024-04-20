import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

void showSnackBar(String message,bool status,BuildContext context)
{
  final snackBar=SnackBar(content: Text(message,style: TextStyle(
      color:status?Colors.black:Colors.white
  ),),
    backgroundColor: status?Colors.white:Colors.red,);
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class AddTodo extends StatefulWidget {
  const AddTodo({super.key, this.todo});
final Map? todo;
  @override
  State<AddTodo> createState() => _AddTodoState();
}
class _AddTodoState extends State<AddTodo> {
  TextEditingController titleController=TextEditingController();
  TextEditingController descriptionController=TextEditingController();
 void submitData(BuildContext context)
  async {
final title=titleController.text.trim();
final description=descriptionController.text.trim();
final body={
  "title": title,
  "description": description,
  "is_completed": false
};
  final url="https://api.nstack.in/v1/todos";
  final uri=Uri.parse(url);
  final response=await http.post(uri,body: jsonEncode(body),
      headers: {'Content-Type':'application/json'}
  );
  if(response.statusCode==201)
    {
      titleController.text='';
      descriptionController.text='';
      print("success");
      showSnackBar("Success",true,context);
    }
  else{
    print("failed");
    print(response.body);
    showSnackBar("Failed",false,context);
  }
  }

  Future<void> updateData(BuildContext context)
  async {
   if(widget.todo==null){
     return;
   }
   final id=widget.todo!['_id'];
   final isCompleted=widget.todo!['is_completed'];
final title=titleController.text.trim();
final description=descriptionController.text.trim();
final body={
  "title": title,
  "description": description,
  "is_completed": isCompleted
};
  final url="https://api.nstack.in/v1/todos/$id";
  final uri=Uri.parse(url);
  final response=await http.put(uri,body: jsonEncode(body),
      headers: {'Content-Type':'application/json'}
  );
  if(response.statusCode==200)
    {
      print("success");
      showSnackBar("Updated Success",true,context);
    }
  else{
    print("failed");
    print(response.body);
    showSnackBar("Failed",false,context);
  }
  }

  bool isEdit=false;
 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.todo !=null)
      {
        isEdit=true;
        titleController=TextEditingController(text: widget.todo!['title']);
        descriptionController=TextEditingController(text: widget.todo!['description']);
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         backgroundColor: Colors.black54,
         automaticallyImplyLeading: true,
         title: Text(isEdit?"Edit Todo":"Add Todo"),
       ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: titleController,
            decoration:InputDecoration(
              hintText: "Title",
            ) ,
          ),
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              hintText: 'Description',
            ),
            maxLines: 8,
            // minLines: 5,
            keyboardType: TextInputType.multiline,
          ),
          SizedBox(height: 30,),
         isEdit?ElevatedButton(
             onPressed:() => updateData(context),
             child: Text('Update'))
             :ElevatedButton(
              onPressed: () {
                return submitData(context);
              },
              child: Text('Submit'))
        ],
      ),
    );
  }
}
