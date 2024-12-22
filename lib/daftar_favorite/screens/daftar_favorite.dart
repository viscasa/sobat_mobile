import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:sobat_mobile/daftar_favorite/models/models.dart';
import 'package:sobat_mobile/daftar_favorite/screens/detail.dart';
import 'package:sobat_mobile/daftar_favorite/widgets/list_product.dart';
import 'package:sobat_mobile/drug/models/drug_entry.dart';
import 'package:sobat_mobile/drug/screens/drug_detail.dart';
import 'package:sobat_mobile/widgets/left_drawer.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<FavoriteEntry> favoriteProducts = [];
  final String baseUrl = 'https://m-arvin-sobat.pbp.cs.ui.ac.id/media/';
  TextEditingController _newController = new TextEditingController();
  // int totalFavorit = 0;

  Map<String, dynamic> productDetailsMap = {};
  Map<String, String> productPKMap = {};
  late Future<void> fetchFuture;
  @override
  void initState() {
    super.initState();

    fetchFuture = fetchProduct(CookieRequest()); // Memuat data awal
  }

  Future<List<FavoriteEntry>> fetchProduct(CookieRequest request) async {
    final response = await request
        .get('https://m-arvin-sobat.pbp.cs.ui.ac.id/favorite/json/');
    var data = response;

    // Melakukan konversi data json menjadi object MoodEntry
    List<FavoriteEntry> listMood = [];
    for (var d in data) {
      if (d != null) {
        listMood.add(FavoriteEntry.fromJson(d));
        String b = d["fields"]["product"];

        String pk = d['pk'];
        productPKMap[b] = pk;

        final responses = await http.get(Uri.parse(
            'https://m-arvin-sobat.pbp.cs.ui.ac.id/product/json/$b/'));
        var test = jsonDecode(responses.body);
        var fields = test[0]["fields"];
        productDetailsMap[b] = fields;

        // print(productDetailsMap);
        // var test = responseJson;
        // print(test);
      }
    }
    // print(listMood.toString());
    return listMood;
  }

  Future<void> editFavorite(
      String favoriteId, String newNote, CookieRequest request) async {
    final url = await request
        .get('https://m-arvin-sobat.pbp.cs.ui.ac.id/favorite/json/');
    var data = url;

    try {
      final response = await request.postJson(
        url,
        jsonEncode(<String, String>{
          "catatan": newNote,
        }),
      );
    } catch (e) {
      print("Request failed: $e");
    }
  }

  Future<DrugModel> fetchDrugDetails(String productId) async {
    final response = await http.get(
      Uri.parse(
          'https://m-arvin-sobat.pbp.cs.ui.ac.id/product/json/$productId/'),
    );

    if (response.statusCode == 200) {
      // Pastikan respons adalah Map<String, dynamic>
      final List<dynamic> jsonList = jsonDecode(response.body);
      if (jsonList.isNotEmpty) {
        // Ambil elemen pertama dari list
        final Map<String, dynamic> jsonMap = jsonList[0];
        return DrugModel.fromJson(jsonMap);
      } else {
        throw Exception("Data produk tidak ditemukan");
      }
    } else {
      throw Exception("Gagal memuat produk: ${response.statusCode}");
    }
  }

  void navigateToProductDetail(BuildContext context, String productId,
      String productPk, CookieRequest request) async {
    try {
      DrugModel product = await fetchDrugDetails(productId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => detailPage(
            product: product.fields,
            addCart: () => addToResep(productId, request),
            // detailRoute: () => deleteProduct(productPk),
            detailRoute: () => showConfirm(productPk, true),
            pk: productPk,
            request: request,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat detail produk: $e")),
      );
    }
  }

  void showConfirm(String productId, bool isInProduct) {
    setState(() {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: "Do you want to Remove",
        confirmBtnText: "Yes",
        cancelBtnText: "NO",
        onConfirmBtnTap: () async {
          await deleteProduct(
              productId, isInProduct); // Panggil fungsi penghapusan
        },
      );
    });
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

  Future<void> deleteProduct(String productId, bool isinProduct) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://m-arvin-sobat.pbp.cs.ui.ac.id/favorite/api/$productId/'),
        headers: {
          'Content-Type': 'application/json',
          // Sertakan CSRF token
        },
      );

      if (response.statusCode == 200) {
        List<FavoriteEntry> updatedFavorites =
            await fetchProduct(CookieRequest());
        setState(
          () {
            favoriteProducts = updatedFavorites; // Perbarui state
          },
        );
        if (isinProduct) {
          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }
      } else {
        print('Gagal menghapus produk. Status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    return Scaffold(
      drawer: LeftDrawer(),
      appBar: AppBar(
        title: const Text("Daftar Produk Favorit"),
      ),
      body: FutureBuilder(
        future: fetchProduct(CookieRequest()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Terjadi kesalahan: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada produk favorit.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          } else {
            final products = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        String productId = product.fields.product;
                        String url = productDetailsMap[productId]["image"];
                        String imageUrl = '$baseUrl$url';
                        String productPk = productPKMap[productId] ?? '';
                        String drugForm =
                            productDetailsMap[productId]["drug_form"];
                        String drugCategory =
                            productDetailsMap[productId]["category"];

                        ;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 5),
                          child: productTile(
                            name: productDetailsMap[productId]["name"],
                            price: productDetailsMap[productId]["price"],
                            imageUrl: imageUrl,
                            onPressed: () => showConfirm(productPk, false),
                            drugForm: drugForm,
                            category: drugCategory,
                            detailRoute: () => navigateToProductDetail(
                                context, productId, productPk, request),
                            addCart: () => addToResep(productId, request),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
