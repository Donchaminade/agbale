
import 'package:abgbale/screens/dashboard/tableau.dart';
import 'package:abgbale/services/api_service.dart';
import 'package:abgbale/widgets/auth_background_clipper.dart';
import 'package:abgbale/widgets/full_screen_loader.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  String? _errorMessage;
  bool _isLoading = false;

  void _verifyOtp(String pin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _apiService.verifyOtp(widget.email, pin);

    if (mounted) {
      if (result['success']) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const TableauScreen()),
          (route) => false, // Remove all previous routes
        );
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'] ?? 'Invalid code. Please try again.';
        });
      }
    }
  }

  void _resendCode() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _apiService.requestOtp(widget.email);
    
    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'A new code has been sent.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    final defaultPinTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: const TextStyle(fontSize: 22, color: Colors.black),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return FullScreenLoader(
      isLoading: _isLoading,
      child: Scaffold(
        body: Stack(
          children: [
            ClipPath(
              clipper: AuthBackgroundClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.4,
                color: primaryColor,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                height: 80,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Enter Verification Code',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 22),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'A 6-digit code has been sent to \n${widget.email}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 24),
                              Pinput(
                                length: 6,
                                controller: _pinController,
                                defaultPinTheme: defaultPinTheme,
                                focusedPinTheme: defaultPinTheme.copyWith(
                                  decoration: defaultPinTheme.decoration!.copyWith(
                                    border: Border.all(color: primaryColor),
                                  ),
                                ),
                                errorPinTheme: defaultPinTheme.copyWith(
                                  decoration: defaultPinTheme.decoration!.copyWith(
                                    border: Border.all(color: Colors.redAccent),
                                  ),
                                ),
                                onCompleted: (pin) => _verifyOtp(pin),
                                validator: (s) {
                                  if (s == null || s.length != 6) {
                                    return 'Please enter the 6-digit code';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              if (_errorMessage != null)
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                                ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _verifyOtp(_pinController.text);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: secondaryColor,
                                  foregroundColor: Colors.black,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text('Verify'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _resendCode,
                      child: Text(
                        'Resend Code',
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
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
}
