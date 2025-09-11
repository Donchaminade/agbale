import 'package:abgbale/screens/notes/notes_todos_screen.dart';
import 'package:abgbale/screens/contacts/contacts_screen.dart';
import 'package:abgbale/models/user.dart';
import 'package:abgbale/screens/auth/login.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:flutter/material.dart';

class TableauScreen extends StatefulWidget {
  const TableauScreen({super.key});

  @override
  State<TableauScreen> createState() => _TableauScreenState();
}

class _TableauScreenState extends State<TableauScreen> {
  final ApiService _apiService = ApiService();
  Future<User?>? _userFuture;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _userFuture = _apiService.fetchUserData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() async {
    await _apiService.logoutUser();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Widget _buildBody() {
    // Placeholder bodies for each tab
    final List<Widget> widgetOptions = <Widget>[
      _buildDashboardHome(),
      const ContactsScreen(), // To be implemented
      const NotesTodosScreen(), // To be implemented
    ];
    return widgetOptions.elementAt(_selectedIndex);
  }

  Widget _buildDashboardHome() {
    return FutureBuilder<User?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Could not load user data.'));
        }

        final user = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, ${user.fullName}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text('Email: ${user.email}'),
              const SizedBox(height: 8),
              Text('Member since: ${user.creationDate.toLocal().toString().split(' ')[0]}'),
              const Spacer(),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (_selectedIndex == 0) // Show logout only on the main dashboard view
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts_outlined),
            label: 'Contacts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            label: 'Notes',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}