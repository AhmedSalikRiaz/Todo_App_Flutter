import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../controllers/todo_controller.dart';
import '../models/todo_model.dart';

class AddEditTaskScreen extends StatelessWidget {
  final TodoController todoController = Get.find();
  final Todo? task;

  AddEditTaskScreen({this.task}); // Update the constructor

  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController dueTimeController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();

  final List<String> priorityOptions = ['None', 'Low', 'Medium', 'High'];
  String? selectedPriority = 'None';
  String? attachmentUrl;

  @override
  Widget build(BuildContext context) {
    // If task is not null, populate the controllers with task data
    if (task != null) {
      titleController.text = task!.title;
      noteController.text = task!.note;
      selectedPriority = task!.priority.isEmpty ? 'None' : task!.priority;
      dueDateController.text = task!.dueDate.toIso8601String().split('T')[0];
      dueTimeController.text =
          task!.dueDate.toIso8601String().split('T').length > 1
              ? task!.dueDate.toIso8601String().split('T')[1].substring(0, 5)
              : '';
      categoryController.text = task!.category;
      tagsController.text = task!.tags;
      attachmentUrl = task!.attachmentUrl;
    }

    void _submitTask() {
      if (titleController.text.isEmpty || dueDateController.text.isEmpty) {
        Get.snackbar('Error', 'Title and Due Date are required!',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      DateTime dueDateTime;
      if (dueTimeController.text.isEmpty) {
        dueDateTime = DateTime.parse('${dueDateController.text}T00:00:00');
      } else {
        // Ensure the time format is valid
        try {
          final timeParts = dueTimeController.text.split(':');
          if (timeParts.length == 2) {
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);

            final formattedTime =
                '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
            dueDateTime =
                DateTime.parse('${dueDateController.text}T$formattedTime:00');
          } else {
            throw FormatException('Invalid time format');
          }
        } catch (e) {
          Get.snackbar('Error', 'Invalid time format!',
              snackPosition: SnackPosition.BOTTOM);
          return;
        }
      }

      if (task == null) {
        // Add new task
        todoController.addTask(
          titleController.text,
          noteController.text,
          selectedPriority ?? 'None',
          dueDateTime,
          categoryController.text,
          tagsController.text,
          attachmentUrl,
        );
      } else {
        // Update existing task
        todoController.updateTask(
          task!.id,
          titleController.text,
          noteController.text,
          selectedPriority ?? 'None',
          dueDateTime,
          categoryController.text,
          tagsController.text,
          attachmentUrl,
        );
      }
      Navigator.pop(context);
    }

    Future<void> _pickAttachment() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('attachments/${pickedFile.name}');
        final uploadTask = storageRef.putFile(File(pickedFile.path));

        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        attachmentUrl = downloadUrl;
        Get.snackbar('Success', 'File uploaded successfully!',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'No file selected!',
            snackPosition: SnackPosition.BOTTOM);
      }
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 60, // Increase the height of the top row
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 18), // Increase text size
                      ),
                    ),
                    Text(
                      task == null ? 'New Reminder' : 'Edit Reminder',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    GetBuilder<TodoController>(
                      builder: (_) {
                        bool isDisabled = titleController.text.isEmpty ||
                            dueDateController.text.isEmpty;
                        return TextButton(
                          onPressed: isDisabled ? null : _submitTask,
                          child: Text(
                            task == null ? 'Add' : 'Update',
                            style: TextStyle(
                                color: isDisabled ? Colors.grey : Colors.blue,
                                fontSize: 18), // Increase text size
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => todoController.update(),
              ),
              SizedBox(height: 10),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    dueDateController.text =
                        pickedDate.toIso8601String().split('T')[0];
                    todoController.update();
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: dueDateController,
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  // Parse the time from the controller
                  TimeOfDay initialTime;
                  if (dueTimeController.text.isNotEmpty) {
                    final timeParts = dueTimeController.text.split(':');
                    initialTime = TimeOfDay(
                      hour: int.parse(timeParts[0]),
                      minute: int.parse(timeParts[1]),
                    );
                  } else {
                    initialTime = TimeOfDay.now();
                  }

                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: initialTime,
                    builder: (BuildContext context, Widget? child) {
                      return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      );
                    },
                  );
                  if (pickedTime != null) {
                    final now = DateTime.now();
                    final formattedTime = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    ).toIso8601String().split('T')[1].substring(0, 5);
                    dueTimeController.text = formattedTime;
                    todoController.update();
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: dueTimeController,
                    decoration: InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: priorityOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  selectedPriority = newValue;
                },
              ),
              SizedBox(height: 10),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: tagsController,
                decoration: InputDecoration(
                  labelText: 'Tags',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickAttachment,
                icon: Icon(Icons.attach_file),
                label: Text('Attach a file'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
