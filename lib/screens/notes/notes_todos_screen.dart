import 'package:abgbale/screens/notes/add_edit_note_todo_screen.dart';
import 'package:flutter/material.dart';
import 'package:abgbale/models/note_todo.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:intl/intl.dart';

class NotesTodosScreen extends StatefulWidget {
  const NotesTodosScreen({super.key});

  @override
  State<NotesTodosScreen> createState() => _NotesTodosScreenState();
}

class _NotesTodosScreenState extends State<NotesTodosScreen> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  List<NoteTodo> _notesTodos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchNotesTodos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed, refreshing notes/todos list...');
      _fetchNotesTodos();
    }
  }

  Future<void> _fetchNotesTodos() async {
    print('Fetching notes/todos data...');
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final notesTodos = await _apiService.fetchNotesTodos();
      setState(() {
        _notesTodos = notesTodos;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load notes/todos: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addNoteTodo() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddEditNoteTodoScreen()),
    );

    if (result == true && mounted) {
      _fetchNotesTodos(); // Refresh the list if a note/todo was added
    }
  }

  Future<void> _editNoteTodo(NoteTodo noteTodo) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => AddEditNoteTodoScreen(noteTodo: noteTodo)),
    );

    if (result == true && mounted) {
      _fetchNotesTodos(); // Refresh the list if a note/todo was edited
    }
  }

  Future<void> _deleteNoteTodo(int noteTodoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note/Todo'),
        content: const Text('Are you sure you want to delete this note/todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final success = await _apiService.deleteNoteTodo(noteTodoId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note/Todo deleted successfully!')),
          );
          _fetchNotesTodos(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete note/todo.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting note/todo: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes & Todos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNoteTodo,
            tooltip: 'Add New Note/Todo',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _notesTodos.isEmpty
                  ? const Center(child: Text('No notes or todos found. Add a new one!'))
                  : ListView.builder(
                      itemCount: _notesTodos.length,
                      itemBuilder: (context, index) {
                        final item = _notesTodos[index];
                        final isTodo = item.type == 'todo';
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                            leading: CircleAvatar(
                              backgroundColor: isTodo
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.primary,
                              child: Icon(
                                isTodo ? Icons.check_box_outlined : Icons.note_alt_outlined,
                                color: isTodo ? Colors.black : Colors.white,
                              ),
                            ),
                            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (item.content != null && item.content!.isNotEmpty)
                                  Text(item.content!, maxLines: 2, overflow: TextOverflow.ellipsis),
                                Text('Type: ${item.type}'),
                                Text('Status: ${item.status}'),
                                Text('Created: ${DateFormat('yyyy-MM-dd').format(item.creationDate)}'),
                                if (item.dueDate != null)
                                  Text('Due: ${DateFormat('yyyy-MM-dd').format(item.dueDate!)}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editNoteTodo(item),
                                  tooltip: 'Edit Note/Todo',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteNoteTodo(item.id),
                                  tooltip: 'Delete Note/Todo',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
