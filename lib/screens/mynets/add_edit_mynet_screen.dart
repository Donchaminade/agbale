import 'dart:ui';
import 'package:abgbale/models/mynet.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:abgbale/utils/token_manager.dart';
import 'package:abgbale/widgets/full_screen_loader.dart';
import 'package:flutter/material.dart';

class AddEditMyNetScreen extends StatefulWidget {
  final MyNet? myNet;

  const AddEditMyNetScreen({super.key, this.myNet});

  @override
  State<AddEditMyNetScreen> createState() => _AddEditMyNetScreenState();
}

class _AddEditMyNetScreenState extends State<AddEditMyNetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late final TextEditingController _siteNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailOrNumberController;
  late final TextEditingController _passwordController;

  bool _isLoading = false;
  bool _isPasswordObscured = true;

  bool get _isEditing => widget.myNet != null;

  @override
  void initState() {
    super.initState();
    _siteNameController = TextEditingController(text: widget.myNet?.siteName ?? '');
    _usernameController = TextEditingController(text: widget.myNet?.username ?? '');
    _emailOrNumberController = TextEditingController(text: widget.myNet?.associatedEmailOrNumber ?? '');
    _passwordController = TextEditingController(text: widget.myNet?.password ?? '');
  }

  @override
  void dispose() {
    _siteNameController.dispose();
    _usernameController.dispose();
    _emailOrNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveMyNet() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) throw Exception('User not authenticated');

      final myNetData = MyNet(
        id: widget.myNet?.id ?? 0,
        userId: userId,
        siteName: _siteNameController.text,
        username: _usernameController.text,
        associatedEmailOrNumber: _emailOrNumberController.text.isNotEmpty ? _emailOrNumberController.text : null,
        password: _passwordController.text,
        creationDate: widget.myNet?.creationDate ?? DateTime.now(),
      );

      final success = _isEditing
          ? await _apiService.updateMyNet(myNetData)
          : (await _apiService.createMyNet(myNetData)) != null;

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('MyNet entry ${ _isEditing ? 'updated' : 'saved' } successfully!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true);
        } else {
          throw Exception('Failed to save MyNet entry.');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF2196F3); // Define the new primary blue color

    return FullScreenLoader(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(_isEditing ? 'Edit MyNet' : 'Add MyNet'),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/onboarding1.png'), // Choose a suitable background
                  fit: BoxFit.cover,
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
            SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.security_outlined, color: Colors.white.withOpacity(0.8), size: 60),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _siteNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(labelText: 'Site or App Name', icon: Icons.language),
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(labelText: 'Username', icon: Icons.person_outline),
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a username' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailOrNumberController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(labelText: 'Associated Email/Number (Optional)', icon: Icons.alternate_email),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isPasswordObscured,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        labelText: 'Password',
                        icon: Icons.lock_outline,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                        ),
                      ),
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a password' : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveMyNet,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(_isEditing ? 'Update Entry' : 'Save Entry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({required String labelText, required IconData icon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}