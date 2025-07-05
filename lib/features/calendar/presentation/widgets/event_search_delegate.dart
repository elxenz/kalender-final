// lib/features/calendar/presentation/widgets/event_search_delegate.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kalender/features/calendar/domain/entities/event.dart';

class EventSearchDelegate extends SearchDelegate<Event?> {
  final List<Event> events;

  EventSearchDelegate({required this.events});

  @override
  String get searchFieldLabel => 'Cari acara...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
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
    final queryLower = query.toLowerCase();
    final filteredEvents = events.where((event) {
      return event.title.toLowerCase().contains(queryLower) ||
          event.description.toLowerCase().contains(queryLower);
    }).toList();

    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 8),
            Text('Cari berdasarkan judul atau deskripsi'),
          ],
        ),
      );
    }

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
          leading: CircleAvatar(
            backgroundColor: Color(event.colorValue),
            child: Text(
              event.title.isNotEmpty ? event.title[0].toUpperCase() : 'A',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(event.title),
          subtitle: Text(
            DateFormat.yMMMMEEEEd('id_ID').format(event.date),
          ),
          onTap: () {
            close(context, event);
          },
        );
      },
    );
  }
}
