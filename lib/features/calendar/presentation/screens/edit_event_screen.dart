// lib/features/calendar/presentation/screens/edit_event_screen.dart
import 'package:flutter/material.dart';
import 'package:kalender/features/calendar/domain/entities/event.dart';
import 'package:kalender/features/calendar/presentation/provider/event_provider.dart';
import 'package:provider/provider.dart';

class EditEventScreen extends StatefulWidget {
  final Event? event;
  final DateTime? date;

  const EditEventScreen({
    super.key,
    this.event,
    this.date,
  });

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _selectedColorValue;

  final List<Color> _colors = [
    const Color(0xFF2196F3), // Blue
    const Color(0xFF4CAF50), // Green
    const Color(0xFFFF9800), // Orange
    const Color(0xFFF44336), // Red
    const Color(0xFF9C27B0), // Purple
    const Color(0xFF607D8B), // Blue Grey
    const Color(0xFF795548), // Brown
    const Color(0xFF009688), // Teal
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? '');
    _selectedDate = widget.event?.date ?? widget.date ?? DateTime.now();
    _startTime = widget.event?.startTime ?? TimeOfDay.now();
    _endTime = widget.event?.endTime ??
        TimeOfDay(
            hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute);
    _selectedColorValue = widget.event?.colorValue ?? 0xFF2196F3;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Tambah Acara' : 'Edit Acara'),
        actions: [
          if (widget.event != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteEvent,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul Acara',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Date Picker
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Tanggal'),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 16),

              // Time Pickers
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Mulai'),
                        subtitle: Text(_startTime.format(context)),
                        onTap: () => _selectTime(true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                        title: const Text('Selesai'),
                        subtitle: Text(_endTime.format(context)),
                        onTap: () => _selectTime(false),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Color Picker
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Warna'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _colors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColorValue = color.value;
                              });
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: _selectedColorValue == color.value
                                    ? Border.all(
                                        color: Colors.black,
                                        width: 3,
                                      )
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveEvent,
                  child: Text(widget.event == null ? 'Simpan' : 'Update'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          // Auto-adjust end time if it's before start time
          if (_endTime.hour < _startTime.hour ||
              (_endTime.hour == _startTime.hour &&
                  _endTime.minute <= _startTime.minute)) {
            _endTime = TimeOfDay(
              hour: _startTime.hour + 1,
              minute: _startTime.minute,
            );
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      // Validate time
      if (_endTime.hour < _startTime.hour ||
          (_endTime.hour == _startTime.hour &&
              _endTime.minute <= _startTime.minute)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Waktu selesai harus setelah waktu mulai')),
        );
        return;
      }

      final event = Event(
        id: widget.event?.id,
        title: _titleController.text,
        description: _descriptionController.text,
        date: _selectedDate,
        startTime: _startTime,
        endTime: _endTime,
        colorValue: _selectedColorValue,
      );

      try {
        final eventProvider = context.read<EventProvider>();
        if (widget.event == null) {
          await eventProvider.addEvent(event);
        } else {
          await eventProvider.updateEvent(event);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Acara'),
        content: const Text('Apakah Anda yakin ingin menghapus acara ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.event?.id != null) {
      try {
        await context.read<EventProvider>().deleteEvent(widget.event!.id!);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }
}
