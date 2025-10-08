import 'package:abgbale/models/contact.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:abgbale/utils/token_manager.dart';
import 'package:abgbale/widgets/full_screen_loader.dart';
import 'package:flutter/material.dart';

class AddEditContactScreen extends StatefulWidget {
  final Contact? contact;

  const AddEditContactScreen({super.key, this.contact});

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late final TextEditingController _emailController;
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

      final contactData = Contact(
        id: widget.contact?.id ?? 0,
        userId: userId,
        contactName: _nameController.text,
        number: _numberController.text.isNotEmpty ? _numberController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        importanceNote: _selectedImportance,
        dateAdded: widget.contact?.dateAdded ?? DateTime.now(),
      );

      final bool success;
      if (_isEditing) {
        success = await _apiService.updateContact(contactData);
      } else {
        final newContact = await _apiService.createContact(contactData);
        success = newContact != null;
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contact ${ _isEditing ? 'updated' : 'saved' } successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          throw Exception('Failed to save contact.');
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
          title: Text(_isEditing ? 'Edit Contact' : 'Add Contact'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nameController,
                labelText: 'Contact Name',
                icon: Icons.person_outline,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _numberController,
                labelText: 'Phone Number (Optional)',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email (Optional)',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedImportance,
                decoration: InputDecoration(
                  labelText: 'Importance',
                  prefixIcon: const Icon(Icons.star_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'faible', child: Text('Low')),
                  DropdownMenuItem(value: 'moyenne', child: Text('Medium')),
                  DropdownMenuItem(value: 'élevée', child: Text('High')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedImportance = value);
                  }
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveContact,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_isEditing ? 'Update Contact' : 'Save Contact'),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}