import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// --- TAMBAHAN BARU: Enum untuk aturan pengulangan ---
enum RecurrenceType { none, daily, weekly, monthly }

class Event extends Equatable {
  final int? id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int colorValue;
  // --- TAMBAHAN BARU: Properti untuk pengulangan ---
  final RecurrenceType recurrenceType;
  final DateTime? untilDate;

  const Event({
    this.id,
    required this.title,
    this.description = '',
    required this.date,
    required this.startTime,
    required this.endTime,
    this.colorValue = 0xFF2196F3, // Warna biru sebagai default
    this.recurrenceType = RecurrenceType.none, // Default tidak berulang
    this.untilDate,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        startTime,
        endTime,
        colorValue,
        recurrenceType,
        untilDate,
      ];

  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? colorValue,
    RecurrenceType? recurrenceType,
    DateTime? untilDate,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      colorValue: colorValue ?? this.colorValue,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      untilDate: untilDate ?? this.untilDate,
    );
  }
}
