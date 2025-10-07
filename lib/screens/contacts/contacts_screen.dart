import 'package:abgbale/screens/contacts/add_edit_contact_screen.dart';
import 'package:flutter/material.dart';
import 'package:abgbale/models/contact.dart';
import 'package:abgbale/services/api_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Contact> _allContacts = [];
  List<Contact> _displayedContacts = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchContacts();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed, refreshing contacts list...');
      _fetchContacts();
    }
  }

  Future<void> _fetchContacts() async {
    print('Fetching contacts data...');
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final contacts = await _apiService.fetchContacts();
      setState(() {
        _allContacts = contacts;
        _displayedContacts = contacts;
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

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _displayedContacts = _allContacts.where((contact) {
        final nameMatch = contact.contactName.toLowerCase().contains(query);
        final emailMatch = contact.email?.toLowerCase().contains(query) ?? false;
        final numberMatch = contact.number?.toLowerCase().contains(query) ?? false;
        return nameMatch || emailMatch || numberMatch;
      }).toList();
    });
  }

  Future<void> _addContact() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddEditContactScreen()),
    );

    if (result == true) {
      _fetchContacts(); // Refresh the list if a contact was added
    }
  }

  Future<void> _editContact(Contact contact) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => AddEditContactScreen(contact: contact)),
    );

    if (result == true) {
      _fetchContacts(); // Refresh the list if a contact was edited
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
          SnackBar(content: Text('Error deleting contact: ${e.toString()}'),
          ),
        );
      }
    }
  }

  AppBar _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchController.clear();
            });
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search contacts...',
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          ),
        ],
      );
    }

    return AppBar(
      title: const Text('Contacts'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _addContact,
          tooltip: 'Add New Contact',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _allContacts.isEmpty
                  ? const Center(child: Text('No contacts found. Add a new one!'))
                  : _displayedContacts.isEmpty
                      ? const Center(child: Text('No contacts match your search.'))
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: _displayedContacts.length,
                          itemBuilder: (context, index) {
                            final contact = _displayedContacts[index];
                            final initial = contact.contactName.isNotEmpty ? contact.contactName[0].toUpperCase() : '?';
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(initial),
                              ),
                              title: Text(contact.contactName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (contact.email != null && contact.email!.isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(Icons.email_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Expanded(child: Text(contact.email!, style: const TextStyle(color: Colors.grey))),
                                      ],
                                    ),
                                  if (contact.number != null && contact.number!.isNotEmpty)
                                    Row(
                                      children: [
                                        const Icon(Icons.phone_outlined, size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(contact.number!, style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.grey),
                                    onPressed: () => _editContact(contact),
                                    tooltip: 'Edit Contact',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _deleteContact(contact.id),
                                    tooltip: 'Delete Contact',
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
    );
  }
}
