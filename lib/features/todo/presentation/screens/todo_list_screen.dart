// lib/features/todo/presentation/screens/todo_list_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kalender/features/todo/domain/todo.dart';
import 'package:kalender/features/todo/presentation/provider/todo_provider.dart';
import 'package:provider/provider.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todoProvider = context.watch<TodoProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('To-do List')),
      body: todoProvider.todos.isEmpty
          ? _buildEmptyState()
          : _buildTodoList(context, todoProvider.todos),
      floatingActionButton: Builder(
        builder: (dialogContext) => FloatingActionButton(
          onPressed: () => _showAddEditTodoDialog(dialogContext),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_box_outline_blank, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('Belum ada tugas.',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTodoList(BuildContext context, List<Todo> todos) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          child: ListTile(
            onTap: () => _showAddEditTodoDialog(context, todo: todo),
            leading: Checkbox(
              value: todo.isCompleted,
              onChanged: (value) =>
                  context.read<TodoProvider>().toggleTodoStatus(todo),
            ),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isCompleted
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: todo.isCompleted ? Colors.grey : null,
              ),
            ),
            subtitle: _buildSubtitle(context, todo),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () =>
                  context.read<TodoProvider>().deleteTodo(todo.id!),
            ),
          ),
        );
      },
    );
  }

  Widget? _buildSubtitle(BuildContext context, Todo todo) {
    if (todo.dueDate == null) return null;
    final dateText =
        "Jatuh tempo: ${DateFormat.yMMMEd('id_ID').format(todo.dueDate!)}";
    final timeText = todo.reminderTime != null
        ? " - ${todo.reminderTime!.format(context)}"
        : "";
    return Text(dateText + timeText,
        style: const TextStyle(fontSize: 12, color: Colors.grey));
  }

  void _showAddEditTodoDialog(BuildContext context, {Todo? todo}) {
    final textController = TextEditingController(text: todo?.title);
    DateTime? selectedDueDate = todo?.dueDate;
    TimeOfDay? selectedReminderTime = todo?.reminderTime;
    final isEditing = todo != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Tugas' : 'Tugas Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: textController,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'Judul tugas'),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 20),
                      const SizedBox(width: 8),
                      TextButton(
                        child: Text(selectedDueDate == null
                            ? 'Tambah tanggal'
                            : DateFormat.yMMMEd('id_ID')
                                .format(selectedDueDate!)),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDueDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDueDate = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  if (selectedDueDate != null)
                    Row(
                      children: [
                        const Icon(Icons.alarm_outlined, size: 20),
                        const SizedBox(width: 8),
                        TextButton(
                          child: Text(selectedReminderTime == null
                              ? 'Tambah waktu'
                              : selectedReminderTime!.format(context)),
                          onPressed: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime:
                                  selectedReminderTime ?? TimeOfDay.now(),
                            );
                            if (picked != null) {
                              setDialogState(
                                  () => selectedReminderTime = picked);
                            }
                          },
                        ),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (textController.text.isNotEmpty) {
                      final provider = context.read<TodoProvider>();
                      if (isEditing) {
                        provider.updateTodo(todo.copyWith(
                          title: textController.text,
                          dueDate: selectedDueDate,
                          reminderTime: selectedReminderTime,
                        ));
                      } else {
                        provider.addTodo(
                          textController.text,
                          dueDate: selectedDueDate,
                          reminderTime: selectedReminderTime,
                        );
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: Text(isEditing ? 'Simpan' : 'Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
