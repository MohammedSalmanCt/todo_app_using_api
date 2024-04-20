import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_app_using_api/screen/add_page.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}
class _TodoListPageState extends State<TodoListPage> {
  List items=[];
  bool isLoading=true;
  Future<void> navigateToAddPage()async{
    final
     route=MaterialPageRoute(builder: (context) {
       return AddTodo();
     });
    await Navigator.push(context, route);
    setState(() {
      isLoading=true;
    });
    fetchTodo();
  }
 Future<void> navigateToEditPage(Map item)async{
    final
     route=MaterialPageRoute(builder: (context) {
       return AddTodo(todo: item,);
     });
   await Navigator.push(context, route);
  setState(() {
    isLoading=true;
  });
  fetchTodo();
  }

  Future<void> deleteId(String id,BuildContext context)async{
    final url='https://api.nstack.in/v1/todos/$id';
    final uri=Uri.parse(url);
    final response=await http.delete(uri);
    if(response.statusCode==200)
      {
        setState(() {
          items=items.where((element) => element['_id'] !=id).toList();
        });
      }
    else
      {
        showSnackBar("Deleted Success", false, context);
      }
  }
  Future<void> fetchTodo()
  async {
    final url='https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri=Uri.parse(url);
    final response=await http.get(uri);
  if(response.statusCode==200)
    {
      final body=response.body;
      Map json=jsonDecode(body);
     final result=json['items'] as List;
     setState(() {
       items=result;
       print(items.length);
     });
    }
  else{
    print(response.statusCode);
  }
  setState(() {
    isLoading=false;
  });
  }
  @override
  void initState() {
    fetchTodo();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text("Todo List"),
      ),
      body: Visibility(
        visible: isLoading,
        child: Center(
          child: CircularProgressIndicator(),
        ),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              print(items.length);
              final item=items[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(item['title']),
                  subtitle: Text(item["description"]),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(child: Text("Edit"),
                        value: "edit",
                        onTap: () {
                          navigateToEditPage(item);
                        },),
                        PopupMenuItem(child: Text("Delete"),value: "delete",
                        onTap: () {
                          deleteId(item['_id'],context);
                        },)
                      ];
                    },
                  ),
                ),
              );
            },),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed:() => navigateToAddPage(),
        label: Text("Add Todo"),
      ),
    );
  }
}
