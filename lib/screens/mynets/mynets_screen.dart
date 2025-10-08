import 'dart:ui';
import 'package:abgbale/models/mynet.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:abgbale/screens/mynets/add_edit_mynet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyNetsScreen extends StatefulWidget {
  const MyNetsScreen({super.key});

  @override
  State<MyNetsScreen> createState() => _MyNetsScreenState();
}

class _MyNetsScreenState extends State<MyNetsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<MyNet> _allMyNets = [];
  List<MyNet> _displayedMyNets = [];
  bool _isSearching = false;
  Future<void>? _fetchFuture;

  @override
  void initState() {
    super.initState();
    _fetchFuture = _fetchMyNets();
    _searchController.addListener(_filterMyNets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMyNets() async {
    try {
      final myNets = await _apiService.fetchMyNets();
      if (mounted) {
        setState(() {
          _allMyNets = myNets;
          _filterMyNets();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load MyNets: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _filterMyNets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _displayedMyNets = _allMyNets.where((mynet) {
        return mynet.siteName.toLowerCase().contains(query) ||
               mynet.username.toLowerCase().contains(query) ||
               (mynet.associatedEmailOrNumber?.toLowerCase().contains(query) ?? false);
      }).toList();
    });
  }

  Future<void> _navigateToAddEditScreen([MyNet? myNet]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => AddEditMyNetScreen(myNet: myNet)),
    );
    if (result == true && mounted) {
      setState(() => _fetchFuture = _fetchMyNets());
    }
  }

  Future<void> _deleteMyNet(int myNetId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete MyNet Entry'),
        content: const Text('Are you sure you want to permanently delete this entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final success = await _apiService.deleteMyNet(myNetId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entry deleted successfully!'), backgroundColor: Colors.green),
          );
          setState(() => _fetchFuture = _fetchMyNets());
        } else {
          throw Exception('Failed to delete entry.');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDetailsPopup(BuildContext context, MyNet myNet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900]?.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(myNet.siteName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
            IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.of(context).pop()),
          ],
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              _buildDetailRow(context, Icons.person_outline, 'Username', myNet.username),
              if (myNet.associatedEmailOrNumber != null && myNet.associatedEmailOrNumber!.isNotEmpty)
                _buildDetailRow(context, Icons.alternate_email, 'Email/Number', myNet.associatedEmailOrNumber!),
              const Divider(height: 24, color: Colors.white24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  TextButton.icon(
                    icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
                    label: const Text('Copy', style: TextStyle(color: Colors.white70)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: myNet.password));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password copied to clipboard!')));
                    },
                  ),
                ],
              ),
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
          : const Text('MyNets'),
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
            image: DecorationImage(image: AssetImage('assets/onboarding1.png'), fit: BoxFit.cover),
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
              if (snapshot.connectionState == ConnectionState.waiting && _allMyNets.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
              }
              if (_allMyNets.isEmpty) {
                return const Center(child: Text('No MyNet entries found. Add one!', style: TextStyle(color: Colors.white)));
              }
              if (_isSearching && _displayedMyNets.isEmpty) {
                return const Center(child: Text('No entries match your search.', style: TextStyle(color: Colors.white)));
              }
              return _buildMyNetsList();
            },
          ),
        ),
      ],
    );
  }

  ListView _buildMyNetsList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: _displayedMyNets.length,
      itemBuilder: (context, index) {
        final myNet = _displayedMyNets[index];
        final initial = myNet.siteName.isNotEmpty ? myNet.siteName[0].toUpperCase() : '?';
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
                  leading: CircleAvatar(backgroundColor:  Color.fromARGB(255, 1, 43, 160), child: Text(initial, style: const TextStyle(color: Colors.white))),
                  title: Text(myNet.siteName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text('Username: ${myNet.username}', style: const TextStyle(color: Colors.white70)),
                  onTap: () => _showDetailsPopup(context, myNet),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white70),
                    onSelected: (value) {
                      if (value == 'edit') _navigateToAddEditScreen(myNet);
                      if (value == 'delete') _deleteMyNet(myNet.id);
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