import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/money.dart';
import '../../providers/seller_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';

class SellerShell extends StatefulWidget {
  const SellerShell({super.key});

  @override
  State<SellerShell> createState() => _SellerShellState();
}

class _SellerShellState extends State<SellerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      _SellerDashboardScreen(),
      _SellerOrdersScreen(),
      _SellerProductsScreen(),
      _SellerChatScreen(),
      _SellerProfileScreen(),
    ];

    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), selectedIcon: Icon(Icons.inventory_2), label: 'Products'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _SellerDashboardScreen extends StatelessWidget {
  const _SellerDashboardScreen();
  @override
  Widget build(BuildContext context) {
    final seller = context.watch<SellerProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        actions: [
          IconButton(
            onPressed: seller.isLoading ? null : () => context.read<SellerProvider>().loadDashboard(),
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Builder(
        builder: (_) {
          if (seller.isLoading) {
            return const LoadingWidget(label: 'Loading seller dashboard...');
          }
          if (seller.error != null) {
            return ErrorView(
              message:
                  '${seller.error}\n\nTip: Seller endpoints may require a seller session/login on the backend. We will add a mobile auth bridge next.',
              onRetry: () => context.read<SellerProvider>().loadDashboard(),
            );
          }

          if (seller.sales.isEmpty && seller.recentOrders.isEmpty) {
            return Center(
              child: FilledButton(
                onPressed: () => context.read<SellerProvider>().loadDashboard(),
                child: const Text('Load dashboard'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Recent orders', style: TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${seller.recentOrders.length} orders'),
                ),
              ),
              const SizedBox(height: 10),
              ...seller.recentOrders.take(8).map((o) {
                return Card(
                  child: ListTile(
                    title: Text(o.orderNumber.isEmpty ? 'Order #${o.sellerOrderId}' : o.orderNumber),
                    subtitle: Text('Status: ${o.status.isEmpty ? 'pending' : o.status}'),
                    trailing: Text(formatMoney(o.totalAmount), style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _SellerOrdersScreen extends StatelessWidget {
  const _SellerOrdersScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Seller Orders')),
        body: const Center(child: Text('Next: seller orders + status updates')),
      );
}

class _SellerProductsScreen extends StatelessWidget {
  const _SellerProductsScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Seller Products')),
        body: const Center(child: Text('Next: product management')),
      );
}

class _SellerChatScreen extends StatelessWidget {
  const _SellerChatScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Seller Chat')),
        body: const Center(child: Text('Next: seller chat conversations')),
      );
}

class _SellerProfileScreen extends StatelessWidget {
  const _SellerProfileScreen();
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Seller Profile')),
        body: const Center(child: Text('Next: seller profile/settings')),
      );
}

