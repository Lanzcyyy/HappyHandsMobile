import 'package:flutter/material.dart';

import '../auth_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthScreen(role: AuthRole.user);
  }
}
          fontSize: 13,
          color: AppTheme.mediumGray.withValues(alpha: 0.6),
        ),
      ),
      validator: validator,
    );
  }
}
