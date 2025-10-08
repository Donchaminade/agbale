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
    _fetchFuture = _fetchMyNets(isInitial: true);
    _searchController.addListener(_filterMyNets);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMyNets({bool isInitial = false}) async {
    try {
      if (!isInitial) setState(() {}); // Show refresh indicator
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

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  Future<void> _navigateToAddEditScreen([MyNet? myNet]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => AddEditMyNetScreen(myNet: myNet),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        _fetchFuture = _fetchMyNets();
      });
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
          setState(() {
            _fetchFuture = _fetchMyNets();
          });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () => _fetchMyNets(),
        child: FutureBuilder<void>(
          future: _fetchFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _allMyNets.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (_allMyNets.isEmpty) {
              return const Center(child: Text('No MyNet entries found. Add one!'));
            }
            if (_isSearching && _displayedMyNets.isEmpty) {
              return const Center(child: Text('No entries match your search.'));
            }
            return _buildMyNetsList();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _stopSearch),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search...', border: InputBorder.none),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear()),
        ],
      );
    }
    return AppBar(
      title: const Text('MyNets'),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: _startSearch),
      ],
    );
  }

  ListView _buildMyNetsList() {
    return ListView.builder(
      itemCount: _displayedMyNets.length,
      itemBuilder: (context, index) {
        final myNet = _displayedMyNets[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(myNet.siteName.isNotEmpty ? myNet.siteName[0].toUpperCase() : '?'),
            ),
            title: Text(myNet.siteName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Username: ${myNet.username}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.copy), onPressed: () {
                  Clipboard.setData(ClipboardData(text: myNet.password));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password copied to clipboard!')));
                }),
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _navigateToAddEditScreen(myNet)),
                IconButton(icon: const Icon(Icons.delete), color: Colors.red.shade300, onPressed: () => _deleteMyNet(myNet.id)),
              ],
            ),
          ),
        );
      },
    );
  }
}