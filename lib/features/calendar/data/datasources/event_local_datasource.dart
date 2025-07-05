// lib/features/calendar/data/datasources/event_local_datasource.dart
import 'package:kalender/features/calendar/data/models/event_model.dart';

abstract class EventLocalDataSource {
  Future<List<EventModel>> getEvents();
  Future<List<EventModel>> getEventsForMonth(DateTime month);
  Future<List<EventModel>> searchEvents(String query);
  Future<int> addEvent(EventModel event);
  Future<void> updateEvent(EventModel event);
  Future<void> deleteEvent(int id);
}

class EventLocalDataSourceImpl implements EventLocalDataSource {
  final Future<Database> database;

  EventLocalDataSourceImpl({required this.database});

  @override
  Future<List<EventModel>> getEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    return List.generate(maps.length, (i) {
      return EventModel.fromMap(maps[i]);
    });
  }

  @override
  Future<List<EventModel>> getEventsForMonth(DateTime month) async {
    final db = await database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'date >= ? AND date <= ?',
      whereArgs: [
        startOfMonth.toIso8601String(),
        endOfMonth.toIso8601String(),
      ],
    );

    return List.generate(maps.length, (i) {
      return EventModel.fromMap(maps[i]);
    });
  }

  @override
  Future<List<EventModel>> searchEvents(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'title LIKE ? OR description LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return EventModel.fromMap(maps[i]);
    });
  }

  @override
  Future<int> addEvent(EventModel event) async {
    final db = await database;
    return await db.insert('events', event.toMap());
  }

  @override
  Future<void> updateEvent(EventModel event) async {
    final db = await database;
    await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  @override
  Future<void> deleteEvent(int id) async {
    final db = await database;
    await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
