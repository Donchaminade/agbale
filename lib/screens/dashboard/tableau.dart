import 'dart:ui';
import 'package:abgbale/models/user.dart';
import 'package:abgbale/screens/contacts/add_edit_contact_screen.dart';
import 'package:abgbale/screens/contacts/contacts_screen.dart';
import 'package:abgbale/screens/mynets/mynets_screen.dart';
import 'package:abgbale/screens/navbar/bottomnavbar.dart';
import 'package:abgbale/screens/notes/add_edit_note_todo_screen.dart';
import 'package:abgbale/screens/notes/notes_todos_screen.dart';
import 'package:abgbale/screens/profile/my_info_screen.dart';
import 'package:abgbale/screens/profile/profile_screen.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:abgbale/screens/auth/login.dart'; // Import LoginScreen

class TableauScreen extends StatefulWidget {
  const TableauScreen({super.key});

  @override
  State<TableauScreen> createState() => _TableauScreenState();
}

class _TableauScreenState extends State<TableauScreen>
    with WidgetsBindingObserver {
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
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
  }

  void _navigateToMyInfo() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const MyInfoScreen()));
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
        const SnackBar(
          content: Text('Contact added successfully!'),
          backgroundColor: Colors.green,
        ),
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
        const SnackBar(
          content: Text('Note/Todo added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildBody() {
    final List<Widget> widgetOptions = <Widget>[
      _buildDashboardHome(),
      const ContactsScreen(),
      const NotesTodosScreen(),
      const MyNetsScreen(),
    ];
    return widgetOptions.elementAt(_selectedIndex);
  }

  Widget _buildDashboardHome() {
    const Color primaryBlue = Color(
      0xFF2196F3,
    ); // Define the new primary blue color

    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Could not load dashboard data.',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _loadData();
                  }),
                  child: const Text('Retry'),
                ),
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
                stretch: true,
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, ${user.fullName}!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        user.email,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/onboarding2.png', fit: BoxFit.cover),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                        child: Container(color: Colors.black.withOpacity(0.3)),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildExpertStatCard(
                          context,
                          'Total Contacts',
                          stats['totalContacts'].toString(),
                          Icons.people_alt,
                          primaryBlue,
                        ),
                        _buildExpertStatCard(
                          context,
                          'Active Notes',
                          stats['activeNotes'].toString(),
                          Icons.note_alt,
                          primaryBlue,
                        ),
                        _buildExpertStatCard(
                          context,
                          'Total MyNets',
                          stats['totalMynets'].toString(),
                          Icons.vpn_key,
                          primaryBlue,
                        ),
                        _buildExpertStatCard(
                          context,
                          'Pending Tasks',
                          stats['pendingTodos'].toString(),
                          Icons.task,
                          primaryBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildQuickActionButton(
                          context,
                          'Add Contact',
                          Icons.person_add,
                          _quickAddContact,
                          primaryBlue,
                        ),
                        _buildQuickActionButton(
                          context,
                          'New Note',
                          Icons.note_add,
                          _quickAddNote,
                          primaryBlue,
                        ),
                        _buildQuickActionButton(
                          context,
                          'View All',
                          Icons.list_alt,
                          () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('View All - To be implemented'),
                              ),
                            );
                          },
                          primaryBlue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildActivityItem(
                      context,
                      'New contact added: John Doe',
                      '2 hours ago',
                      Icons.person_add,
                    ),
                    _buildActivityItem(
                      context,
                      'Note "Project Alpha" updated',
                      'yesterday',
                      Icons.edit_note,
                    ),
                    _buildActivityItem(
                      context,
                      'Shared post on Facebook',
                      '3 days ago',
                      Icons.facebook,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlassmorphicContainer({
    required Widget child,
    double borderRadius = 16,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildExpertStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return _buildGlassmorphicContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 36, color: Colors.white.withOpacity(0.9)),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String activity,
    String time,
    IconData icon,
  ) {
    return _buildGlassmorphicContainer(
      borderRadius: 8,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                  Text(
                    time,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return _buildGlassmorphicContainer(
      borderRadius: 12,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(
      0xFF2196F3,
    ); // Define the new primary blue color

    return Scaffold(
      backgroundColor:
          Colors.black, // Dark background for better glassmorphism effect
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.1),
          radius: 20,
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
                  backgroundColor: Colors.white10,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white70,
                    ),
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
                      leading: Icon(Icons.person, color: Colors.black87),
                      title: Text(
                        'Profil',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'my_info',
                    child: ListTile(
                      leading: Icon(Icons.info, color: Colors.black87),
                      title: Text(
                        'Mes infos',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.black87),
                      title: Text(
                        'Déconnexion',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                ],
                child: CircleAvatar(
                  backgroundColor: primaryBlue,
                  child: Text(
                    user.fullName.isNotEmpty
                        ? user.fullName.substring(0, 1).toUpperCase()
                        : 'U',
                    style: const TextStyle(color: Colors.white),
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
