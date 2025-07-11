// lib/features/calendar/presentation/screens/edit_event_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  // State untuk fitur pengulangan
  late RecurrenceType _recurrenceType;
  DateTime? _untilDate;

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
    _selectedColorValue = widget.event?.colorValue ?? _colors.first.value;

    // Inisialisasi state pengulangan
    _recurrenceType = widget.event?.recurrenceType ?? RecurrenceType.none;
    _untilDate = widget.event?.untilDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Tambah Acara' : 'Edit Acara'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
        actions: [
          if (widget.event != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteEvent,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Judul Acara ---
              Text('Judul Acara', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration(hintText: 'e.g. Rapat Tim'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- Deskripsi ---
              Text('Deskripsi', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration(hintText: 'Detail acara...'),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // --- Pemilih Tanggal & Waktu ---
              _buildPickerCard(
                icon: Icons.calendar_today_outlined,
                label: 'Tanggal',
                value:
                    DateFormat('EEEE, d MMMM y', 'id_ID').format(_selectedDate),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPickerCard(
                      icon: Icons.access_time_outlined,
                      label: 'Mulai',
                      value: _startTime.format(context),
                      onTap: () => _selectTime(isStartTime: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPickerCard(
                      icon: Icons.access_time_outlined,
                      label: 'Selesai',
                      value: _endTime.format(context),
                      onTap: () => _selectTime(isStartTime: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- Bagian Pengulangan ---
              _buildRecurrenceSection(),
              const SizedBox(height: 24),

              // --- Pemilih Warna ---
              Text('Warna Acara', style: textTheme.labelLarge),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
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
                          border: Border.all(
                            color: colorScheme.primary,
                            width: _selectedColorValue == color.value ? 3 : 0,
                          ),
                        ),
                        child: _selectedColorValue == color.value
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveEvent,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              widget.event == null ? 'Simpan Acara' : 'Update Acara',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // Helper untuk dekorasi input
  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  // Helper untuk membuat kartu pemilih
  Widget _buildPickerCard({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.bodySmall),
                Text(value,
                    style: textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceSection() {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pengulangan Acara', style: textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<RecurrenceType>(
          value: _recurrenceType,
          decoration: _inputDecoration(hintText: 'Atur pengulangan'),
          items: const [
            DropdownMenuItem(
                value: RecurrenceType.none, child: Text('Tidak Berulang')),
            DropdownMenuItem(
                value: RecurrenceType.daily, child: Text('Setiap Hari')),
            DropdownMenuItem(
                value: RecurrenceType.weekly, child: Text('Setiap Minggu')),
            DropdownMenuItem(
                value: RecurrenceType.monthly, child: Text('Setiap Bulan')),
          ],
          onChanged: (value) {
            setState(() {
              _recurrenceType = value ?? RecurrenceType.none;
              if (_recurrenceType == RecurrenceType.none) {
                _untilDate = null;
              }
            });
          },
        ),
        if (_recurrenceType != RecurrenceType.none) ...[
          const SizedBox(height: 16),
          _buildPickerCard(
            icon: Icons.event_repeat_outlined,
            label: 'Ulangi Hingga',
            value: _untilDate == null
                ? 'Pilih tanggal'
                : DateFormat('d MMMM y', 'id_ID').format(_untilDate!),
            onTap: _selectUntilDate,
          ),
        ],
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectUntilDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _untilDate ?? _selectedDate.add(const Duration(days: 30)),
      firstDate: _selectedDate,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _untilDate = picked;
      });
    }
  }

  Future<void> _selectTime({required bool isStartTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          // Otomatis sesuaikan waktu selesai jika sebelum waktu mulai
          if ((_endTime.hour < _startTime.hour) ||
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_recurrenceType != RecurrenceType.none && _untilDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Harap tentukan tanggal akhir pengulangan')),
      );
      return;
    }

    // Validasi waktu
    if ((_endTime.hour < _startTime.hour) ||
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
      recurrenceType: _recurrenceType,
      untilDate: _untilDate,
    );

    if (!mounted) {
      return;
    }
    final eventProvider = context.read<EventProvider>();
    final navigator = Navigator.of(context);

    try {
      if (widget.event == null) {
        await eventProvider.addEvent(event);
      } else {
        await eventProvider.updateEvent(event);
      }
      navigator.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan acara: $e')));
      }
    }
  }

  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Acara'),
        content: const Text(
            'Apakah Anda yakin ingin menghapus acara ini? Ini akan menghapus semua pengulangannya.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.event?.id != null) {
      if (!mounted) {
        return;
      }
      final eventProvider = context.read<EventProvider>();
      final navigator = Navigator.of(context);
      try {
        await eventProvider.deleteEvent(widget.event!.id!);
        navigator.pop(true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal menghapus acara: $e')));
        }
      }
    }
  }
}
//aden