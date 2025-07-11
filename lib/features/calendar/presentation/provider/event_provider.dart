import 'package:flutter/material.dart';
import 'package:kalender/features/calendar/domain/entities/event.dart';
import 'package:kalender/features/calendar/domain/repositories/event_repository.dart';

class EventProvider extends ChangeNotifier {
  final EventRepository eventRepository;

  EventProvider({required this.eventRepository});

  Map<DateTime, List<Event>> _events = {};
  Map<DateTime, List<Event>> get events => _events;

  List<Event> getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  Future<void> getEvents() async {
    final allEvents = await eventRepository.getAllEvents();
    final newEventsMap = <DateTime, List<Event>>{};

    for (var event in allEvents) {
      // Tambahkan acara asli
      _addEventToMap(newEventsMap, event.date, event);

      // --- LOGIKA BARU UNTUK ACARA BERULANG ---
      if (event.recurrenceType != RecurrenceType.none &&
          event.untilDate != null) {
        DateTime currentDate = event.date;

        while (currentDate.isBefore(event.untilDate!)) {
          switch (event.recurrenceType) {
            case RecurrenceType.daily:
              currentDate = currentDate.add(const Duration(days: 1));
              break;
            case RecurrenceType.weekly:
              currentDate = currentDate.add(const Duration(days: 7));
              break;
            case RecurrenceType.monthly:
              currentDate = DateTime(
                  currentDate.year, currentDate.month + 1, currentDate.day);
              break;
            case RecurrenceType.none:
              break;
          }

          if (!currentDate.isAfter(event.untilDate!)) {
            _addEventToMap(
                newEventsMap, currentDate, event.copyWith(date: currentDate));
          }
        }
      }
    }

    _events = newEventsMap;
    notifyListeners();
  }

  // Helper untuk menambahkan acara ke map
  void _addEventToMap(
      Map<DateTime, List<Event>> map, DateTime date, Event event) {
    final day = DateTime(date.year, date.month, date.day);
    if (map[day] == null) {
      map[day] = [];
    }
    map[day]!.add(event);
  }

  Future<void> addEvent(Event event) async {
    await eventRepository.addEvent(event);
    await getEvents();
  }

  Future<void> updateEvent(Event event) async {
    await eventRepository.updateEvent(event);
    await getEvents();
  }

  Future<void> deleteEvent(int id) async {
    await eventRepository.deleteEvent(id);
    await getEvents();
  }
}
