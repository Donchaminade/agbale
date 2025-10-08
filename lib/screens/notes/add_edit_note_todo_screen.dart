import 'package:abgbale/models/note_todo.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:abgbale/utils/token_manager.dart';
import 'package:abgbale/widgets/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddEditNoteTodoScreen extends StatefulWidget {
  final NoteTodo? noteTodo;

  const AddEditNoteTodoScreen({super.key, this.noteTodo});

  @override
  State<AddEditNoteTodoScreen> createState() => _AddEditNoteTodoScreenState();
}

class _AddEditNoteTodoScreenState extends State<AddEditNoteTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDueDate) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _saveNoteTodo() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final noteTodoData = NoteTodo(
        id: widget.noteTodo?.id ?? 0,
        userId: userId,
        title: _titleController.text,
        content: _contentController.text.isNotEmpty ? _contentController.text : null,
        type: _selectedType,
        status: _selectedStatus,
        creationDate: widget.noteTodo?.creationDate ?? DateTime.now(),
        dueDate: _selectedDueDate,
      );

      final bool success;
      if (_isEditing) {
        success = await _apiService.updateNoteTodo(noteTodoData);
      } else {
        final newNoteTodo = await _apiService.createNoteTodo(noteTodoData);
        success = newNoteTodo != null;
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note/Todo ${ _isEditing ? 'updated' : 'saved' } successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          throw Exception('Failed to save Note/Todo.');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 16),
              _buildTextField(
                controller: _titleController,
                labelText: 'Title',
                icon: Icons.title,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _contentController,
                labelText: 'Content (Optional)',
                icon: Icons.description,
                maxLines: 4,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Type',
                        prefixIcon: const Icon(Icons.category_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'note', child: Text('Note')),
                        DropdownMenuItem(value: 'todo', child: Text('Todo')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        prefixIcon: const Icon(Icons.task_alt_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'en_attente', child: Text('Pending')),
                        DropdownMenuItem(value: 'en_cours', child: Text('In Progress')),
                        DropdownMenuItem(value: 'terminé', child: Text('Completed')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text(
                    _selectedDueDate == null
                        ? 'Select Due Date (Optional)'
                        : 'Due: ${DateFormat.yMMMd().format(_selectedDueDate!)}',
                  ),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveNoteTodo,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_isEditing ? 'Update Note/Todo' : 'Save Note/Todo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }
}