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

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await TokenManager.getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final myNetData = MyNet(
        id: widget.myNet?.id ?? 0,
        userId: userId,
        siteName: _siteNameController.text,
        username: _usernameController.text,
        associatedEmailOrNumber: _emailOrNumberController.text.isNotEmpty ? _emailOrNumberController.text : null,
        password: _passwordController.text,
        creationDate: widget.myNet?.creationDate ?? DateTime.now(),
      );

      final bool success;
      if (_isEditing) {
        success = await _apiService.updateMyNet(myNetData);
      } else {
        final newMyNet = await _apiService.createMyNet(myNetData);
        success = newMyNet != null;
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('MyNet entry ${ _isEditing ? 'updated' : 'saved' } successfully!'),
              backgroundColor: Colors.green,
            ),
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
    return FullScreenLoader(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit MyNet' : 'Add MyNet'),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 16),
              _buildTextField(
                controller: _siteNameController,
                labelText: 'Site or App Name',
                icon: Icons.language,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _usernameController,
                labelText: 'Username',
                icon: Icons.person_outline,
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a username' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailOrNumberController,
                labelText: 'Associated Email/Number (Optional)',
                icon: Icons.alternate_email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveMyNet,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_isEditing ? 'Update Entry' : 'Save Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _isPasswordObscured,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _isPasswordObscured = !_isPasswordObscured;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        return null;
      },
    );
  }
}