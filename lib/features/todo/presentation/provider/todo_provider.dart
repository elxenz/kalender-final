// lib/features/todo/presentation/provider/todo_provider.dart
import 'package:flutter/material.dart';
import 'package:kalender/core/database/database_helper.dart';
import 'package:kalender/core/utils/notification_helper.dart';
import 'package:kalender/features/calendar/domain/entities/event.dart';
import 'package:kalender/features/todo/domain/todo.dart';
import 'package:sqflite/sqflite.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  final dbHelper = DatabaseHelper.instance;
  final notificationHelper = NotificationHelper();

  TodoProvider() {
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    try {
      final db = await dbHelper.database;
      final List<Map<String, dynamic>> maps =
          await db.query('todos', orderBy: 'id DESC');
      _todos = List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
      notifyListeners();
    } on DatabaseException catch (e) {
      if (e.isNoSuchTableError()) {
        _todos = [];
        notifyListeners();
      } else {
        debugPrint("Error Database saat mengambil todos: $e");
      }
    }
  }

  Future<void> addTodo(String title,
      {DateTime? dueDate, TimeOfDay? reminderTime}) async {
    try {
      final newTodo =
          Todo(title: title, dueDate: dueDate, reminderTime: reminderTime);
      final db = await dbHelper.database;
      final data = newTodo.toMap();
      data.remove('id');

      final id = await db.insert('todos', data);
      debugPrint("Todo berhasil ditambahkan dengan ID: $id");

      await _scheduleNotification(newTodo.copyWith(id: id));
      await fetchTodos();
    } catch (e) {
      debugPrint("GAGAL MENAMBAHKAN TODO: $e");
    }
  }

  Future<void> updateTodo(Todo todo) async {
    try {
      final db = await dbHelper.database;
      await db
          .update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
      await _scheduleNotification(todo);
      await fetchTodos();
    } catch (e) {
      debugPrint("Error saat update todo: $e");
    }
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    if (updatedTodo.isCompleted && todo.id != null) {
      await notificationHelper.cancelNotification(updatedTodo.id!);
    }
    await updateTodo(updatedTodo);
  }

  Future<void> deleteTodo(int id) async {
    try {
      final db = await dbHelper.database;
      await db.delete('todos', where: 'id = ?', whereArgs: [id]);
      await notificationHelper.cancelNotification(id);
      await fetchTodos();
    } catch (e) {
      debugPrint("Error saat menghapus todo: $e");
    }
  }

  Future<void> _scheduleNotification(Todo todo) async {
    if (todo.id == null) return;
    await notificationHelper.cancelNotification(todo.id!);
    if (!todo.isCompleted &&
        todo.dueDate != null &&
        todo.reminderTime != null) {
      final fakeEvent = Event(
        id: todo.id,
        title: "Pengingat Tugas: ${todo.title}",
        date: todo.dueDate!,
        startTime: todo.reminderTime!,
        endTime: todo.reminderTime!,
      );
      await notificationHelper.scheduleNotification(fakeEvent, 0);
    }
  }
}
//aden