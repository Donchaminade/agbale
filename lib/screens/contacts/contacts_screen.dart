import 'package:flutter/material.dart';
import 'package:abgbale/models/contact.dart';
import 'package:abgbale/services/api_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ApiService _apiService = ApiService();
  List<Contact> _contacts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final contacts = await _apiService.fetchContacts();
      setState(() {
        _contacts = contacts;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load contacts: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addContact() async {
    final newContact = await showDialog<Contact>(
      context: context,
      builder: (context) => ContactFormDialog(),
    );

    if (newContact != null) {
      try {
        final createdContact = await _apiService.createContact(newContact);
        if (createdContact != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact added successfully!')),
          );
          _fetchContacts(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add contact.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding contact: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _editContact(Contact contact) async {
    final updatedContact = await showDialog<Contact>(
      context: context,
      builder: (context) => ContactFormDialog(contact: contact),
    );

    if (updatedContact != null) {
      try {
        final success = await _apiService.updateContact(updatedContact);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact updated successfully!')),
          );
          _fetchContacts(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update contact.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating contact: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteContact(int contactId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to delete this contact?'),
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
        final success = await _apiService.deleteContact(contactId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact deleted successfully!')),
          );
          _fetchContacts(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete contact.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting contact: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addContact,
            tooltip: 'Add New Contact',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _contacts.isEmpty
                  ? const Center(child: Text('No contacts found. Add a new one!'))
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text(contact.contactName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (contact.number != null && contact.number!.isNotEmpty)
                                  Text('Phone: ${contact.number}'),
                                if (contact.email != null && contact.email!.isNotEmpty)
                                  Text('Email: ${contact.email}'),
                                Text('Importance: ${contact.importanceNote}'),
                                Text('Added: ${contact.dateAdded.toLocal().toString().split(' ')[0]}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editContact(contact),
                                  tooltip: 'Edit Contact',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteContact(contact.id),
                                  tooltip: 'Delete Contact',
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

class ContactFormDialog extends StatefulWidget {
  final Contact? contact;

  const ContactFormDialog({super.key, this.contact});

  @override
  State<ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<ContactFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _emailController;
  String _selectedImportance = 'moyenne';

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newContact = Contact(
        id: widget.contact?.id ?? 0, // ID will be ignored for new contacts by API
        userId: widget.contact?.userId ?? 0, // userId will be ignored for new contacts by API
        contactName: _nameController.text,
        number: _numberController.text.isEmpty ? null : _numberController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        importanceNote: _selectedImportance,
        dateAdded: widget.contact?.dateAdded ?? DateTime.now(),
      );
      Navigator.of(context).pop(newContact);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact == null ? 'Add New Contact' : 'Edit Contact'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Contact Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a contact name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Phone Number (Optional)'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (Optional)'),
                keyboardType: TextInputType.emailAddress,
              ),
              DropdownButtonFormField<String>(
                value: _selectedImportance,
                decoration: const InputDecoration(labelText: 'Importance Note'),
                items: const [
                  DropdownMenuItem(value: 'faible', child: Text('Faible')),
                  DropdownMenuItem(value: 'moyenne', child: Text('Moyenne')),
                  DropdownMenuItem(value: 'elevee', child: Text('Élevée')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedImportance = value!;
                  });
                },
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
          child: Text(widget.contact == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}