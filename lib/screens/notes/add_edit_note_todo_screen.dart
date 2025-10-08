import 'dart:ui';
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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) throw Exception('User not authenticated');

      final noteTodoData = NoteTodo(
        id: widget.noteTodo?.id ?? 0,
        userId: userId,
        title: _titleController.text,
        content: _contentController.text.isNotEmpty ? _contentController.text : null,
        type: _selectedType,
        status: _selectedType == 'note' ? 'en_attente' : _selectedStatus,
        creationDate: widget.noteTodo?.creationDate ?? DateTime.now(),
        dueDate: _selectedType == 'note' ? null : _selectedDueDate,
      );

      final success = _isEditing
          ? await _apiService.updateNoteTodo(noteTodoData)
          : (await _apiService.createNoteTodo(noteTodoData)) != null;

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Note/Todo ${ _isEditing ? 'updated' : 'saved' } successfully!'), backgroundColor: Colors.green),
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
    const Color primaryBlue = Color(0xFF2196F3); // Define the new primary blue color

    return FullScreenLoader(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(_isEditing ? 'Edit Note/Todo' : 'Add Note/Todo'),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/onboarding3.png'), // Replace with your background image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
            SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.note_alt_outlined, color: Colors.white.withOpacity(0.8), size: 60),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(labelText: 'Title', icon: Icons.title),
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a title' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(labelText: 'Content (Optional)', icon: Icons.description),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      items: const [
                        DropdownMenuItem(value: 'note', child: Text('Note')),
                        DropdownMenuItem(value: 'todo', child: Text('Todo')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                            if (_selectedType == 'note') {
                              _selectedStatus = 'en_attente';
                              _selectedDueDate = null;
                            }
                          });
                        }
                      },
                      decoration: _buildInputDecoration(labelText: 'Type', icon: Icons.category_outlined),
                      dropdownColor: Colors.grey[800],
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (_selectedType == 'todo') ...[
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        items: const [
                          DropdownMenuItem(value: 'en_attente', child: Text('Pending')),
                          DropdownMenuItem(value: 'en_cours', child: Text('In Progress')),
                          DropdownMenuItem(value: 'terminé', child: Text('Completed')),
                        ],
                        onChanged: (value) {
                          if (value != null) setState(() => _selectedStatus = value);
                        },
                        decoration: _buildInputDecoration(labelText: 'Status', icon: Icons.task_alt_outlined),
                        dropdownColor: Colors.grey[800],
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        tileColor: Colors.white.withOpacity(0.1),
                        leading: Icon(Icons.calendar_today_outlined, color: Colors.white.withOpacity(0.7)),
                        title: Text(
                          _selectedDueDate == null ? 'Select Due Date' : 'Due: ${DateFormat.yMMMd().format(_selectedDueDate!)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () => _selectDate(context),
                      ),
                    ],
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveNoteTodo,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_isEditing ? 'Update Note/Todo' : 'Save Note/Todo'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String labelText, required IconData icon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}