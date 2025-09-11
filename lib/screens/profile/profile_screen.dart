import 'package:flutter/material.dart';
import 'package:abgbale/models/user.dart';
import 'package:abgbale/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await _apiService.fetchUserData();
      setState(() {
        _user = user;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load user profile: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _user == null
                  ? const Center(child: Text('User data not available.'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Full Name: ${_user!.fullName}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Email: ${_user!.email}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Member Since: ${_user!.creationDate.toLocal().toString().split(' ')[0]}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          // Add more user details here as needed
                        ],
                      ),
                    ),
    );
  }
}
