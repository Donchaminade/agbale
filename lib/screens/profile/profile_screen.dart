import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:abgbale/models/user.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2196F3); // Define the new primary blue color

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile'),
      ),
      body: Stack(
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
          FutureBuilder<User?>(
            future: _apiService.fetchUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('Could not load profile.', style: TextStyle(color: Colors.white)));
              }

              final user = snapshot.data!;

              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    const SizedBox(height: 20),
                    _buildProfileHeader(user, primaryBlue),
                    const SizedBox(height: 30),
                    _buildInfoCard(user, primaryBlue),
                    const SizedBox(height: 20),
                    _buildActionsCard(primaryBlue),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User user, Color primaryBlue) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: primaryBlue,
          child: Text(
            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
            style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Text(user.fullName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(user.email, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
      ],
    );
  }

  Widget _buildInfoCard(User user, Color primaryBlue) {
    return _buildGlassmorphicContainer(
      child: Column(
        children: [
          _buildInfoRow(Icons.person_pin_circle_outlined, 'Full Name', user.fullName, primaryBlue),
          _buildInfoRow(Icons.email_outlined, 'Email Address', user.email, primaryBlue),
          _buildInfoRow(Icons.cake_outlined, 'Member Since', DateFormat.yMMMd().format(user.creationDate), primaryBlue),
        ],
      ),
    );
  }

  Widget _buildActionsCard(Color primaryBlue) {
    return _buildGlassmorphicContainer(
      child: Column(
        children: [
          _buildActionRow(Icons.edit_outlined, 'Edit Profile', () {}, primaryBlue),
          _buildActionRow(Icons.security_outlined, 'Change Password', () {}, primaryBlue),
          _buildActionRow(Icons.notifications_outlined, 'Notifications', () {}, primaryBlue),
        ],
      ),
    );
  }

  Widget _buildGlassmorphicContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: primaryBlue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String label, VoidCallback onTap, Color primaryBlue) {
    return ListTile(
      leading: Icon(icon, color: primaryBlue),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
      onTap: onTap,
    );
  }
}