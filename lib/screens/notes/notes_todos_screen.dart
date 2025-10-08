import 'dart:ui';
import 'package:abgbale/models/note_todo.dart';
import 'package:abgbale/screens/notes/add_edit_note_todo_screen.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotesTodosScreen extends StatefulWidget {
  const NotesTodosScreen({super.key});

  @override
  State<NotesTodosScreen> createState() => _NotesTodosScreenState();
}

class _NotesTodosScreenState extends State<NotesTodosScreen> {
  final ApiService _apiService = ApiService();
  Future<void>? _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = _fetchNotesTodos();
  }

  Future<void> _fetchNotesTodos() async {
    setState(() {}); // Trigger rebuild to show loading indicator
    try {
      // This is a bit of a hack to ensure the future is not null
      await _apiService.fetchNotesTodos();
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _navigateToAddEditScreen([NoteTodo? noteTodo]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => AddEditNoteTodoScreen(noteTodo: noteTodo)),
    );
    if (result == true && mounted) {
      setState(() => _fetchFuture = _fetchNotesTodos());
    }
  }

  Future<void> _deleteNoteTodo(int noteTodoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note/Todo'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final success = await _apiService.deleteNoteTodo(noteTodoId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted successfully!'), backgroundColor: Colors.green),
          );
          setState(() => _fetchFuture = _fetchNotesTodos());
        } else {
          throw Exception('Failed to delete item.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showNoteDetailsPopup(BuildContext context, NoteTodo item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900]?.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
            IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.of(context).pop()),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              if (item.content != null && item.content!.isNotEmpty)
                _buildDetailRow(context, Icons.description_outlined, 'Content', item.content!),
              _buildDetailRow(context, Icons.category_outlined, 'Type', item.type),
              if (item.type == 'todo') ...[
                _buildDetailRow(context, Icons.task_alt_outlined, 'Status', item.status),
                if (item.dueDate != null)
                  _buildDetailRow(context, Icons.event_busy_outlined, 'Due Date', DateFormat.yMMMd().format(item.dueDate!)),
              ],
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Notes & Todos'),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(image: AssetImage('assets/onboarding3.png'), fit: BoxFit.cover),
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        SafeArea(
          child: FutureBuilder<List<NoteTodo>>(
            future: _apiService.fetchNotesTodos(), // Directly use the future from the API service
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No items found. Add one!', style: TextStyle(color: Colors.white)));
              }
              final items = snapshot.data!;
              return _buildNotesList(items);
            },
          ),
        ),
      ],
    );
  }

  ListView _buildNotesList(List<NoteTodo> items) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isTodo = item.type == 'todo';
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
                  leading: CircleAvatar(
                    backgroundColor: const Color.fromARGB(255, 1, 43, 160).withOpacity(isTodo ? 1.0 : 0.5),
                    child: Icon(isTodo ? Icons.check_box_outlined : Icons.note_alt_outlined, color: Colors.white),
                  ),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text('Status: ${item.status}', style: const TextStyle(color: Colors.white70)),
                  onTap: () => _showNoteDetailsPopup(context, item),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    onSelected: (value) {
                      if (value == 'edit') _navigateToAddEditScreen(item);
                      if (value == 'delete') _deleteNoteTodo(item.id);
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