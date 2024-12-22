import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sobat_mobile/shop/models/shop_model.dart';
import 'package:sobat_mobile/shop/widgets/shop_card.dart';
import 'package:sobat_mobile/shop/screens/shop_form.dart';
import 'package:sobat_mobile/widgets/left_drawer.dart';
import 'package:http/http.dart' as http;

class ShopMainPage extends StatefulWidget {
  const ShopMainPage({super.key});

  @override
  State<ShopMainPage> createState() => _ShopMainPageState();
}

class _ShopMainPageState extends State<ShopMainPage> {
  Future<List<ShopEntry>> fetchShops(CookieRequest request) async {
    try {
      print("Fetching shops..."); // Debug print
      final response = await http.get(
        Uri.parse('https://m-arvin-sobat.pbp.cs.ui.ac.id/shop/show-json/'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print("Shop response status: ${response.statusCode}"); // Debug print
      print("Shop response body: ${response.body}"); // Debug print

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        return decoded.map((data) => ShopEntry.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load shops: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching shops: $e"); // Debug print
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    print("Building ShopMainPage"); // Debug print

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Our Shops',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.green[900]?.withOpacity(0.8),
        centerTitle: true,
      ),
      drawer: const LeftDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[50] ?? Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: FutureBuilder(
          future: fetchShops(request),
          builder: (context, AsyncSnapshot<List<ShopEntry>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.green[900],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[700],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No shops available.',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900]?.withOpacity(0.6),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  final shop = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ShopCard(shop: shop),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: (Colors.green[900] ?? Colors.green).withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            print("FAB pressed"); // Debug print
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ShopFormPage()),
            );
          },
          backgroundColor: Colors.green[900]?.withOpacity(0.8),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
