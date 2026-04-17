import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/money.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_widget.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final authToken = context.watch<AuthProvider>().backendAccessToken;

    void reloadCart() {
      context.read<CartProvider>().loadCart(authToken);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          IconButton(
            onPressed: cart.isLoading ? null : reloadCart,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (cart.isLoading) {
            return const LoadingWidget(label: 'Loading cart...');
          }
          if (cart.error != null) {
            return ErrorView(message: cart.error!, onRetry: reloadCart);
          }

          final items = cart.cartItems;
          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == items.length) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          formatMoney(cart.total),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final item = items[index];
              return Card(
                child: ListTile(
                  title: Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Qty: ${item.quantity} • ${formatMoney(item.unitPrice)}',
                  ),
                  trailing: Text(
                    formatMoney(item.totalPrice),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
