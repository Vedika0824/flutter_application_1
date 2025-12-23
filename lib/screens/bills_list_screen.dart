import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/api_conf.dart';
import 'package:flutter_application_1/screens/product_screen.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';
import 'bill_summary_screen.dart';

class BillsListScreen extends StatefulWidget {
  const BillsListScreen({super.key});

  @override
  State<BillsListScreen> createState() => _BillsListScreenState();
}

class _BillsListScreenState extends State<BillsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final api = context.read<ApiConfigProvider>();
      context.read<BillProvider>().fetchBills(api.baseUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillProvider>();

    if (provider.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.bills.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No bills found")),
      );
    }

    // Sort bills by date descending
    final bills = [...provider.bills];
    bills.sort((a, b) =>
        DateTime.parse(b['createdAt']).compareTo(DateTime.parse(a['createdAt'])));

    // Group bills
    Map<String, List<Map<String, dynamic>>> groupedBills = {
      "Recent": [],
      "Last Week": [],
      "Older": [],
    };

    final now = DateTime.now();

    for (var bill in bills) {
      final date = DateTime.parse(bill['createdAt']);
      final difference = now.difference(date).inDays;

      if (difference == 0) {
        groupedBills["Recent"]!.add(bill);
      } else if (difference <= 7) {
        groupedBills["Last Week"]!.add(bill);
      } else {
        groupedBills["Older"]!.add(bill);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Bill History",
          style: TextStyle(
            color: Colors.white,
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
              MaterialPageRoute(builder: (_) => const ProductScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: ListView(
        children: groupedBills.entries
            .where((entry) => entry.value.isNotEmpty)
            .expand((entry) {
          final header = [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 32, 56, 78),
                ),
              ),
            )
          ];

          final items = entry.value.map((bill) {
            final DateTime date = DateTime.parse(bill['createdAt']);
            final double total = (bill['grandTotal'] as num).toDouble();

            return ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(
                "₹${total.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Items: ${bill['items'].length} • ${date.toLocal().toString().substring(0, 16)}",
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BillSummaryScreen(bill),
                  ),
                );
              },
            );
          }).toList();

          return [...header, ...items];
        }).toList(),
      ),
    );
  }
}
