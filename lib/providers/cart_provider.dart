import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<Product, int> cart = {};

  void add(Product product) {
    cart[product] = (cart[product] ?? 0) + 1;
    notifyListeners();
  }

  void remove(Product product) {
    if (!cart.containsKey(product)) return;

    if (cart[product]! > 1) {
      cart[product] = cart[product]! - 1;
    } else {
      cart.remove(product);
    }
    notifyListeners();
  }
  

  double get subtotal {
    double sum = 0;
    cart.forEach((product, qty) {
      sum += product.price * qty;
    });
    return sum;
  }

  double get tax => subtotal * 0.05;

  double get grandTotal => subtotal + tax;

  Future<Map<String, dynamic>> checkout(url) async {
    final items = cart.entries.map((e) {
      return {
        "productId": e.key.id,
        "name": e.key.name,
        "price": e.key.price,
        "quantity": e.value,
      };
    }).toList();

    final res = await http.post(
      Uri.parse("$url/bills"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"items": items}),
    );

    if (res.statusCode != 201) {
      throw Exception("Failed to generate bill");
    }

    cart.clear();
    notifyListeners();

    return json.decode(res.body);
  }
}
