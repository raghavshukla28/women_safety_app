import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:women_safety_app/main.dart';

// Add RegisterPage class in the same file for now
class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add registration logic
                Navigator.pop(context);
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

// Rest of your existing _AuthPageState class remains exactly the same
class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool otpSent = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutQuart),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    mobileNumberController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void verifyOTP() {
    final otp = otpController.text.trim();

    if (otp.isEmpty || otp.length != 6) {
      _showErrorMessage("Please enter a valid 6-digit OTP.");
      return;
    }

    if (otp == "123456") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WomenSafetyApp()),
      );
    } else {
      _showErrorMessage("Invalid OTP!");
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onError),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildTopSection(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: otpSent ? _buildOTPForm() : _buildPhoneForm(),
                    ),
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24, 40, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            otpSent ? "Verify OTP" : "Welcome",
            style: GoogleFonts.poppins(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineLarge?.color,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            otpSent
                ? "Enter the code sent to your phone"
                : "Sign in to continue",
            style: GoogleFonts.poppins(
              fontSize: 17,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? prefix,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: GoogleFonts.poppins(
          fontSize: 17,
          color: Theme.of(context).textTheme.bodyLarge?.color,
          letterSpacing: -0.2,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
          prefixText: prefix,
          prefixStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 17,
          ),
          counterText: "",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildPhoneForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: mobileNumberController,
          label: "Phone number",
          keyboardType: TextInputType.phone,
          prefix: "+91",
        ),
        SizedBox(height: 24),
        _buildPrimaryButton(
          label: "Continue",
          onPressed: () {
            if (mobileNumberController.text.length == 10) {
              setState(() {
                otpSent = true;
              });
              _animationController.reset();
              _animationController.forward();
            } else {
              _showErrorMessage("Please enter a valid phone number");
            }
          },
        ),
        SizedBox(height: 16),
        _buildSecondaryButton(
          label: "New User? Create Account",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOTPForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTextField(
          controller: otpController,
          label: "Enter OTP",
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        SizedBox(height: 24),
        _buildPrimaryButton(
          label: "Verify",
          onPressed: verifyOTP,
        ),
        SizedBox(height: 16),
        _buildSecondaryButton(
          label: "Didn't receive code? Resend",
          onPressed: () {
            // Implement resend logic
          },
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        "By continuing, you agree to our Terms & Privacy Policy",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}