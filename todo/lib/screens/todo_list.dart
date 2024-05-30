import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo/screens/add_page.dart';
import 'package:http/http.dart' as http;

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List items = [];
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodo();
  }

  Future<void> navigateToAddPage() async{
    final route = MaterialPageRoute(
      builder: (context) => const AddtodoPage(),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading=true;
    });
    fetchTodo();
  }

   Future<void>  navigateToEditPage(Map item) async{
    final route = MaterialPageRoute(
      builder: (context) =>  AddtodoPage(todo:item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading=true;
    });
    fetchTodo();
  }

  Future<void> fetchTodo() async {
    try {
      const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map;
        final result = jsonData['items'] as List;
        setState(() {
          items = result;
        });

        print(result);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      return print(e.runtimeType);
    }
  }

  Future<void> deleteByID(String id) async {
    try {
      const baseUrl = 'https://api.nstack.in/v1/todos/';
      final url = '$baseUrl$id';
      final uri = Uri.parse(url);
      final response = await http.delete(uri);
      if (response.statusCode == 200) {
        final filteredItem =
            items.where((element) => element['_id'] != id).toList();
        setState(() {
          items = filteredItem;
        });
      } else {
        showFailureMessage('Unable to delete');
      }
    } catch (e) {
      return print(e.runtimeType);
    }
  }

  void showFailureMessage(String message) {
    final snackbar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      showCloseIcon: true,
      closeIconColor: Colors.black,
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(item['title']),
                  subtitle: Text(item['description']),
                  trailing: PopupMenuButton(onSelected: (value) {
                    if (value == 'edit') {
                      navigateToEditPage(item);
                    } else if (value == 'delete') {
                      deleteByID(item['_id'] as String);
                    }
                  }, itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        child: Text('Edit'),
                        value: 'edit',
                      ),
                      const PopupMenuItem(
                        child: Text('Delete'),
                        value: 'delete',
                      ),
                    ];
                  }),
                );
              }),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: navigateToAddPage, label: const Text('Add Todo')),
    );
  }
}
