// lib/features/calendar/presentation/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart' as table_calendar;
import 'package:calendar_view/calendar_view.dart';

import 'package:kalender/features/calendar/domain/entities/event.dart'
    as app_event;
import 'package:kalender/features/calendar/presentation/provider/event_provider.dart';
import 'package:kalender/features/calendar/presentation/provider/view_provider.dart';
import 'package:kalender/features/calendar/presentation/screens/edit_event_screen.dart';
import 'package:kalender/features/calendar/presentation/screens/event_detail_screen.dart';
import 'package:kalender/features/calendar/presentation/widgets/app_drawer.dart';
import 'package:kalender/features/calendar/presentation/widgets/event_search_delegate.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final EventController _eventController = EventController();
  final GlobalKey<DayViewState> _dayViewKey = GlobalKey();
  final GlobalKey<WeekViewState> _weekViewKey = GlobalKey();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<EventProvider>().getEvents();
      }
    });
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  void _updateTimelineEvents(List<app_event.Event> events) {
    _eventController.removeWhere((_) => true);
    final newEvents = events.map((event) {
      final startTime = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        event.startTime.hour,
        event.startTime.minute,
      );
      final endTime = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        event.endTime.hour,
        event.endTime.minute,
      );
      return CalendarEventData(
        date: startTime,
        startTime: startTime,
        endTime: endTime,
        title: event.title,
        description: event.description,
        color: Color(event.colorValue),
        event: event,
      );
    }).toList();
    _eventController.addAll(newEvents);
  }

  Future<void> _onEventTapped(
      List<CalendarEventData> events, DateTime date) async {
    if (events.isEmpty || !mounted) return;
    final clickedEvent = events.first.event as app_event.Event;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(event: clickedEvent)),
    );
    if (result == true && mounted) {
      context.read<EventProvider>().getEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewProvider = context.watch<ViewProvider>();
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        _updateTimelineEvents(
            eventProvider.events.values.expand((e) => e).toList());
        return Scaffold(
          appBar: _buildAppBar(context, viewProvider, eventProvider),
          drawer: const AppDrawer(),
          body: _buildCalendarView(viewProvider, eventProvider),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (!mounted) return;
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => EditEventScreen(date: _selectedDay)),
              );
              if (result == true && mounted) {
                context.read<EventProvider>().getEvents();
              }
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, ViewProvider viewProvider,
      EventProvider eventProvider) {
    final now = DateTime.now();

    String getTitle() {
      // FIX: Menggunakan 'currentDate' yang merupakan properti yang benar dan ada di kedua state (DayView dan WeekView)
      DateTime? dayViewDate = _dayViewKey.currentState?.currentDate;
      DateTime? weekViewDate = _weekViewKey.currentState?.currentDate;

      switch (viewProvider.currentView) {
        case CalendarView.jadwal:
          return 'Jadwal';
        case CalendarView.hari:
          return DateFormat.yMMMMEEEEd('id_ID')
              .format(dayViewDate ?? _focusedDay);
        case CalendarView.tigaHari:
        case CalendarView.minggu:
          return DateFormat.yMMMM('id_ID').format(weekViewDate ?? _focusedDay);
        case CalendarView.bulan:
          return DateFormat.yMMMM('id_ID').format(_focusedDay);
      }
    }

    return AppBar(
      title: Text(getTitle()),
      elevation: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () async {
            if (!mounted) return;
            final events =
                eventProvider.events.values.expand((e) => e).toList();
            final app_event.Event? selectedEvent =
                await showSearch<app_event.Event?>(
              context: context,
              delegate: EventSearchDelegate(events: events),
            );
            if (selectedEvent != null && mounted) {
              final fakeEventData = CalendarEventData(
                  date: selectedEvent.date,
                  event: selectedEvent,
                  title: selectedEvent.title);
              _onEventTapped([fakeEventData], selectedEvent.date);
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.today),
          onPressed: () {
            setState(() {
              _focusedDay = now;
              _selectedDay = now;
              _dayViewKey.currentState?.jumpToDate(now);
              _weekViewKey.currentState?.jumpToWeek(now);
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalendarView(
      ViewProvider viewProvider, EventProvider eventProvider) {
    switch (viewProvider.currentView) {
      case CalendarView.jadwal:
        return _buildScheduleView(eventProvider);
      case CalendarView.hari:
        return _buildDayView();
      case CalendarView.tigaHari:
        return _buildThreeDayView();
      case CalendarView.minggu:
        return _buildWeekView();
      case CalendarView.bulan:
        return Column(
          children: [
            _buildMonthView(eventProvider),
            Expanded(child: _buildEventListForSelectedDay(eventProvider)),
          ],
        );
    }
  }

  Widget _buildEventListForSelectedDay(EventProvider eventProvider) {
    final selectedDay = _selectedDay ?? DateTime.now();
    final selectedEvents = eventProvider.getEventsForDay(selectedDay);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text(
            "Jadwal untuk ${DateFormat.yMMMMEEEEd('id_ID').format(selectedDay)}",
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
        if (selectedEvents.isEmpty)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Tidak ada acara untuk hari ini.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: selectedEvents.length,
              itemBuilder: (context, index) {
                final event = selectedEvents[index];
                return Card(
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                  margin: const EdgeInsets.symmetric(vertical: 6.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      final fakeEventData = CalendarEventData(
                          date: event.date, event: event, title: event.title);
                      _onEventTapped([fakeEventData], event.date);
                    },
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(width: 8, color: Color(event.colorValue)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(event.title,
                                      style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${event.startTime.format(context)} - ${event.endTime.format(context)}',
                                    style: textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDayView() {
    return DayView(
      key: _dayViewKey,
      controller: _eventController,
      heightPerMinute: 1.2,
      timeLineWidth: 60,
      showVerticalLine: true,
      initialDay: _focusedDay,
      onPageChange: (date, page) => setState(() => _focusedDay = date),
      timeLineBuilder: (date) {
        if (date.minute != 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text("${date.hour}:00",
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        );
      },
      onEventTap: _onEventTapped,
    );
  }

  Widget _buildWeekView() {
    return WeekView(
      key: _weekViewKey,
      controller: _eventController,
      initialDay: _focusedDay,
      onPageChange: (date, page) => setState(() => _focusedDay = date),
      onEventTap: _onEventTapped,
    );
  }

  Widget _buildThreeDayView() {
    return WeekView(
      key: _weekViewKey,
      controller: _eventController,
      initialDay: _focusedDay,
      onPageChange: (date, page) => setState(() => _focusedDay = date),
      onEventTap: _onEventTapped,
    );
  }

  Widget _buildScheduleView(EventProvider eventProvider) {
    final allEvents = eventProvider.events.values.expand((e) => e).toList();
    allEvents.sort((a, b) => a.date.compareTo(b.date));

    final Map<DateTime, List<app_event.Event>> groupedEvents = {};
    for (var event in allEvents) {
      final day = DateTime(event.date.year, event.date.month, event.date.day);
      if (groupedEvents[day] == null) {
        groupedEvents[day] = [];
      }
      groupedEvents[day]!.add(event);
    }

    final sortedDays = groupedEvents.keys.toList()..sort();

    if (sortedDays.isEmpty) {
      // FIX: Menambahkan `const` untuk performa
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text('Tidak ada jadwal acara.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        final day = sortedDays[index];
        final eventsOnDay = groupedEvents[day]!;
        final textTheme = Theme.of(context).textTheme;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  DateFormat.yMMMMEEEEd('id_ID').format(day),
                  style: textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              // FIX: Menggunakan `Column` untuk list item agar lebih rapi
              Column(
                  children: eventsOnDay.map((event) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      final fakeEventData = CalendarEventData(
                          date: event.date, event: event, title: event.title);
                      _onEventTapped([fakeEventData], event.date);
                    },
                    child: Row(
                      children: [
                        Container(
                            width: 5,
                            height: 50, // Memberi tinggi agar konsisten
                            color: Color(event.colorValue)),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 65, // Memberi lebar yang cukup
                          child: Text(
                            event.startTime.format(context),
                            style: textTheme.titleSmall,
                          ),
                        ),
                        Expanded(
                            child: Text(event.title,
                                maxLines: 2, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                );
              }).toList()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthView(EventProvider eventProvider) {
    return table_calendar.TableCalendar<app_event.Event>(
      locale: 'id_ID',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) =>
          table_calendar.isSameDay(_selectedDay, day),
      calendarFormat: table_calendar.CalendarFormat.month,
      availableGestures: table_calendar.AvailableGestures.horizontalSwipe,
      eventLoader: eventProvider.getEventsForDay,
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
      headerStyle: const table_calendar.HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarBuilders: table_calendar.CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;
          return Positioned(
            right: 1,
            bottom: 1,
            // FIX: Menambahkan `const` untuk performa
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                '${events.length}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}
