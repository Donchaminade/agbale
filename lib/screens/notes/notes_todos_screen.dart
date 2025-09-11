import 'package:abgbale/models/note_todo.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:flutter/material.dart';

class NotesTodosScreen extends StatefulWidget {
  const NotesTodosScreen({super.key});

  @override
  State<NotesTodosScreen> createState() => _NotesTodosScreenState();
}

class _NotesTodosScreenState extends State<NotesTodosScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<NoteTodo>> _notesTodosFuture;

  @override
  void initState() {
    super.initState();
    _notesTodosFuture = _apiService.fetchNotesTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<NoteTodo>>(
        future: _notesTodosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No notes or todos found.'));
          }

          final notesTodos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: notesTodos.length,
            itemBuilder: (context, index) {
              final item = notesTodos[index];
              final isTodo = item.type == 'todo';
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
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
                  subtitle: item.content != null && item.content!.isNotEmpty 
                      ? Text(item.content!, maxLines: 2, overflow: TextOverflow.ellipsis) 
                      : null,
                  trailing: Chip(
                    label: Text(item.status),
                    backgroundColor: Colors.grey.shade200,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add note/todo functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
