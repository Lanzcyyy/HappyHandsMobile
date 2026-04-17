import 'package:flutter/material.dart';

import '../auth_screen.dart';

class RiderAuthScreen extends StatelessWidget {
  const RiderAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScreen(role: AuthRole.rider);
  }
}
