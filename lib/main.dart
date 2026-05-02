import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'providers/auth_provider.dart';
import 'providers/role_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/products_provider.dart';
import 'providers/seller_provider.dart';
import 'providers/rider_provider.dart';
import 'services/flask_api_service.dart';
import 'services/firebase_database_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase is still used for Realtime Database (product data).
  // Authentication now goes through Flask/MySQL only.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // Firebase Realtime Database service (products/categories only)
        Provider(create: (_) => FirebaseDatabaseService()),

        // MySQL/Flask auth — no Firebase Auth
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Flask API client — uses JWT from AuthProvider
        ProxyProvider<AuthProvider, ApiClient>(
          update: (context, authProvider, previous) => ApiClient(
            tokenProvider: () async => authProvider.getIdToken(),
          ),
        ),

        // Flask API service
        ProxyProvider<ApiClient, FlaskApiService>(
          update: (context, apiClient, previous) => FlaskApiService(apiClient),
        ),

        // Products from Firebase Realtime Database
        ChangeNotifierProvider(
          create: (context) => ProductsProvider(
            context.read<FirebaseDatabaseService>(),
          )..fetch(),
        ),

        // Product provider used by home/detail screens (mock + API)
        ChangeNotifierProvider(create: (_) => ProductProvider()),

        ChangeNotifierProvider(create: (_) => CartProvider()),

        ChangeNotifierProvider(
          create: (context) =>
              SellerProvider(context.read<FlaskApiService>()),
        ),

        ChangeNotifierProvider(
          create: (context) =>
              RiderProvider(context.read<FlaskApiService>()),
        ),

        ChangeNotifierProvider(create: (_) => RoleProvider()),
      ],
      child: const App(),
    ),
  );
}
