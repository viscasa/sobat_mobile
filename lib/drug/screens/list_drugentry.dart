import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sobat_mobile/drug/models/drug_entry.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sobat_mobile/drug/screens/drug_detail.dart';
import 'package:sobat_mobile/drug/screens/drugedit_form.dart';
import 'package:sobat_mobile/drug/screens/drugentry_form.dart'; // Assuming the form is in this file
import 'package:http/http.dart' as http;
import 'package:sobat_mobile/widgets/left_drawer.dart';

class DrugEntryPage extends StatefulWidget {
  const DrugEntryPage({super.key});

  @override
  State<DrugEntryPage> createState() => _DrugEntryPageState();
}

class _DrugEntryPageState extends State<DrugEntryPage> {
  // Define the base URL for images
  final String baseUrl = 'https://m-arvin-sobat.pbp.cs.ui.ac.id/media/';

  Future<List<DrugModel>> fetchProductEntries(CookieRequest request) async {
    final response = await request
        .get('https://m-arvin-sobat.pbp.cs.ui.ac.id/product/json/');
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

  void showSucces(String productId, CookieRequest request) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      onConfirmBtnTap: () => addToFavorite(productId, request),
    );
  }

  Future<void> addToResep(String productId, CookieRequest request) async {
    try {
      // Send POST request to favorite endpoint
      final response = await request.post(
        'https://m-arvin-sobat.pbp.cs.ui.ac.id/resep/flutter_add/$productId/',
        {},
      );

      if (response['status'] == 'success') {
        // If successful, show success dialog
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Berhasil!',
          text: 'Produk berhasil ditambahkan ke resep.',
          autoCloseDuration: Duration(seconds: 1),
          disableBackBtn: true,
          showConfirmBtn: false,
        );

        print('Produk berhasil ditambahkan ke resep!');
        // Optionally, update the UI or state here
      } else {
        // If the product is already in favorites, show error dialog
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Gagal!',
          text: 'Produk sudah ada di resep.',
          confirmBtnText: 'Kembali',
          onConfirmBtnTap: () {
            Navigator.pop(context); // Close the dialog
          },
        );
      }
    } catch (error) {
      print('Terjadi kesalahan: $error');
      // Optionally, show an error dialog here
    }
  }

  Future<void> addToFavorite(String productId, CookieRequest request) async {
    try {
      // Send POST request to favorite endpoint
      final response = await request.post(
        'https://m-arvin-sobat.pbp.cs.ui.ac.id/favorite/api/add/$productId/',
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
            Navigator.pop(context); // Close the dialog
          },
        );
      }
    } catch (error) {
      print('Terjadi kesalahan: $error');
      // Optionally, show an error dialog here
    }
  }

  Future<bool> deleteProduct(String productId) async {
    final url =
        'https://m-arvin-sobat.pbp.cs.ui.ac.id/product/delete-drug/$productId/';
    final response = await http.get(Uri.parse(url));

    return response.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      drawer: LeftDrawer(),
      appBar: AppBar(
        title: const Text('Product Entry List'),
      ),
      body: FutureBuilder(
        future: fetchProductEntries(request),
        builder: (context, AsyncSnapshot<List<DrugModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum ada data produk pada Grosa.',
                      style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  final product = snapshot.data![index];
                  final imageUrl = '$baseUrl${product.fields.image}';

                  return InkWell(
                    onTap: () {
                      // Navigate to product detail page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailPage(
                            product: product,
                            detailRoute: () =>
                                addToFavorite(product.pk, request),
                            onPressed: () => addToResep(product.pk, request),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Expanded widget for product details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.fields.name,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Harga: \$${product.fields.price}",
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Optional: Display description if needed
                                // Text(
                                //   "Deskripsi: ${product.fields.desc}",
                                //   style: const TextStyle(
                                //     fontSize: 14.0,
                                //     color: Colors.black54,
                                //   ),
                                // ),
                                const SizedBox(height: 8),
                                // Row for edit and delete buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit,
                                          color: Colors.blue.shade700),
                                      onPressed: () {
                                        // Navigate to edit form, passing the selected product
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditDrugForm(
                                                productId: product.pk),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete,
                                          color: Colors.red.shade700),
                                      onPressed: () async {
                                        bool success = await deleteProduct(
                                            product.pk.toString());
                                        if (success) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                'Product successfully deleted'),
                                          ));
                                          // Optionally refresh the list
                                          setState(() {});
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                'Failed to delete product'),
                                          ));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Image widget
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
      // Floating action button to navigate to the drug entry form for adding new drug
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddDrugForm(), // Navigate to the add drug form
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
