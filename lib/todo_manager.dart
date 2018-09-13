import 'package:flutter/material.dart';

import './DTO/todo.dart';
import './todo_control.dart';

// manager to manage the todo items
class TodoManager extends StatefulWidget {
  final todoList = List<ListItem>.generate(
    1200,
    (i) => i % 6 == 0
        ? HeadingItem("Heading $i")
        : MessageItem("Sender $i", "Message body $i"),
  );

  @override
  State<StatefulWidget> createState() {
    print('productmanager createstate');
    return _TodoManager();
  }
}

class _TodoManager extends State<TodoManager> {
  List<ListItem> _todoList = [];

  @override
  void initState() {
    _todoList = widget.todoList;

    //always call in the end
    super.initState();
  }

  void _addTodoTask(String name) {
    // _todoList.add(Todo(name));
  }

  @override
  Widget build(BuildContext context) {
    print('productmanager build');
    return ListView.builder(
      // Let the ListView know how many items it needs to build
      itemCount: _todoList.length,
      // Provide a builder function. This is where the magic happens! We'll
      // convert each item into a Widget based on the type of item it is.
      itemBuilder: (context, index) {
        final item = _todoList[index];

        if (item is HeadingItem) {
          return ListTile(
            title: Text(
              item.heading,
              style: Theme.of(context).textTheme.headline,
            ),
          );
        } else if (item is MessageItem) {
          return ListTile(
            title: Text(item.sender),
            subtitle: Text(item.body),
          );
        }
      },
    );
  }
}
