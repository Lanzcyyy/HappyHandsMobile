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
// After you run `flutterfire configure`, this file will be generated.
// It provides the correct Firebase settings for Android/iOS.
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Requires Firebase configuration (google-services.json / GoogleService-Info.plist).
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ProxyProvider<AuthProvider, ApiClient>(
          update: (context, authProvider, previous) {
            return ApiClient(
              tokenProvider: () async => authProvider.getIdToken(),
            );
          },
        ),
        ProxyProvider<ApiClient, FlaskApiService>(
          update: (context, apiClient, previous) => FlaskApiService(apiClient),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              ProductsProvider(context.read<FlaskApiService>()),
        ),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (context) => SellerProvider(context.read<FlaskApiService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => RiderProvider(context.read<FlaskApiService>()),
        ),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
      ],
      child: const App(),
    ),
  );
}
