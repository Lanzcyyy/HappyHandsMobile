import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/rider_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';

class RiderShell extends StatefulWidget {
  const RiderShell({super.key});

  @override
  State<RiderShell> createState() => _RiderShellState();
}

class _RiderShellState extends State<RiderShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      _RiderDashboardScreen(),
      _RiderOrdersScreen(),
      _RiderNotificationsScreen(),
      _RiderProfileScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), selectedIcon: Icon(Icons.local_shipping), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'Notifications'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _RiderDashboardScreen extends StatelessWidget {
  const _RiderDashboardScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Rider Dashboard'),
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: const Center(child: Text('Next: rider stats endpoints')),
      );
}

class _RiderOrdersScreen extends StatelessWidget {
  const _RiderOrdersScreen();
  @override
  Widget build(BuildContext context) {
    final rider = context.watch<RiderProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Orders'),
        actions: [
          IconButton(
            onPressed: rider.isLoading ? null : () => context.read<RiderProvider>().loadOrders(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (rider.isLoading) return const LoadingWidget(label: 'Loading orders...');
          if (rider.error != null) {
            return ErrorView(
              message:
                  '${rider.error}\n\nTip: Rider endpoints may require a rider session/login on the backend. We will add a mobile auth bridge next.',
              onRetry: () => context.read<RiderProvider>().loadOrders(),
            );
          }
          if (rider.orders.isEmpty) {
            return Center(
              child: FilledButton(
                onPressed: () => context.read<RiderProvider>().loadOrders(),
                child: const Text('Load orders'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: rider.orders.length,
            itemBuilder: (context, index) {
              final o = rider.orders[index];
              return Card(
                child: ListTile(
                  title: Text(o.orderNumber.isEmpty ? 'Order #${o.sellerOrderId}' : o.orderNumber),
                  subtitle: Text('Status: ${o.status.isEmpty ? 'pending' : o.status}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RiderNotificationsScreen extends StatelessWidget {
  const _RiderNotificationsScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: const Center(child: Text('Next: rider notifications')),
      );
}

class _RiderProfileScreen extends StatelessWidget {
  const _RiderProfileScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Rider Profile'),
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: const Center(child: Text('Next: rider profile/settings')),
      );
}

