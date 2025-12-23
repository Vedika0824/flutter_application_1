import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/bill_provider.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/product_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => BillProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const ProductScreen(),
      ),
    );
  }
}
