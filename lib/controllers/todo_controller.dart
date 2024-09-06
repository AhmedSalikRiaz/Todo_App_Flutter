import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/todo_model.dart';

class TodoController extends GetxController {
  var todos = <Todo>[].obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTodos();
  }

  void fetchTodos() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var snapshot = await FirebaseFirestore.instance
            .collection('todos')
            .where('uid', isEqualTo: user.uid)
            .get();
        var fetchedTodos =
            snapshot.docs.map((doc) => Todo.fromDocument(doc)).toList();
        todos.assignAll(fetchedTodos);
        print('Fetched todos: ${todos.length}');
      }
    } catch (error) {
      print('Failed to fetch todos: $error');
    }
  }

  void addTask(String title, String note, String priority, DateTime dueDate,
      String category, String tags, String? attachmentUrl) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var newTodo = Todo(
        id: '', // Temporary ID
        title: title,
        note: note,
        priority: priority,
        dueDate: dueDate,
        category: category,
        tags: tags,
        attachmentUrl: attachmentUrl,
        uid: user.uid,
      );

      FirebaseFirestore.instance
          .collection('todos')
          .add(newTodo.toMap())
          .then((docRef) {
        newTodo.id = docRef.id; // Update the ID with the actual document ID
        FirebaseFirestore.instance
            .collection('todos')
            .doc(docRef.id)
            .update(newTodo.toMap());
        fetchTodos();
      });
    }
  }

  void deleteTask(Todo todo) async {
    if (todo.attachmentUrl != null && todo.attachmentUrl!.isNotEmpty) {
      try {
        // Get the reference to the attachment
        final storageRef =
            FirebaseStorage.instance.refFromURL(todo.attachmentUrl!);
        // Delete the attachment
        await storageRef.delete();
        print('Attachment deleted successfully');
      } catch (e) {
        print('Failed to delete attachment: $e');
      }
    }

    // Delete the document from Firestore
    await FirebaseFirestore.instance.collection('todos').doc(todo.id).delete();
    fetchTodos();
  }

  void updateTask(String id, String title, String note, String priority,
      DateTime dueDate, String category, String tags, String? attachmentUrl) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var updatedTodo = Todo(
        id: id,
        title: title,
        note: note,
        priority: priority,
        dueDate: dueDate,
        category: category,
        tags: tags,
        attachmentUrl: attachmentUrl,
        uid: user.uid,
      );

      FirebaseFirestore.instance
          .collection('todos')
          .doc(id)
          .update(updatedTodo.toMap());
      fetchTodos();
    }
  }

  void toggleTaskDone(Todo todo) {
    todo.isDone = !todo.isDone;
    FirebaseFirestore.instance
        .collection('todos')
        .doc(todo.id)
        .update(todo.toMap());
    fetchTodos();
  }

  // Group todos based on dueDate
  Map<String, List<Todo>> groupTodos(List<Todo> filteredTodos) {
    var grouped = <String, List<Todo>>{};
    for (var todo in filteredTodos) {
      var key = todo.dueDate.toLocal().toString().split(' ')[0];
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(todo);
    }
    return grouped;
  }

  List<Todo> get filteredTodos {
    if (searchQuery.value.isEmpty) {
      return todos;
    } else {
      return todos
          .where((todo) =>
              todo.title
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              todo.note
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              todo.category
                  .toLowerCase()
                  .contains(searchQuery.value.toLowerCase()) ||
              todo.tags.toLowerCase().contains(searchQuery.value.toLowerCase()))
          .toList();
    }
  }
}
