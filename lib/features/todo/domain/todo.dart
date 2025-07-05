// lib/features/todo/domain/todo.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // Impor untuk TimeOfDay

class Todo extends Equatable {
  final int? id;
  final String title;
  final bool isCompleted;
  final DateTime? dueDate;
  final TimeOfDay? reminderTime; // <-- FIELD BARU

  const Todo({
    this.id,
    required this.title,
    this.isCompleted = false,
    this.dueDate,
    this.reminderTime, // <-- TAMBAHKAN DI CONSTRUCTOR
  });

  Todo copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? dueDate,
    TimeOfDay? reminderTime, // <-- TAMBAHKAN DI COPYWITH
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      reminderTime:
          reminderTime ?? this.reminderTime, // <-- TAMBAHKAN DI COPYWITH
    );
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    TimeOfDay? reminder;
    if (map['reminderTime'] != null) {
      final parts = (map['reminderTime'] as String).split(':');
      reminder =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return Todo(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      reminderTime: reminder, // <-- PARSE DARI STRING
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'dueDate': dueDate?.toIso8601String(),
      // --- UBAH TIMEODAY MENJADI STRING ---
      'reminderTime': reminderTime != null
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : null,
    };
  }

  @override
  List<Object?> get props => [id, title, isCompleted, dueDate, reminderTime];
}
