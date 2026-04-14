import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Shipping Information
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  
  // Payment Information
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  
  String _selectedPaymentMethod = 'cod'; // cod, card
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _prefillUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: CustomAppBar(
        title: 'Checkout',
        onCartTap: () => Navigator.pop(context),
        onProfileTap: () => _navigateToProfile(),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isEmpty) {
            return _buildEmptyCart();
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  _buildOrderSummary(cartProvider),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Shipping Information
                  _buildShippingInformation(),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Payment Method
                  _buildPaymentMethod(),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Payment Details (if card selected)
                  if (_selectedPaymentMethod == 'card')
                    _buildPaymentDetails(),
                  
                  const SizedBox(height: AppConstants.spacingXL),
                  
                  // Place Order Button
                  _buildPlaceOrderButton(cartProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: AppTheme.borderGray.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.darkBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: AppConstants.spacingMD),
          
          // Cart Items Summary
          ...cartProvider.cartItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.spacingSM),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.darkBlue,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Qty: ${item.quantity}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₱${item.subtotal.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          
          const Divider(height: AppConstants.spacingLG),
          
          // Totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.mediumGray,
                ),
              ),
              Text(
                '₱${cartProvider.subtotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingSM),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.mediumGray,
                ),
              ),
              Text(
                '₱${cartProvider.shippingCost.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const Divider(height: AppConstants.spacingLG),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.darkBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '₱${cartProvider.total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        
        const SizedBox(height: AppConstants.spacingMD),
        
        // Name
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: const Icon(
              FontAwesomeIcons.user,
              color: AppTheme.mediumGray,
            ),
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
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppConstants.spacingMD),
        
        // Phone
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            prefixIcon: const Icon(
              FontAwesomeIcons.phone,
              color: AppTheme.mediumGray,
            ),
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
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppConstants.spacingMD),
        
        // Address
        TextFormField(
          controller: _addressController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Address',
            hintText: 'Enter your complete address',
            prefixIcon: const Icon(
              FontAwesomeIcons.home,
              color: AppTheme.mediumGray,
            ),
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
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your address';
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppConstants.spacingMD),
        
        Row(
          children: [
            // City
            Expanded(
              child: TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  hintText: 'City',
                  prefixIcon: const Icon(
                    FontAwesomeIcons.city,
                    color: AppTheme.mediumGray,
                  ),
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(width: AppConstants.spacingMD),
            
            // Province
            Expanded(
              child: TextFormField(
                controller: _provinceController,
                decoration: InputDecoration(
                  labelText: 'Province',
                  hintText: 'Province',
                  prefixIcon: const Icon(
                    FontAwesomeIcons.map,
                    color: AppTheme.mediumGray,
                  ),
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your province';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.spacingMD),
        
        // Postal Code
        TextFormField(
          controller: _postalCodeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Postal Code',
            hintText: 'Enter postal code',
            prefixIcon: const Icon(
              FontAwesomeIcons.envelope,
              color: AppTheme.mediumGray,
            ),
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
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your postal code';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        
        const SizedBox(height: AppConstants.spacingMD),
        
        // Cash on Delivery
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = 'cod';
            });
          },
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            decoration: BoxDecoration(
              color: _selectedPaymentMethod == 'cod'
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : AppTheme.white,
              border: Border.all(
                color: _selectedPaymentMethod == 'cod'
                    ? AppTheme.primaryBlue
                    : AppTheme.borderGray,
                width: _selectedPaymentMethod == 'cod' ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.moneyBillWave,
                  color: _selectedPaymentMethod == 'cod'
                      ? AppTheme.primaryBlue
                      : AppTheme.mediumGray,
                ),
                const SizedBox(width: AppConstants.spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cash on Delivery',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _selectedPaymentMethod == 'cod'
                              ? AppTheme.primaryBlue
                              : AppTheme.darkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Pay when you receive your order',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: 'cod',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                  activeColor: AppTheme.primaryBlue,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppConstants.spacingMD),
        
        // Credit/Debit Card
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = 'card';
            });
          },
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingMD),
            decoration: BoxDecoration(
              color: _selectedPaymentMethod == 'card'
                  ? AppTheme.primaryBlue.withOpacity(0.1)
                  : AppTheme.white,
              border: Border.all(
                color: _selectedPaymentMethod == 'card'
                    ? AppTheme.primaryBlue
                    : AppTheme.borderGray,
                width: _selectedPaymentMethod == 'card' ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
            child: Row(
              children: [
                Icon(
                  FontAwesomeIcons.creditCard,
                  color: _selectedPaymentMethod == 'card'
                      ? AppTheme.primaryBlue
                      : AppTheme.mediumGray,
                ),
                const SizedBox(width: AppConstants.spacingMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Credit/Debit Card',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: _selectedPaymentMethod == 'card'
                              ? AppTheme.primaryBlue
                              : AppTheme.darkBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Pay securely with your card',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Radio<String>(
                  value: 'card',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentMethod = value!;
                    });
                  },
                  activeColor: AppTheme.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        
        const SizedBox(height: AppConstants.spacingMD),
        
        // Card Number
        TextFormField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            prefixIcon: const Icon(
              FontAwesomeIcons.creditCard,
              color: AppTheme.mediumGray,
            ),
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
          ),
          validator: (value) {
            if (_selectedPaymentMethod == 'card') {
              if (value == null || value.isEmpty) {
                return 'Please enter your card number';
              }
              if (value.length < 16) {
                return 'Please enter a valid card number';
              }
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppConstants.spacingMD),
        
        // Card Name
        TextFormField(
          controller: _cardNameController,
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            hintText: 'Name on card',
            prefixIcon: const Icon(
              FontAwesomeIcons.user,
              color: AppTheme.mediumGray,
            ),
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
          ),
          validator: (value) {
            if (_selectedPaymentMethod == 'card') {
              if (value == null || value.isEmpty) {
                return 'Please enter the cardholder name';
              }
            }
            return null;
          },
        ),
        
        const SizedBox(height: AppConstants.spacingMD),
        
        Row(
          children: [
            // Expiry Date
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  prefixIcon: const Icon(
                    FontAwesomeIcons.calendar,
                    color: AppTheme.mediumGray,
                  ),
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
                ),
                validator: (value) {
                  if (_selectedPaymentMethod == 'card') {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(width: AppConstants.spacingMD),
            
            // CVV
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  prefixIcon: const Icon(
                    FontAwesomeIcons.lock,
                    color: AppTheme.mediumGray,
                  ),
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
                ),
                validator: (value) {
                  if (_selectedPaymentMethod == 'card') {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    if (value.length < 3) {
                      return 'Invalid CVV';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceOrderButton(CartProvider cartProvider) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _placeOrder(cartProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: AppTheme.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          ),
        ),
        child: _isProcessing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                ),
              )
            : Text(
                'Place Order - ₱${cartProvider.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.shoppingCart,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.darkBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'Add some products to your cart to proceed with checkout.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXL),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingXL,
                  vertical: AppConstants.spacingMD,
                ),
              ),
              child: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  void _prefillUserInfo() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user != null) {
      _nameController.text = authProvider.user!.displayName ?? '';
    }
  }

  Future<void> _placeOrder(CartProvider cartProvider) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simulate order processing
      await Future.delayed(const Duration(seconds: 3));

      // Clear cart after successful order
      final authProvider = context.read<AuthProvider>();
      await cartProvider.clearCart(authProvider.backendAccessToken);

      // Show success message
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  FontAwesomeIcons.checkCircle,
                  color: AppTheme.successGreen,
                  size: 24,
                ),
                const SizedBox(width: AppConstants.spacingSM),
                const Text('Order Placed!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thank you for your order!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSM),
                Text(
                  'Order ID: #${DateTime.now().millisecondsSinceEpoch}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingSM),
                Text(
                  'You will receive a confirmation email shortly.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
                child: const Text('Continue Shopping'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _navigateToProfile() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) {
      Navigator.pushNamed(context, '/auth');
    } else {
      // Navigate to profile screen (to be implemented)
    }
  }
}
