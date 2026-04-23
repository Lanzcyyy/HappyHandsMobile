import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../auth_screen.dart';

class SellerAuthScreen extends StatelessWidget {
  const SellerAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.white,
        appBar: CustomAppBar(
          title: 'Happy Hands',
          showBackButton: true,
          onBackTap: () => Navigator.pop(context),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMD,
                  vertical: AppConstants.spacingSM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _SellerAuthHeader(),
                    const SizedBox(height: AppConstants.spacingLG),
                    // Tab toggle
                    Container(
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
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        tabs: const [
                          Tab(child: SizedBox.expand(child: Center(child: Text('Login')))),
                          Tab(child: SizedBox.expand(child: Center(child: Text('Register')))),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMD),
                    const Expanded(child: _SellerTabForms()),
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

class _SellerAuthHeader extends StatelessWidget {
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
          child: const Icon(FontAwesomeIcons.store, color: AppTheme.white, size: 28),
        ),
        const SizedBox(height: AppConstants.spacingSM),
        Text(
          'Seller Portal',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Manage your shop and connect with customers',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.mediumGray,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SellerTabForms extends StatelessWidget {
  const _SellerTabForms();

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        // Login tab — reuse existing AuthForm login
        const AuthForm(role: AuthRole.seller),
        // Register tab — full seller registration
        const _SellerRegisterForm(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Seller Registration Form
// ─────────────────────────────────────────────────────────────────────────────
class _SellerRegisterForm extends StatefulWidget {
  const _SellerRegisterForm();

  @override
  State<_SellerRegisterForm> createState() => _SellerRegisterFormState();
}

class _SellerRegisterFormState extends State<_SellerRegisterForm> {
  final _formKey = GlobalKey<FormState>();

  // Personal info
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  // Store info
  final _storeNameCtrl = TextEditingController();
  final _storeDescCtrl = TextEditingController();

  // Address
  final _regionCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _barangayCtrl = TextEditingController();
  final _exactAddressCtrl = TextEditingController();

  // Password
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _error;
  String? _success;

  // Selected categories (using the same slugs as AppConstants)
  final Set<String> _selectedCategories = {};

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _emailCtrl, _contactCtrl, _storeNameCtrl, _storeDescCtrl,
      _regionCtrl, _provinceCtrl, _cityCtrl, _barangayCtrl, _exactAddressCtrl,
      _passwordCtrl, _confirmPasswordCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  InputDecoration _dec({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppTheme.white,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: Icon(icon, color: AppTheme.mediumGray, size: 18),
      prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: const BorderSide(color: AppTheme.borderGray),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: const BorderSide(color: AppTheme.primaryBlue),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        borderSide: const BorderSide(color: AppTheme.errorRed),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.darkBlue,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      setState(() => _error = 'Please select at least one product category.');
      return;
    }

    setState(() { _isLoading = true; _error = null; _success = null; });

    try {
      final uri = Uri.parse('${AppConfig.apiBaseUrl}/seller/register');
      final body = {
        'sellername': _nameCtrl.text.trim(),
        'selleremail': _emailCtrl.text.trim(),
        'contactnumber': _contactCtrl.text.trim(),
        'storename': _storeNameCtrl.text.trim(),
        'storedesc': _storeDescCtrl.text.trim(),
        'region': _regionCtrl.text.trim(),
        'province': _provinceCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'barangay': _barangayCtrl.text.trim(),
        'exact_address': _exactAddressCtrl.text.trim(),
        'password': _passwordCtrl.text,
        'confirmpassword': _confirmPasswordCtrl.text,
        'seller_category_ids': _selectedCategories.toList(),
      };

      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(AppConfig.requestTimeout);

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201 || json['status'] == 'success') {
        setState(() {
          _success = json['message']?.toString() ??
              'Registration submitted! We will review your application and contact you soon.';
        });
      } else {
        setState(() {
          _error = json['message']?.toString() ?? 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() => _error = 'Network error. Please check your connection.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success != null) {
      return _buildSuccessView();
    }

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Personal Information ──────────────────────────────────────
            _sectionTitle('Personal Information'),

            TextFormField(
              controller: _nameCtrl,
              decoration: _dec(label: 'Full Name', hint: 'Your full name', icon: FontAwesomeIcons.user),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _dec(label: 'Email Address', hint: 'seller@email.com', icon: FontAwesomeIcons.envelope),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(v.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _contactCtrl,
              keyboardType: TextInputType.phone,
              decoration: _dec(label: 'Contact Number', hint: '09XXXXXXXXX', icon: FontAwesomeIcons.phone),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),

            // ── Store Information ─────────────────────────────────────────
            _sectionTitle('Store Information'),

            TextFormField(
              controller: _storeNameCtrl,
              decoration: _dec(label: 'Store Name', hint: 'Your store name', icon: FontAwesomeIcons.store),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _storeDescCtrl,
              maxLines: 3,
              decoration: _dec(
                label: 'Store Description',
                hint: 'Describe what you sell...',
                icon: FontAwesomeIcons.fileLines,
              ).copyWith(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(FontAwesomeIcons.fileLines, color: AppTheme.mediumGray, size: 18),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Product Categories
            Text(
              'Product Categories',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.categories.map((cat) {
                final id = cat['id']!;
                final name = cat['name']!;
                final icon = cat['icon']!;
                final selected = _selectedCategories.contains(id);
                return FilterChip(
                  label: Text('$icon $name', style: TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedCategories.add(id);
                      } else {
                        _selectedCategories.remove(id);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.15),
                  checkmarkColor: AppTheme.primaryBlue,
                  labelStyle: TextStyle(
                    color: selected ? AppTheme.primaryBlue : AppTheme.mediumGray,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  side: BorderSide(
                    color: selected ? AppTheme.primaryBlue : AppTheme.borderGray,
                  ),
                );
              }).toList(),
            ),

            // ── Address ───────────────────────────────────────────────────
            _sectionTitle('Store Address'),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _regionCtrl,
                    decoration: _dec(label: 'Region', hint: 'e.g. Region III', icon: FontAwesomeIcons.map),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _provinceCtrl,
                    decoration: _dec(label: 'Province', hint: 'e.g. Bulacan', icon: FontAwesomeIcons.locationDot),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityCtrl,
                    decoration: _dec(label: 'City / Municipality', hint: 'City', icon: FontAwesomeIcons.city),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _barangayCtrl,
                    decoration: _dec(label: 'Barangay', hint: 'Barangay', icon: FontAwesomeIcons.houseFlag),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _exactAddressCtrl,
              maxLines: 2,
              decoration: _dec(
                label: 'Exact Address',
                hint: 'Unit/Bldg, Street, Subdivision...',
                icon: FontAwesomeIcons.house,
              ).copyWith(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Icon(FontAwesomeIcons.house, color: AppTheme.mediumGray, size: 18),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),

            // ── Password ──────────────────────────────────────────────────
            _sectionTitle('Account Password'),

            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscurePassword,
              decoration: _dec(
                label: 'Password',
                hint: 'Min. 6 characters',
                icon: FontAwesomeIcons.lock,
                suffix: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                    color: AppTheme.mediumGray,
                    size: 18,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 6) return 'At least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _confirmPasswordCtrl,
              obscureText: _obscureConfirm,
              decoration: _dec(
                label: 'Confirm Password',
                hint: 'Re-enter password',
                icon: FontAwesomeIcons.lock,
                suffix: IconButton(
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(
                    _obscureConfirm ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                    color: AppTheme.mediumGray,
                    size: 18,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v != _passwordCtrl.text) return 'Passwords do not match';
                return null;
              },
            ),

            // ── Error ─────────────────────────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.circleExclamation, color: AppTheme.errorRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppTheme.errorRed, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Submit ────────────────────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                        ),
                      )
                    : const Text(
                        'Submit Application',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Note about pending review
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(FontAwesomeIcons.circleInfo, color: AppTheme.mediumGray, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your application will be reviewed by our team. '
                      'You will be notified via email once approved.',
                      style: TextStyle(color: AppTheme.mediumGray, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.circleCheck,
                color: AppTheme.successGreen,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Application Submitted!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.darkBlue,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _success!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: AppTheme.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                  ),
                ),
                child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
