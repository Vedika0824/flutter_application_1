import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BillProvider extends ChangeNotifier {
  List<Map<String, dynamic>> bills = [];
  bool loading = false;
  Future<void> fetchBills() async {
    loading = true;
    notifyListeners();
    final res = await http.get(
      Uri.parse("http://192.168.5.24:3000/api/bills"),
    );
    if (res.statusCode == 200) {
      bills = List<Map<String, dynamic>>.from(json.decode(res.body));
    } else {
      throw Exception("Failed to load bills");
    }
    loading = false;
    notifyListeners();
  }
}
