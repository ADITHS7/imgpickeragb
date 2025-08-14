import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imgpickapp/login/service/storage_service.dart';
import 'package:imgpickapp/login/vm/login_vm.dart';
import 'package:imgpickapp/views/user_managment_screen.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  bool _isCheckingLoginStatus = true;
  bool _isPasswordVisible = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkLoginStatus();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await _storageService.isLoggedIn();
      if (isLoggedIn && mounted) {
        final user = await _storageService.getUser();
        if (user != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => UserManagementScreen()),
          );
          return;
        }
      }
    } catch (e) {
      // Silent error handling
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingLoginStatus = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingLoginStatus) {
      return Scaffold(
        body: Container(
          decoration: _buildGradientBackground(),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                SizedBox(height: 20),
                Text(
                  'Loading...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: _buildGradientBackground(),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 50),
                  _buildLoginCard(),
                  const SizedBox(height: 30),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFF6B73FF)],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Animated Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF8F9FA)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.account_circle_outlined,
                size: 60,
                color: Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 30),

            // Welcome Text
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Sign in to continue',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Consumer<LoginViewModel>(
          builder: (context, viewModel, child) {
            return Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Username Field (changed from phone)
                  _buildUsernameField(viewModel),
                  const SizedBox(height: 24),

                  // Password Field
                  _buildPasswordField(viewModel),
                  const SizedBox(height: 16),

                  // Error Message
                  if (viewModel.state == LoginState.error)
                    _buildErrorMessage(viewModel),

                  // Success Message
                  if (viewModel.state == LoginState.success)
                    _buildSuccessMessage(),

                  const SizedBox(height: 32),

                  // Login Button
                  _buildLoginButton(viewModel),

                  const SizedBox(height: 20),

                  // Forgot Password
                  _buildForgotPassword(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUsernameField(LoginViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Username',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: viewModel.usernameController,
          keyboardType: TextInputType.text,
          validator: viewModel.validateUsername,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Enter your username',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF667eea),
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(LoginViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: viewModel.passwordController,
          obscureText: !_isPasswordVisible,
          validator: viewModel.validatePassword,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_outline,
                color: Color(0xFF667eea),
                size: 20,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF667eea),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF7FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(LoginViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getUserFriendlyErrorMessage(viewModel.errorMessage),
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Login successful! Redirecting...',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(LoginViewModel viewModel) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed:
            viewModel.isLoading ? null : () => _handleLogin(context, viewModel),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            viewModel.isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () => _showForgotPasswordDialog(),
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          color: const Color(0xFF667eea),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Text(
            'Secure Login',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Your data is protected',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUserFriendlyErrorMessage(String errorMessage) {
    final lowerError = errorMessage.toLowerCase();

    if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Please check your internet connection and try again.';
    } else if (lowerError.contains('timeout')) {
      return 'Connection timeout. Please try again.';
    } else if (lowerError.contains('invalid') || lowerError.contains('wrong')) {
      return 'Invalid username or password. Please check and try again.';
    } else if (lowerError.contains('server') || lowerError.contains('500')) {
      return 'Service temporarily unavailable. Please try again later.';
    } else if (lowerError.contains('unauthorized') ||
        lowerError.contains('401')) {
      return 'Invalid credentials. Please check your username and password.';
    } else if (lowerError.contains('not found') || lowerError.contains('404')) {
      return 'Account not found. Please contact support.';
    } else {
      return 'Login failed. Please try again or contact support if the problem persists.';
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Forgot Password',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Please contact your administrator to reset your password.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: const Color(0xFF667eea),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _handleLogin(
    BuildContext context,
    LoginViewModel viewModel,
  ) async {
    try {
      await viewModel.login();

      if (viewModel.state == LoginState.success) {
        if (viewModel.loginResponse?.data != null) {
          await _storageService.saveUser(viewModel.loginResponse!.data!);
        }

        await Future.delayed(const Duration(seconds: 1));

        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      UserManagementScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
