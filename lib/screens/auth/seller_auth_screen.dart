import 'package:flutter/material.dart';

import '../auth_screen.dart';

class SellerAuthScreen extends StatelessWidget {
  const SellerAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScreen(role: AuthRole.seller);
  }
}
