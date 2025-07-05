// lib/features/calendar/data/models/event_model.dart
import 'package:flutter/material.dart';
import 'package:kalender/features/calendar/domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    super.id,
    required super.title,
    super.description,
    required super.date,
    required super.startTime,
    required super.endTime,
    super.colorValue,
  });

  // Konversi dari Map (data dari database) ke EventModel
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      date: DateTime.parse(map['date']),
      startTime: TimeOfDay(
        hour: int.parse(map['startTime'].split(':')[0]),
        minute: int.parse(map['startTime'].split(':')[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(map['endTime'].split(':')[0]),
        minute: int.parse(map['endTime'].split(':')[1]),
      ),
      colorValue: map['colorValue'] ?? 0xFF2196F3,
    );
  }

  // Konversi dari Event ke EventModel
  factory EventModel.fromEntity(Event event) {
    return EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      date: event.date,
      startTime: event.startTime,
      endTime: event.endTime,
      colorValue: event.colorValue,
    );
  }

  // Konversi dari EventModel ke Event
  Event toEntity() {
    return Event(
      id: id,
      title: title,
      description: description,
      date: date,
      startTime: startTime,
      endTime: endTime,
      colorValue: colorValue,
    );
  }

  // Konversi dari Event/EventModel ke Map (untuk disimpan ke database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'startTime':
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'endTime':
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'colorValue': colorValue,
    };
  }
}
