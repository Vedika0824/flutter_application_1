import 'package:flutter/material.dart';
import 'product_screen.dart';
import 'bills_list_screen.dart';

class BillSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> bill;

  const BillSummaryScreen(this.bill, {super.key});

  @override
  Widget build(BuildContext context) {
    final List items = bill['items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bill Summary",
          style: TextStyle(
            color: Colors.white, // Set the color you want here
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 32, 56, 78),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const BillsListScreen()),
            (route) => false,
          );
        },
      ),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // -------- ITEMS LIST --------
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        "No items found",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final i = items[index];
                        final double price = (i['price'] as num).toDouble();
                        final int qty = i['quantity'];
                        final double total = (i['total'] as num).toDouble();

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            title: Text(
                              i['name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("₹${price.toStringAsFixed(2)} × $qty"),
                            trailing: Text(
                              "₹${total.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const Divider(thickness: 2),

            // -------- TOTALS SECTION --------
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _totalRow("Subtotal", bill['subtotal']),
                    _totalRow("Tax (5%)", bill['tax']),
                    _totalRow("Grand Total", bill['grandTotal'], bold: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // -------- NAVIGATION BUTTONS --------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text("Back to Home"),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductScreen()),
                      (route) => false,
                    );
                  },
                ),
                
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, dynamic value, {bool bold = false}) {
    final double amount = (value as num).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
