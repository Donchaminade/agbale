import 'package:abgbale/utils/token_manager.dart';
import 'package:abgbale/widgets/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:abgbale/models/note_todo.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:intl/intl.dart';

class AddEditNoteTodoScreen extends StatefulWidget {
  final NoteTodo? noteTodo;

  const AddEditNoteTodoScreen({super.key, this.noteTodo});

  @override
  State<AddEditNoteTodoScreen> createState() => _AddEditNoteTodoScreenState();
}

class _AddEditNoteTodoScreenState extends State<AddEditNoteTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  String _selectedType = 'note';
  String _selectedStatus = 'en_attente';
  DateTime? _selectedDueDate;
  bool _isLoading = false;

  bool get _isEditing => widget.noteTodo != null;

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

  Future<void> _saveNoteTodo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userId = await TokenManager.getUserId() ?? 0; // Get userId from TokenManager

      final noteTodo = NoteTodo(
        id: widget.noteTodo?.id ?? 0,
        userId: userId,
        title: _titleController.text,
        content: _contentController.text.isNotEmpty ? _contentController.text : null,
        type: _selectedType,
        status: _selectedStatus,
        creationDate: widget.noteTodo?.creationDate ?? DateTime.now(),
        dueDate: _selectedDueDate,
      );

      try {
        bool success = false;
        if (_isEditing) {
          success = await _apiService.updateNoteTodo(noteTodo);
        } else {
          final newNoteTodo = await _apiService.createNoteTodo(noteTodo, userId);
          success = newNoteTodo != null;
        }

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Note/Todo ${ _isEditing ? 'updated' : 'saved' } successfully!'), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to ${ _isEditing ? 'update' : 'save' } note/todo.'), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An error occurred: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FullScreenLoader(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Note/Todo' : 'Add Note/Todo'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const SizedBox(height: 24),
            Center(
              child: Icon(
                _selectedType == 'todo' ? Icons.check_box_outlined : Icons.note_alt_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: 'Content (Optional)', prefixIcon: Icon(Icons.description)),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Type', prefixIcon: Icon(Icons.category)),
                    items: const [
                      DropdownMenuItem(value: 'note', child: Text('Note')),
                      DropdownMenuItem(value: 'todo', child: Text('Todo')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status', prefixIcon: Icon(Icons.info_outline)),
                    items: const [
                      DropdownMenuItem(value: 'en_attente', child: Text('En attente')),
                      DropdownMenuItem(value: 'en_cours', child: Text('En cours')),
                      DropdownMenuItem(value: 'terminé', child: Text('Terminé')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(_selectedDueDate == null
                        ? 'Select Due Date (Optional)'
                        : 'Due Date: ${DateFormat('yyyy-MM-dd').format(_selectedDueDate!)}'),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: () => _selectDate(context),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _saveNoteTodo,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_isEditing ? 'Update Note/Todo' : 'Save Note/Todo'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
