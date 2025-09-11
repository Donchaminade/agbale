import 'package:flutter/material.dart';
import 'package:abgbale/models/note_todo.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:intl/intl.dart';

class NotesTodosScreen extends StatefulWidget {
  const NotesTodosScreen({super.key});

  @override
  State<NotesTodosScreen> createState() => _NotesTodosScreenState();
}

class _NotesTodosScreenState extends State<NotesTodosScreen> {
  final ApiService _apiService = ApiService();
  List<NoteTodo> _notesTodos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotesTodos();
  }

  Future<void> _fetchNotesTodos() async {
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
    final newNoteTodo = await showDialog<NoteTodo>(
      context: context,
      builder: (context) => NoteTodoFormDialog(),
    );

    if (newNoteTodo != null) {
      try {
        final createdNoteTodo = await _apiService.createNoteTodo(newNoteTodo, newNoteTodo.userId); // Pass userId
        if (createdNoteTodo != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note/Todo added successfully!')),
          );
          _fetchNotesTodos(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add note/todo.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding note/todo: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _editNoteTodo(NoteTodo noteTodo) async {
    final updatedNoteTodo = await showDialog<NoteTodo>(
      context: context,
      builder: (context) => NoteTodoFormDialog(noteTodo: noteTodo),
    );

    if (updatedNoteTodo != null) {
      try {
        final success = await _apiService.updateNoteTodo(updatedNoteTodo);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note/Todo updated successfully!')),
          );
          _fetchNotesTodos(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update note/todo.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating note/todo: ${e.toString()}')),
        );
      }
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

class NoteTodoFormDialog extends StatefulWidget {
  final NoteTodo? noteTodo;

  const NoteTodoFormDialog({super.key, this.noteTodo});

  @override
  State<NoteTodoFormDialog> createState() => _NoteTodoFormDialogState();
}

class _NoteTodoFormDialogState extends State<NoteTodoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _selectedType = 'note';
  String _selectedStatus = 'en_attente';
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.noteTodo?.title ?? '');
    _contentController = TextEditingController(text: widget.noteTodo?.content ?? '');
    _selectedType = widget.noteTodo?.type ?? 'note';
    _selectedStatus = widget.noteTodo?.status ?? 'en_attente';
    _selectedDueDate = widget.noteTodo?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final userId = await ApiService().fetchUserData().then((user) => user?.id ?? 0); // Get userId from fetched user data

      final newNoteTodo = NoteTodo(
        id: widget.noteTodo?.id ?? 0, // ID will be ignored for new notes/todos by API
        userId: userId, // Use fetched userId
        title: _titleController.text,
        content: _contentController.text.isEmpty ? null : _contentController.text,
        type: _selectedType,
        status: _selectedStatus,
        creationDate: widget.noteTodo?.creationDate ?? DateTime.now(),
        dueDate: _selectedDueDate,
      );
      Navigator.of(context).pop(newNoteTodo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.noteTodo == null ? 'Add New Note/Todo' : 'Edit Note/Todo'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Content (Optional)'),
                maxLines: 3,
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'note', child: Text('Note')),
                  DropdownMenuItem(value: 'todo', child: Text('Todo')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'en_attente', child: Text('En attente')),
                  DropdownMenuItem(value: 'en_cours', child: Text('En cours')),
                  DropdownMenuItem(value: 'terminé', child: Text('Terminé')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              ListTile(
                title: Text(_selectedDueDate == null
                    ? 'Select Due Date (Optional)'
                    : 'Due Date: ${DateFormat('yyyy-MM-dd').format(_selectedDueDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text(widget.noteTodo == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}