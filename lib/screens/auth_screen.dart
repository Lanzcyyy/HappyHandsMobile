import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../core/config/app_config.dart';

enum AuthRole { user, seller, rider }

extension AuthRoleX on AuthRole {
  String get displayName => switch (this) {
    AuthRole.user => 'User',
    AuthRole.seller => 'Seller',
    AuthRole.rider => 'Rider',
  };

  String get appBarTitle => switch (this) {
    AuthRole.user => 'Authentication',
    AuthRole.seller => 'Seller Authentication',
    AuthRole.rider => 'Rider Authentication',
  };

  String get headerSubtitle => switch (this) {
    AuthRole.user => 'Your trusted baby essentials store',
    AuthRole.seller => 'Manage your shop and connect with customers',
    AuthRole.rider => 'Start delivering and earn flexibly',
  };

  String get loginTitle => switch (this) {
    AuthRole.user => 'Welcome Back',
    AuthRole.seller => 'Seller Login',
    AuthRole.rider => 'Rider Login',
  };

  String get loginSubtitle => switch (this) {
    AuthRole.user => 'Sign in to continue',
    AuthRole.seller => 'Manage your shop',
    AuthRole.rider => 'Start delivering and earn',
  };

  String get registerTitle => switch (this) {
    AuthRole.user => 'Create account',
    AuthRole.seller => 'Seller Register',
    AuthRole.rider => 'Rider Register',
  };

  String get registerSubtitle => switch (this) {
    AuthRole.user => 'Join Happy Hands today',
    AuthRole.seller => 'Create your seller account',
    AuthRole.rider => 'Create your rider account',
  };
}

class AuthScreen extends StatelessWidget {
  final AuthRole role;

  const AuthScreen({super.key, this.role = AuthRole.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: CustomAppBar(
        title: 'Happy Hands',
        showBackButton: true,
        onBackTap: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        },
      ),
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMD,
                  vertical: AppConstants.spacingSM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthHeader(role: role),
                    const SizedBox(height: AppConstants.spacingLG),
                    const AuthToggle(),
                    const SizedBox(height: AppConstants.spacingMD),
                    Expanded(child: AuthForm(role: role)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  final AuthRole role;

  const AuthHeader({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppTheme.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            FontAwesomeIcons.baby,
            color: AppTheme.white,
            size: 30,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Text(
          'Happy Hands',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          role.headerSubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.mediumGray,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'API: ${AppConfig.apiBaseUrl}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.mediumGray.withValues(alpha: 0.6),
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class AuthToggle extends StatelessWidget {
  const AuthToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: TabBar(
        isScrollable: false,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        labelColor: AppTheme.white,
        unselectedLabelColor: AppTheme.mediumGray,
        labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(
            child: SizedBox.expand(child: Center(child: Text('Login'))),
          ),
          Tab(
            child: SizedBox.expand(child: Center(child: Text('Register'))),
          ),
        ],
      ),
    );
  }
}

class AuthForm extends StatefulWidget {
  final AuthRole role;

  const AuthForm({super.key, required this.role});

  @override
  State<AuthForm> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthForm> {
  // Login form controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _loginFormKey = GlobalKey<FormState>();

  // Register form controllers
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerFormKey = GlobalKey<FormState>();

  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _obscureConfirmPassword = true;

  InputDecoration _buildCompactDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      filled: true,
      fillColor: AppTheme.white,
      isDense: false,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      prefixIcon: Icon(prefixIcon, color: AppTheme.mediumGray, size: 18),
      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: const BorderSide(color: AppTheme.borderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: const BorderSide(color: AppTheme.primaryBlue),
      ),
    );
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(children: [_buildLoginForm(), _buildRegisterForm()]);
  }

  // ignore: unused_element
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            FontAwesomeIcons.baby,
            color: AppTheme.white,
            size: 30,
          ),
        ),

        const SizedBox(height: AppConstants.spacingSM),

        // Title
        Text(
          'Happy Hands',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w800,
            fontSize: 24,
          ),
        ),

        const SizedBox(height: 2),

        // Subtitle
        Text(
          'Your trusted baby essentials store',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.mediumGray,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildTabBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: TabBar(
        isScrollable: false,
        indicatorSize: TabBarIndicatorSize.tab,
        labelPadding: EdgeInsets.zero,
        indicatorPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
        labelColor: AppTheme.white,
        unselectedLabelColor: AppTheme.mediumGray,
        labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(
            child: SizedBox.expand(child: Center(child: Text('Login'))),
          ),
          Tab(
            child: SizedBox.expand(child: Center(child: Text('Register'))),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            top: AppConstants.spacingSM,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _loginFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.role != AuthRole.user) ...[
                      Text(
                        widget.role.loginTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.darkBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.role.loginSubtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.mediumGray,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingMD),
                    ],

                    // Email Field
                    TextFormField(
                      controller: _loginEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildCompactDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter your email',
                        prefixIcon: FontAwesomeIcons.envelope,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingMD),

                    // Password Field
                    TextFormField(
                      controller: _loginPasswordController,
                      obscureText: _obscureLoginPassword,
                      decoration: _buildCompactDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: FontAwesomeIcons.lock,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureLoginPassword = !_obscureLoginPassword;
                            });
                          },
                          icon: Icon(
                            _obscureLoginPassword
                                ? FontAwesomeIcons.eye
                                : FontAwesomeIcons.eyeSlash,
                            color: AppTheme.mediumGray,
                            size: 18,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingSM),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: _showForgotPasswordDialog,
                        child: Text(
                          'Forgot Password?',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingLG),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: AppTheme.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(52),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          tapTargetSize: MaterialTapTargetSize.padded,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusLG,
                            ),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    // Error Message
                    if (authProvider.error != null) ...[
                      const SizedBox(height: AppConstants.spacingSM),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppConstants.spacingSM),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMD,
                          ),
                          border: Border.all(
                            color: AppTheme.errorRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.circleExclamation,
                              color: AppTheme.errorRed,
                              size: 16,
                            ),
                            const SizedBox(width: AppConstants.spacingSM),
                            Expanded(
                              child: Text(
                                authProvider.error!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.errorRed),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterForm() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            top: AppConstants.spacingSM,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _registerFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.role != AuthRole.user) ...[
                      Text(
                        widget.role.registerTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.darkBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.role.registerSubtitle,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.mediumGray,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingMD),
                    ],

                    // Name Field
                    TextFormField(
                      controller: _registerNameController,
                      decoration: _buildCompactDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: FontAwesomeIcons.user,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (value.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingMD),

                    // Email Field
                    TextFormField(
                      controller: _registerEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildCompactDecoration(
                        labelText: 'Email Address',
                        hintText: 'Enter your email',
                        prefixIcon: FontAwesomeIcons.envelope,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingMD),

                    // Password Field
                    TextFormField(
                      controller: _registerPasswordController,
                      obscureText: _obscureRegisterPassword,
                      decoration: _buildCompactDecoration(
                        labelText: 'Password',
                        hintText: 'Create a password',
                        prefixIcon: FontAwesomeIcons.lock,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureRegisterPassword =
                                  !_obscureRegisterPassword;
                            });
                          },
                          icon: Icon(
                            _obscureRegisterPassword
                                ? FontAwesomeIcons.eye
                                : FontAwesomeIcons.eyeSlash,
                            color: AppTheme.mediumGray,
                            size: 18,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingMD),

                    // Confirm Password Field
                    TextFormField(
                      controller: _registerConfirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: _buildCompactDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm your password',
                        prefixIcon: FontAwesomeIcons.lock,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? FontAwesomeIcons.eye
                                : FontAwesomeIcons.eyeSlash,
                            color: AppTheme.mediumGray,
                            size: 18,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _registerPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: AppConstants.spacingLG),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: AppTheme.white,
                          elevation: 0,
                          minimumSize: const Size.fromHeight(52),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          tapTargetSize: MaterialTapTargetSize.padded,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusLG,
                            ),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    // Error Message
                    if (authProvider.error != null) ...[
                      const SizedBox(height: AppConstants.spacingSM),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppConstants.spacingSM),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMD,
                          ),
                          border: Border.all(
                            color: AppTheme.errorRed.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.circleExclamation,
                              color: AppTheme.errorRed,
                              size: 16,
                            ),
                            const SizedBox(width: AppConstants.spacingSM),
                            Expanded(
                              child: Text(
                                authProvider.error!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.errorRed),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.login(
      email: _loginEmailController.text.trim(),
      password: _loginPasswordController.text,
      role: widget.role.name,
    );

    if (authProvider.error == null) {
      if (!mounted) return;
      handleLoginSuccess(authProvider.activeRole ?? widget.role.name);
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.register(
      email: _registerEmailController.text.trim(),
      password: _registerPasswordController.text,
      displayName: _registerNameController.text.trim(),
      role: widget.role.name,
    );

    if (authProvider.error == null) {
      if (!mounted) return;
      handleLoginSuccess(authProvider.activeRole ?? widget.role.name);
    }
  }

  void handleLoginSuccess(String role) {
    final routeName = switch (role) {
      'seller' => '/seller-dashboard',
      'rider' => '/rider-dashboard',
      _ => '/user-dashboard',
    };

    Navigator.of(context).pushReplacementNamed(routeName);
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: const Text(
          'Password reset is not available in the mobile app.\n\n'
          'Please visit the Happy Hands website to reset your password.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
