import 'dart:ui';
import 'package:abgbale/models/contact.dart';
import 'package:abgbale/screens/contacts/add_edit_contact_screen.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:flutter/material.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Contact> _allContacts = [];
  List<Contact> _displayedContacts = [];
  bool _isSearching = false;
  Future<void>? _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = _fetchContacts();
    _searchController.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchContacts() async {
    try {
      final contacts = await _apiService.fetchContacts();
      if (mounted) {
        setState(() {
          _allContacts = contacts;
          _filterContacts();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load contacts: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _displayedContacts = _allContacts.where((contact) {
        return contact.contactName.toLowerCase().contains(query) ||
            (contact.email?.toLowerCase().contains(query) ?? false) ||
            (contact.number?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _navigateToAddEditScreen([Contact? contact]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => AddEditContactScreen(contact: contact)),
    );
    if (result == true && mounted) {
      setState(() => _fetchFuture = _fetchContacts());
    }
  }

  Future<void> _deleteContact(int contactId) async {
    final confirm = await _showDeleteConfirmation();
    if (confirm == true && mounted) {
      try {
        final success = await _apiService.deleteContact(contactId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contact deleted successfully!'), backgroundColor: Colors.green),
          );
          setState(() => _fetchFuture = _fetchContacts());
        } else {
          throw Exception('Failed to delete contact.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: const Text('Are you sure you want to permanently delete this contact?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
  }

  void _showContactDetailsPopup(BuildContext context, Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900]?.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(contact.contactName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
            IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.of(context).pop()),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              if (contact.number != null && contact.number!.isNotEmpty)
                _buildDetailRow(context, Icons.phone_outlined, 'Phone Number', contact.number!),
              if (contact.email != null && contact.email!.isNotEmpty)
                _buildDetailRow(context, Icons.email_outlined, 'Email', contact.email!),
              _buildDetailRow(context, Icons.star_outline, 'Importance', contact.importanceNote),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2196F3)), // Changed to blue
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2196F3); // Define the new primary blue color

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Search...', border: InputBorder.none, hintStyle: TextStyle(color: Colors.white70)),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            )
          : const Text('Contacts'),
      actions: _isSearching
          ? [IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() {
              _isSearching = false;
              _searchController.clear();
            }))]
          : [IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _isSearching = true))],
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/onboarding2.png'), fit: BoxFit.cover),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        SafeArea(
          child: FutureBuilder<void>(
            future: _fetchFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _allContacts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              }
              if (_allContacts.isEmpty) {
                return const Center(child: Text('No contacts found. Add one!', style: TextStyle(color: Colors.white)));
              }
              if (_isSearching && _displayedContacts.isEmpty) {
                return const Center(child: Text('No contacts match your search.', style: TextStyle(color: Colors.white)));
              }
              return _buildContactsList();
            },
          ),
        ),
      ],
    );
  }

  ListView _buildContactsList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: _displayedContacts.length,
      itemBuilder: (context, index) {
        final contact = _displayedContacts[index];
        final initial = contact.contactName.isNotEmpty ? contact.contactName[0].toUpperCase() : '?';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Color(0xFF2196F3), child: Text(initial, style: const TextStyle(color: Colors.white))),
                  title: Text(contact.contactName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text(contact.email ?? contact.number ?? 'No details', style: const TextStyle(color: Colors.white70)),
                  onTap: () => _showContactDetailsPopup(context, contact),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    onSelected: (value) {
                      if (value == 'edit') _navigateToAddEditScreen(contact);
                      if (value == 'delete') _deleteContact(contact.id);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                      const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}