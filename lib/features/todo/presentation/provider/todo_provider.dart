// lib/features/todo/presentation/provider/todo_provider.dart
import 'package:flutter/material.dart';
import 'package:kalender/core/database/database_helper.dart';
import 'package:kalender/core/utils/notification_helper.dart'; // Impor helper notifikasi
import 'package:kalender/features/calendar/domain/entities/event.dart'; // Impor Event untuk notifikasi
import 'package:kalender/features/todo/domain/todo.dart';

class TodoProvider extends ChangeNotifier {
  List<Todo> _todos = [];
  List<Todo> get todos => _todos;

  final dbHelper = DatabaseHelper.instance;
  final notificationHelper = NotificationHelper(); // Instance helper

  TodoProvider() {
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('todos', orderBy: 'id DESC');
    _todos = List.generate(maps.length, (i) => Todo.fromMap(maps[i]));
    notifyListeners();
  }

  Future<void> addTodo(String title,
      {DateTime? dueDate, TimeOfDay? reminderTime}) async {
    final newTodo =
        Todo(title: title, dueDate: dueDate, reminderTime: reminderTime);
    final db = await dbHelper.database;
    final id = await db.insert('todos', newTodo.toMap());

    // Jadwalkan notifikasi jika ada pengingat
    await _scheduleNotification(newTodo.copyWith(id: id));
    await fetchTodos();
  }

  Future<void> updateTodo(Todo todo) async {
    final db = await dbHelper.database;
    await db
        .update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);

    // Jadwalkan ulang notifikasi
    await _scheduleNotification(todo);
    await fetchTodos();
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);
    if (updatedTodo.isCompleted) {
      // Batalkan notifikasi jika tugas selesai
      await notificationHelper.cancelNotification(updatedTodo.id!);
    }
    await updateTodo(updatedTodo);
  }

  Future<void> deleteTodo(int id) async {
    final db = await dbHelper.database;
    await db.delete('todos', where: 'id = ?', whereArgs: [id]);
    // Batalkan notifikasi
    await notificationHelper.cancelNotification(id);
    await fetchTodos();
  }

  // --- FUNGSI BARU UNTUK MENJADWALKAN NOTIFIKASI ---
  Future<void> _scheduleNotification(Todo todo) async {
    // Batalkan notifikasi lama terlebih dahulu untuk menghindari duplikasi
    await notificationHelper.cancelNotification(todo.id!);

    // Hanya jadwalkan jika tugas belum selesai dan punya tanggal/waktu pengingat
    if (!todo.isCompleted &&
        todo.dueDate != null &&
        todo.reminderTime != null) {
      // Buat "event" palsu dari data Todo untuk dikirim ke notification helper
      final fakeEvent = Event(
        id: todo.id,
        title: todo.title,
        date: todo.dueDate!,
        startTime: todo.reminderTime!,
        endTime:
            todo.reminderTime!, // endTime tidak relevan untuk notifikasi tugas
      );
      // Jadwalkan notifikasi 0 menit sebelum waktu pengingat (tepat waktu)
      await notificationHelper.scheduleNotification(fakeEvent, 0);
    }
  }
}
