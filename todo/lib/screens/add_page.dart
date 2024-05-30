import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class AddtodoPage extends StatefulWidget {
  final Map? todo;
  const AddtodoPage({super.key, this.todo});

  @override
  State<AddtodoPage> createState() => _AddtodoPageState();
}

class _AddtodoPageState extends State<AddtodoPage> {
  List item = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final todo = widget.todo;
    if (widget.todo != null) {
      isEdit = true;
      final title = todo?['title'];
      final description = todo?['description'];
      titleController.text = title;
      descriptionController.text = description;
    } else {
      isEdit = false;
    }
  }

  Future<void> submitData() async {
    //Get the data from form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };
    //Submit the data to the server
    const url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);

    final response = await http.post(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    //Show success or fail message based on status
    if (response.statusCode == 201) {
      titleController.text = '';
      descriptionController.text = '';
      print(response.body);
      showSuccessMessage('Success');
    } else {
      print(response.runtimeType);
      print('Error');
      showFailureMessage('Failed to add');
    }
  }

  Future<void> updateData() async {
    final todo = widget.todo;
    final id = todo?['_id'];

    if (todo == null) {
      print('You can not done this.');
      return;
    }

    if (id == null) {
      print('Todo ID is null.');
      return;
    }

    //Get the data from form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };
    //Submit the data to the server
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);

    final response = await http.put(uri,
        body: jsonEncode(body), headers: {'Content-Type': 'application/json'});

    //Show success or fail message based on status
    if (response.statusCode == 200) {
      print(response.body);
      showSuccessMessage('Updated Successfully');
    } else {
      print(response.runtimeType);
      print('Error');
      showFailureMessage('Failed to upload');
    }
  }

  void showSuccessMessage(String message) {
    final snackbar = SnackBar(
      content: Text(message),
      showCloseIcon: true,
      closeIconColor: Colors.black,
      backgroundColor: Colors.white,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
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
        title: Text(isEdit ? 'Edit todo' : 'Add todo'),
      ),
      body: ListView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width) * 0.1,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(hintText: 'Description'),
            keyboardType: TextInputType.multiline,
            minLines: 5,
            maxLines: 8,
          ),
          const SizedBox(
            height: 25,
          ),
          ElevatedButton(
            onPressed: isEdit ? updateData : submitData,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  const Color.fromARGB(255, 3, 44, 13)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
            ),
            child: Text(isEdit ? 'Update' : 'Submit'),
          ),
        ],
      ),
    );
  }
}
