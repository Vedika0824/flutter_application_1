import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/api_conf.dart';
import 'package:flutter_application_1/screens/product_screen.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'bill_summary_screen.dart';

class BillScreen extends StatelessWidget {
  const BillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cart Items",
          style: TextStyle(
            color: Colors.white, // Set the color you want here
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 32, 56, 78),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // --------HERE ARE CART ITEMS LIST --------
          Expanded(
            child: cart.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "No items in cart. Go back and add products.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text("Go to Products"),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (_, index) {
                      final product = cart.keys.elementAt(index);
                      final qty = cart[product]!;
                      final lineTotal = product.price * qty;

                      return Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        elevation: 2,
                        child: ListTile(
                          title: Text(product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("₹${product.price.toStringAsFixed(2)} × $qty"),
                          trailing: SizedBox(
                            width: 120,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => cartProvider.remove(product),
                                ),
                                Text(qty.toString(),
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.green),
                                  onPressed: () => cartProvider.add(product),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // -------- TOTALS SECTION --------
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                _row("Subtotal", cartProvider.subtotal),
                const SizedBox(height: 6),
                _row("Tax (5%)", cartProvider.tax),
                const Divider(thickness: 1),
                _row("Grand Total", cartProvider.grandTotal, bold: true),
                const SizedBox(height: 16),

                // -------- GENERATE BILL BUTTON WITH CONFIRMATION --------
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.receipt_long),
                    label: const Text("Generate Bill"),
                    onPressed: cart.isEmpty
                        ? null
                        : () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Confirm"),
                                content: const Text(
                                    "Are you sure you want to generate this bill?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Confirm"),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed != true) return;

                            try { 
                              final api = context.read<ApiConfigProvider>();
                              final bill = await context.read<CartProvider>().checkout(api.baseUrl);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BillSummaryScreen(bill),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error generating bill: $e"),
                                ),
                              );
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
        Text(
          "₹${value.toStringAsFixed(2)}",
          style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }
}
