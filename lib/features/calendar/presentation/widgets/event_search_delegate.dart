// lib/features/calendar/presentation/widgets/event_search_delegate.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kalender/features/calendar/domain/entities/event.dart';

class EventSearchDelegate extends SearchDelegate<Event?> {
  final List<Event> events;

  EventSearchDelegate({required this.events});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(
        child: Text('Masukkan kata kunci pencarian'),
      );
    }

    final filteredEvents = events.where((event) {
      final titleLower = event.title.toLowerCase();
      final descriptionLower = event.description.toLowerCase();
      final queryLower = query.toLowerCase();

      return titleLower.contains(queryLower) ||
          descriptionLower.contains(queryLower);
    }).toList();

    if (filteredEvents.isEmpty) {
      return const Center(
        child: Text('Tidak ada acara yang ditemukan'),
      );
    }

    return ListView.builder(
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.description.isNotEmpty) Text(event.description),
              Text(
                '${DateFormat('dd MMM yyyy').format(event.date)} - ${DateFormat.jm().format(DateTime(
                  event.date.year,
                  event.date.month,
                  event.date.day,
                  event.startTime.hour,
                  event.startTime.minute,
                ))}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: Color(event.colorValue),
            child: Text(
              event.title.isNotEmpty ? event.title[0].toUpperCase() : 'A',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          onTap: () {
            close(context, event);
          },
        );
      },
    );
  }
}
