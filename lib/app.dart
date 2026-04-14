import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Happy Hands',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/auth': (context) => const AuthScreen(),
        '/product': (context) {
          final productId = ModalRoute.of(context)!.settings.arguments as int;
          return ProductDetailScreen(productId: productId);
        },
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes like product detail
        if (settings.name?.startsWith('/product/') == true) {
          final productId = int.tryParse(settings.name!.split('/')[2]) ?? 0;
          return MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: productId),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

