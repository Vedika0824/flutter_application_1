import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final String baseUrl = "http://192.168.5.24:3000/api/products";
  List<Product> products = [];

  Future<void> fetchProducts() async {
  try {
    final res = await http.get(Uri.parse(baseUrl));

    // If backend is reachable but no products exist
    if (res.statusCode == 200 && res.body.isNotEmpty) {
      final decoded = json.decode(res.body);

      if (decoded is List) {
        products = decoded
            .map((e) => Product.fromJson(e))
            .toList();
      } else {
        products = [];
      }
    } else {
      products = [];
    }
  } catch (e) {
    // Network error, invalid JSON, etc.
    products = [];
  }

  notifyListeners();
}


  Future<void> addProduct(String name, double price) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"name": name, "price": price}),
    );
    await fetchProducts();
  }
}
