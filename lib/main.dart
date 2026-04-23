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

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // Firebase database service (non-ChangeNotifier)
        Provider(create: (_) => FirebaseDatabaseService()),

        // Auth
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Flask API client (proxied through auth token)
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

        // Legacy product provider (used by home_screen, product_detail, etc.)
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
