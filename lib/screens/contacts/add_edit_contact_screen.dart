import 'package:abgbale/widgets/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:abgbale/models/contact.dart';
import 'package:abgbale/services/api_service.dart';

class AddEditContactScreen extends StatefulWidget {
  final Contact? contact;

  const AddEditContactScreen({super.key, this.contact});

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _emailController;
  String _selectedImportance = 'moyenne';
  bool _isLoading = false;

  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.contactName ?? '');
    _numberController = TextEditingController(text: widget.contact?.number ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    _selectedImportance = widget.contact?.importanceNote ?? 'moyenne';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final contact = Contact(
        id: widget.contact?.id ?? 0,
        userId: widget.contact?.userId ?? 0,
        contactName: _nameController.text,
        number: _numberController.text.isNotEmpty ? _numberController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        importanceNote: _selectedImportance,
        dateAdded: widget.contact?.dateAdded ?? DateTime.now(),
      );

      try {
        bool success = false;
        if (_isEditing) {
          success = await _apiService.updateContact(contact);
        } else {
          final newContact = await _apiService.createContact(contact);
          success = newContact != null;
        }

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Contact ${ _isEditing ? 'updated' : 'saved' } successfully!'), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop(true); // Return true to indicate success
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to ${ _isEditing ? 'update' : 'save' } contact.'), backgroundColor: Colors.red),
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
          title: Text(_isEditing ? 'Edit Contact' : 'Add Contact'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const SizedBox(height: 24),
            Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person, size: 50),
              ),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Contact Name', prefixIcon: Icon(Icons.person_outline)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a contact name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _numberController,
                    decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedImportance,
                    decoration: const InputDecoration(labelText: 'Importance', prefixIcon: Icon(Icons.star_outline)),
                    items: const [
                      DropdownMenuItem(value: 'faible', child: Text('Faible')),
                      DropdownMenuItem(value: 'moyenne', child: Text('Moyenne')),
                      DropdownMenuItem(value: 'élevée', child: Text('Élevée')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedImportance = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _saveContact,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(_isEditing ? 'Update Contact' : 'Save Contact'),
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
