import 'package:abgbale/screens/contacts/add_edit_contact_screen.dart';
import 'package:abgbale/models/contact.dart';
import 'package:abgbale/screens/notes/add_edit_note_todo_screen.dart';
import 'package:abgbale/models/note_todo.dart';
import 'package:abgbale/models/user.dart';
import 'package:abgbale/screens/auth/login.dart';
import 'package:abgbale/screens/contacts/add_edit_contact_screen.dart';
import 'package:abgbale/screens/contacts/contacts_screen.dart';
import 'package:abgbale/screens/navbar/bottomnavbar.dart';
import 'package:abgbale/screens/notes/notes_todos_screen.dart';
import 'package:abgbale/screens/profile/my_info_screen.dart';
import 'package:abgbale/screens/profile/profile_screen.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:flutter/material.dart';

class TableauScreen extends StatefulWidget {
  const TableauScreen({super.key});

  @override
  State<TableauScreen> createState() => _TableauScreenState();
}

class _TableauScreenState extends State<TableauScreen> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  Future<Map<String, dynamic>>? _dashboardFuture;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed, refreshing dashboard data...');
      _loadData();
    }
  }

  void _loadData() {
    print('Loading dashboard data...');
    setState(() {
      _dashboardFuture = _apiService.getDashboardData();
    });
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

  Future<void> _quickAddContact() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddEditContactScreen()),
    );

    if (result == true && mounted) {
      setState(() {
        _loadData(); // Refresh dashboard stats
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact added successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _quickAddNote() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const AddEditNoteTodoScreen()),
    );

    if (result == true && mounted) {
      setState(() {
        _loadData(); // Refresh dashboard stats
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note/Todo added successfully!'), backgroundColor: Colors.green),
      );
    }
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
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Could not load dashboard data.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _loadData();
                  }),
                  child: const Text('Retry'),
                )
              ],
            ),
          );
        }

        final user = snapshot.data!['user'] as User;
        final stats = snapshot.data!['stats'] as Map<String, int>;

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _loadData();
            });
          },
          child: CustomScrollView(
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
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
                  // Removed search icon and profile menu as per user request
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
                          _buildExpertStatCard(context, 'Total Contacts', stats['totalContacts'].toString(), Icons.people_alt, Colors.blue),
                          _buildExpertStatCard(context, 'Active Notes', stats['activeNotes'].toString(), Icons.note_alt, Colors.green),
                          _buildExpertStatCard(context, 'Social Engagements', '5', Icons.share, Colors.orange), // Still hardcoded
                          _buildExpertStatCard(context, 'Pending Tasks', stats['pendingTodos'].toString(), Icons.task, Colors.red),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      children: [
                        _buildQuickActionButton(context, 'Add Contact', Icons.person_add, _quickAddContact),
                        _buildQuickActionButton(context, 'New Note', Icons.note_add, _quickAddNote),
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
          ),
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
              const SizedBox(height: 8),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CircleAvatar(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Image.asset('assets/logo.png', height: 30),
          ),
        ),
        actions: [
          FutureBuilder<Map<String, dynamic>>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircleAvatar(
                  radius: 20,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final user = snapshot.data!['user'] as User;
              return PopupMenuButton<String>(
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
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName.substring(0, 1).toUpperCase() : 'U',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}