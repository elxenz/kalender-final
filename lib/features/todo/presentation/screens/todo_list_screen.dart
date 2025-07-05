// lib/features/todo/presentation/screens/todo_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Impor package animasi
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
      appBar: AppBar(
        title: const Text('To-do List'),
      ),
      body: todoProvider.todos.isEmpty
          ? _buildEmptyState()
          : _buildTodoList(context, todoProvider.todos),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditTodoDialog(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ).animate().scale(delay: 500.ms), // <-- ANIMASI PADA FAB
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
    ).animate().fadeIn();
  }

  Widget _buildTodoList(BuildContext context, List<Todo> todos) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onTap: () => _showAddEditTodoDialog(context, todo: todo),
            leading: Checkbox(
              value: todo.isCompleted,
              onChanged: (value) {
                context.read<TodoProvider>().toggleTodoStatus(todo);
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
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
        )
            .animate()
            .fadeIn(duration: 400.ms)
            .slideX(begin: 0.5, end: 0); // <-- ANIMASI PADA ITEM
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
    // ... (kode dialog tidak perlu diubah, karena transisi sudah dihandle oleh AppRouter)
    // ...
  }
}
