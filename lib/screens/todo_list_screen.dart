import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_edit_task_screen.dart';
import '../controllers/todo_controller.dart';

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TodoController todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            const Text(
              'Plantist',
              style: TextStyle(fontSize: 31.0, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 15),
            TextField(
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                todoController.searchQuery.value = value;
              },
            ),
            SizedBox(height: 15),
            Expanded(
              child: Obx(() {
                var filteredTodos = todoController.filteredTodos;
                if (filteredTodos.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tasks available. Please add a new task.',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                } else {
                  // Group and sort todos by due date and priority
                  var groupedTodos = todoController.groupTodos(filteredTodos);

                  // Sort the groups by the date in descending order
                  var sortedGroupKeys = groupedTodos.keys.toList()
                    ..sort((a, b) =>
                        DateTime.parse(a).compareTo(DateTime.parse(b)));

                  return ListView(
                    children: sortedGroupKeys.map((key) {
                      var sortedTodos = groupedTodos[key]!
                        ..sort((a, b) => _getPriorityValue(a.priority)
                            .compareTo(_getPriorityValue(b.priority)));

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            key,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ...sortedTodos.map((task) {
                            return ListTile(
                              tileColor: Colors.white,
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        decoration: task.isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                  ),
                                  if (task.attachmentUrl != null &&
                                      task.attachmentUrl!.isNotEmpty)
                                    Icon(
                                      Icons.attachment,
                                      color: Colors.grey,
                                    ),
                                ],
                              ),
                              subtitle: Text(
                                '${task.dueDate.toLocal()}'.split(' ')[0],
                                style: TextStyle(color: Colors.grey),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddEditTaskScreen(
                                            task: task,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () =>
                                        todoController.deleteTask(task),
                                  ),
                                ],
                              ),
                              leading: Checkbox(
                                shape: CircleBorder(),
                                value: task.isDone,
                                onChanged: (value) =>
                                    todoController.toggleTaskDone(task),
                                activeColor: _getPriorityColor(task
                                    .priority), // Sets the color based on priority
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  );
                }
              }),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditTaskScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                icon: Icon(Icons.add),
                label: Text(
                  'New Reminder',
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getPriorityValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 1;
      case 'medium':
        return 2;
      case 'low':
        return 3;
      case 'none':
        return 4;
      default:
        return 5;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;

      case 'none':
        return Colors.green;
      default:
        return Colors.grey; // Default color for unknown priorities
    }
  }
}
