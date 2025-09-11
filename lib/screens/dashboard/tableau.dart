import 'package:abgbale/screens/notes/notes_todos_screen.dart';
import 'package:abgbale/screens/contacts/contacts_screen.dart';
import 'package:abgbale/models/user.dart';
import 'package:abgbale/screens/auth/login.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:abgbale/screens/profile/profile_screen.dart'; // Import for ProfileScreen
import 'package:abgbale/screens/profile/my_info_screen.dart'; // Import for MyInfoScreen

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

  void _navigateToProfile() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
  }

  void _navigateToMyInfo() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyInfoScreen()));
  }

  Widget _buildBody() {
    final List<Widget> widgetOptions = <Widget>[
      _buildDashboardHome(),
      const ContactsScreen(),
      const NotesTodosScreen(),
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
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250.0,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, ${user.fullName}!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                    ),
                    Text(
                      '${user.email}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
                background: Image.asset(
                  'assets/onboarding2.png',
                  fit: BoxFit.cover,
                  colorBlendMode: BlendMode.darken,
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Global Search - To be implemented')),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'profile') {
                      _navigateToProfile();
                    } else if (value == 'my_info') {
                      _navigateToMyInfo();
                    } else if (value == 'logout') {
                      _logout();
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'profile',
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Edit Profile'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'settings',
                      child: ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Account Settings'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'help',
                      child: ListTile(
                        leading: Icon(Icons.help_outline),
                        title: Text('Help & Support'),
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Déconnexion'),
                      ),
                    ),
                  ],
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    child: Text(
                      user.fullName.substring(0, 1).toUpperCase(),
                      style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildExpertStatCard(context, 'Total Contacts', '120', Icons.people_alt, Colors.blue),
                        _buildExpertStatCard(context, 'Active Notes', '50', Icons.note_alt, Colors.green),
                        _buildExpertStatCard(context, 'Social Engagements', '5', Icons.share, Colors.orange),
                        _buildExpertStatCard(context, 'Pending Tasks', '8', Icons.task, Colors.red),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickActionButton(context, 'Add Contact', Icons.person_add, () {
                          // Navigate to add contact or show dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Add Contact - To be implemented')),
                          );
                        }),
                        _buildQuickActionButton(context, 'New Note', Icons.note_add, () {
                          // Navigate to add note or show dialog
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('New Note - To be implemented')),
                          );
                        }),
                        _buildQuickActionButton(context, 'View All', Icons.list_alt, () {
                          // Navigate to a screen showing all items
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('View All - To be implemented')),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    _buildActivityItem(context, 'New contact added: John Doe', '2 hours ago', Icons.person_add),
                    _buildActivityItem(context, 'Note "Project Alpha" updated', 'yesterday', Icons.edit_note),
                    _buildActivityItem(context, 'Shared post on Facebook', '3 days ago', Icons.facebook),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpertStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String activity, String time, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity, style: Theme.of(context).textTheme.bodyLarge),
                  Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        FloatingActionButton(
          heroTag: title, // Unique tag for each button
          onPressed: onPressed,
          child: Icon(icon),
        ),
        const SizedBox(height: 8),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                _navigateToProfile();
              } else if (value == 'my_info') {
                _navigateToMyInfo();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profil'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'my_info',
                child: ListTile(
                  leading: Icon(Icons.info),
                  title: Text('Mes infos'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Déconnexion'),
                ),
              ),
            ],
            child: FutureBuilder<User?>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return const CircleAvatar(
                    child: Icon(Icons.person_outline),
                  );
                }
                final user = snapshot.data!;
                return CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  child: Text(
                    user.fullName.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
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