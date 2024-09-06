import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  String id;
  String title;
  String note;
  String priority;
  DateTime dueDate;
  String category;
  String tags;
  bool isDone;
  String? attachmentUrl;
  String uid;

  Todo({
    required this.id,
    required this.title,
    required this.note,
    required this.priority,
    required this.dueDate,
    required this.category,
    required this.tags,
    this.isDone = false,
    this.attachmentUrl,
    required this.uid,
  });

  factory Todo.fromDocument(DocumentSnapshot doc) {
    return Todo(
      id: doc.id,
      title: doc['title'] ?? '',
      note: doc['note'] ?? '',
      priority: doc['priority'] ?? '',
      dueDate: (doc['dueDate'] as Timestamp).toDate(),
      category: doc['category'] ?? '',
      tags: doc['tags'] ?? '',
      isDone: doc['isDone'] ?? false,
      attachmentUrl: doc['attachmentUrl'],
      uid: doc['uid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'note': note,
      'priority': priority,
      'dueDate': dueDate,
      'category': category,
      'tags': tags,
      'isDone': isDone,
      'attachmentUrl': attachmentUrl,
      'uid': uid,
    };
  }
}
