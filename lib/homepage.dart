import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:sobat_mobile/authentication/login.dart';
import 'package:sobat_mobile/colors.dart';
import 'package:sobat_mobile/drug/models/drug_entry.dart';
import 'package:sobat_mobile/drug/screens/drug_detail.dart';
import 'package:sobat_mobile/drug/screens/list_drugentry.dart';
import 'package:sobat_mobile/shop/models/shop_model.dart';
import 'package:sobat_mobile/shop/screens/shop_detail_page.dart';
import 'package:sobat_mobile/shop/screens/shop_main_page.dart';
import 'package:sobat_mobile/widgets/left_drawer.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String baseUrl = 'https://m-arvin-sobat.pbp.cs.ui.ac.id/media/';

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      bottomNavigationBar: _buildBottomNavBar(context),
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        title: Row(
          children: [
            const Text(
              "Sobat",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Image.asset(
              'assets/icon-no-bg.png',
              fit: BoxFit.contain,
              height: 40,
            ),
          ],
        ),
      ),
      drawer: LeftDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[700]!, Colors.green[500]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, ${request.jsonData["username"]}!",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Welcome to Sobat: Solo Obat!\nDiscover the finest medicines and herbal remedies to enhance your health and well-being.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/icon-no-bg.png',
                          fit: BoxFit.contain,
                          height: 90,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Popular Drugs"),
                  _buildGrid(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Shops"),
                  _buildHorizontalShopList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<DrugModel>> fetchProductEntries(CookieRequest request) async {
    final response = await request.get('https://m-arvin-sobat.pbp.cs.ui.ac.id/product/json/');
    var data = response;

    List<DrugModel> listProduct = [];
    for (var d in data) {
      if (d != null) {
        try {
          final entry = DrugModel.fromJson(d);

          listProduct.add(entry);
        } catch (e) {
          // Handle any error during data parsing
          print('Error parsing product data: $e');
        }
      }
    }
    return listProduct;
  }

  Future<List<ShopEntry>> fetchShops(CookieRequest request) async {
    try {
      final response = await http.get(
        Uri.parse('https://m-arvin-sobat.pbp.cs.ui.ac.id/shop/show-json/'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> decoded = json.decode(response.body);
        return decoded.map((data) => ShopEntry.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load shops: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(1),
        margin: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12.0,
              spreadRadius: 2.0,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 4),
          child: GNav(
            tabBackgroundColor: Colors.green.shade900,
            tabBorderRadius: 30,
            iconSize: 20,
            gap: 5,
            tabs: [
              GButton(
                iconActiveColor: Colors.white,
                iconColor: Colors.black,
                icon: FontAwesomeIcons.house,
                onPressed: () {},
              ),
              GButton(
                iconActiveColor: Colors.white,
                iconColor: Colors.black,
                icon: FontAwesomeIcons.prescriptionBottleMedical,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DrugEntryPage()),
                  );
                },
              ),
              GButton(
                iconActiveColor: Colors.white,
                iconColor: Colors.black,
                icon: FontAwesomeIcons.shop,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ShopMainPage()),
                  );
                },
              ),
              GButton(
                icon: FontAwesomeIcons.rightFromBracket,
                iconActiveColor: Colors.white,
                iconColor: Colors.black,
                onPressed: () async {
                  final response = await request
                      .logout("https://m-arvin-sobat.pbp.cs.ui.ac.id/logout_mobile/");
                  if (context.mounted && response['status']) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 0.0, 4.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return FutureBuilder(
        future: fetchProductEntries(request),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return const Text(
              'There are no questions yet...',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            );
          } else {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8, // Adjusted for smaller cards
              ),
              itemCount: 8,
              itemBuilder: (_, index) {
                final product = snapshot.data![index];
                final imageUrl = '$baseUrl${product.fields.image}';

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          product: product,
                          detailRoute: () => addToFavorite(product.pk, request), onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image container
                          Expanded(
                            flex: 3,
                            child: Container(
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 32,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Product details container
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      product.fields.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize:
                                            14, // Smaller font for smaller cards
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Rp${product.fields.price}",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13, // Adjusted font size
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        });
  }

  Widget _buildHorizontalShopList() {
    final request = context.watch<CookieRequest>();
    
    return FutureBuilder(
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
        }

        return SizedBox(
          height: 320, // Fixed height for the horizontal list
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final shop = snapshot.data![index];
              return Container(
                width: 280, // Fixed width for each card
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green[900]!.withOpacity(0.08),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Section
                      SizedBox(
                        height: 140,
                        width: double.infinity,
                        child: shop.fields.profileImage.isNotEmpty
                            ? Image.network(
                                shop.fields.profileImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholder();
                                },
                              )
                            : _buildPlaceholder(),
                      ),

                      // Content Section
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Shop Name
                              Text(
                                shop.fields.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),

                              // Address
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.green[800]?.withOpacity(0.9),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      shop.fields.address,
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Opening Hours
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_outlined,
                                    color: Colors.green[800]?.withOpacity(0.9),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${shop.fields.openingTime} - ${shop.fields.closingTime}',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // View Details Button
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ShopDetailPage(shop: shop),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Colors.green[900]?.withOpacity(0.9),
                                    foregroundColor: Colors.white,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'View Details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          Icons.storefront_outlined,
          size: 40,
          color: Colors.green[900]?.withOpacity(0.3),
        ),
      ),
    );
  }

  Future<void> addToFavorite(String productId, CookieRequest request) async {
    try {
      // Send POST request to favorite endpoint
      final response = await request.post(
        'http://m-arvin-sobat.pbp.cs.ui.ac.id/favorite/api/add/$productId/',
        {},
      );

      if (response['status'] == 'success') {
        // If successful, show success dialog
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Berhasil!',
          text: 'Produk berhasil ditambahkan ke favorit.',
          autoCloseDuration: Duration(seconds: 1),
          disableBackBtn: true,
          showConfirmBtn: false,
        );

        print('Produk berhasil ditambahkan ke favorit!');
        // Optionally, update the UI or state here
      } else {
        // If the product is already in favorites, show error dialog
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Gagal!',
          text: 'Produk sudah ada di favorit.',
          confirmBtnText: 'Kembali',
          onConfirmBtnTap: () {
            Navigator.pop(context);
          },
        );
      }
    } catch (error) {
      print('Terjadi kesalahan: $error');
    }
  }
}