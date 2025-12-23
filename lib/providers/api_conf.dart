import 'package:flutter/material.dart';

class ApiConfigProvider extends ChangeNotifier {
  String _baseIp = "192.168.5.24";

  String get baseUrl => "http://$_baseIp:3000/api";
  String get ip => _baseIp;

  void updateIp(String newIp) {
    _baseIp = newIp;
    notifyListeners();
  }
}