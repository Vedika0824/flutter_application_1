import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import 'bill_screen.dart';
import 'bills_list_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final searchCtrl = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    context.read<ProductProvider>().fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;
    final cartProvider = context.watch<CartProvider>();
    final cart = cartProvider.cart;

    // Filtered products based on search query
    final filteredProducts = products
        .where((p) =>
            p.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add & Manage Products",
          style: TextStyle(
            color: Colors.white, // Set the color you want here
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 32, 56, 78),
        iconTheme: const IconThemeData(color: Colors.white),
        
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                "Items: ${cart.length}",
                style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white,)
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchCtrl,
              decoration: const InputDecoration(
                labelText: "Search Product",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val;
                });
              },
            ),
          ),

          // ADD PRODUCT ROW
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: "Price"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final priceText = priceCtrl.text.trim();

                    if (name.isEmpty || priceText.isEmpty) {
                      _showMessage(context, "Please enter both name and price");
                      return;
                    }

                    final duplicate = products.any(
                        (p) => p.name.toLowerCase() == name.toLowerCase());
                    if (duplicate) {
                      _showMessage(context, "Product already exists");
                      return;
                    }

                    final price = double.tryParse(priceText);
                    if (price == null || price <= 0) {
                      _showMessage(context, "Enter a valid price");
                      return;
                    }

                    context.read<ProductProvider>().addProduct(name, price);
                    _showMessage(context, "$name added successfully");

                    nameCtrl.clear();
                    priceCtrl.clear();
                  },
                ),
              ],
            ),
          ),

          // PRODUCT LIST
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Text(
                      "No products found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (_, i) {
                      final product = filteredProducts[i];
                      final qty = cart[product] ?? 0;

                      return Card(
                        color: qty > 0 ? Colors.green.shade50 : null,
                        child: ListTile(
                          title: Text(product.name),
                          subtitle: Text("₹${product.price}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (qty > 0)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle,
                                      color: Colors.red),
                                  onPressed: () {
                                    context.read<CartProvider>().remove(product);
                                    // _showMessage(context,
                                    //     "${product.name} removed from cart");
                                  },
                                ),
                              if (qty > 0)
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.green,
                                  child: Text(
                                    qty.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              if (qty == 0)
                                IconButton(
                                  icon: const Icon(Icons.add_shopping_cart),
                                  onPressed: () {
                                    context.read<CartProvider>().add(product);
                                    // _showMessage(context,
                                    //     "${product.name} added to cart");
                                  },
                                ),
                            ],
                          ),
                          onTap: () {
                            context.read<CartProvider>().add(product);
                            _showMessage(context,
                                "${product.name} added to cart");
                          },
                        ),
                      );
                    },
                  ),
          ),

          // TWO BUTTONS IN BOX ABOVE BOTTOM
          Container(
            padding: const EdgeInsets.all(25),
            color: const Color.fromARGB(255, 32, 56, 78),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.list_alt),
                    label: const Text("View Bills"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const BillsListScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.receipt),
                    label: const Text("View Cart"),
                    onPressed: () {
                      if (cart.isEmpty) {
                        _showMessage(
                            context, "Cart is empty. Add products first.");
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BillScreen()),
                      );
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

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }
}
