import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/api_conf.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> products = [];

  /// FETCH PRODUCTS
  Future<void> fetchProducts(BuildContext context) async {
    try {
      final api = context.read<ApiConfigProvider>();
      final String url = "${api.baseUrl}/products";

      final res = await http.get(Uri.parse(url));

      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final decoded = json.decode(res.body);

        if (decoded is List) {
          products =
              decoded.map((e) => Product.fromJson(e)).toList();
        } else {
          products = [];
        }
      } else {
        products = [];
      }
    } catch (e) {
      products = [];
    }

    notifyListeners();
  }

  /// ADD PRODUCT
  Future<void> addProduct(
    BuildContext context,
    String name,
    double price,
  ) async {
    final api = context.read<ApiConfigProvider>();
    final String url = "${api.baseUrl}/products";

    await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "name": name,
        "price": price,
      }),
    );

    // refresh product list
    await fetchProducts(context);
  }
}
