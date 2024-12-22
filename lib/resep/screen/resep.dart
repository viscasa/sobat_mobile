import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:sobat_mobile/daftar_favorite/screens/detail.dart';
import 'package:sobat_mobile/drug/models/drug_entry.dart';
import 'package:sobat_mobile/drug/screens/drug_detail.dart';
import 'package:sobat_mobile/resep/models/resep_model.dart';
import 'package:sobat_mobile/resep/widgets/list_product.dart';
import 'package:sobat_mobile/widgets/left_drawer.dart';

class CartList extends StatefulWidget {
  const CartList({Key? key}) : super(key: key);

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<CartList> {
  List<Resep> favoriteProducts = [];
  double totalPrice = 0;
  final String baseUrl = 'https://m-arvin-sobat.pbp.cs.ui.ac.id8000/media/';
  TextEditingController _newController = new TextEditingController();
  // int totalFavorit = 0;

  Map<String, dynamic> productDetailsMap = {};
  Map<String, String> productPKMap = {};
  late Future<void> fetchFuture;
  @override
  void initState() {
    super.initState();

    fetchFuture = fetchResep(CookieRequest()); // Memuat data awal
  }

  Future<List<Resep>> fetchResep(CookieRequest request) async {
    final response =
        await request.get('https://m-arvin-sobat.pbp.cs.ui.ac.id/resep/json/');
    var data = response;

    // Melakukan konversi data json menjadi object MoodEntry
    List<Resep> listMood = [];
    for (var d in data) {
      if (d != null) {
        listMood.add(Resep.fromJson(d));
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

  // void navigateToProductDetail(BuildContext context, String productId,
  //     String productPk, CookieRequest request) async {
  //   try {
  //     DrugModel product = await fetchDrugDetails(productId);
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => detailPage(
  //           product: product.fields,

  //           // detailRoute: () => deleteProduct(productPk),
  //           detailRoute: () => showConfirm(productPk, true),
  //           pk: productPk,
  //           request: request,
  //         ),
  //       ),
  //     );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Gagal memuat detail produk: $e")),
  //     );
  //   }
  // }

  void showConfirm(String productId, bool isInProduct) {
    setState(() {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.confirm,
        text: "Do you want to Remove",
        confirmBtnText: "Yes",
        cancelBtnText: "NO",
        onConfirmBtnTap: () {
          // Panggil fungsi penghapusan
        },
      );
    });
  }

  void removeAll(CookieRequest request) async {
    var url = 'https://m-arvin-sobat.pbp.cs.ui.ac.id/resep/flutter_clear/';
    try {
      var response = await request.post(url, {});

      print(response);
      if (response['success']) {
        // Jika item dihapus dan tidak ada item lain, mungkin perlu refresh data
        fetchFuture = fetchResep(
            request); // Fetch new data which setState will be called in FutureBuilder
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Product Deleted"),
              content: Text("All product has been removed."),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    setState(() {
                      totalPrice = 0;
                    }); // Force rebuild to reflect changes
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle any errors here
      print(e.toString());
    }
  }

  void updateProduct(String id, String action, int index, int newQuantity,
      CookieRequest request) async {
    var url = 'https://m-arvin-sobat.pbp.cs.ui.ac.id/resep/flutter_update/';
    try {
      var response = await request.post(url, {
        'resep_id': id,
        'action': action,
      });

      print(response);
      if (response['deleted'] || response['reloaded']) {
        // Jika item dihapus dan tidak ada item lain, mungkin perlu refresh data
        fetchFuture = fetchResep(
            request); // Fetch new data which setState will be called in FutureBuilder
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Product Deleted"),
              content: Text("The product has been removed."),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    setState(() {
                      totalPrice = response["total_price"];
                    }); // Force rebuild to reflect changes
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Tampilkan pemberitahuan atau dialog sesuai dengan hasil
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Update Successful"),
              content: Text("Product amount has been updated."),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      totalPrice = response["total_price"];
                    });
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle any errors here
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      drawer: LeftDrawer(),
      appBar: AppBar(
        title: const Text("Daftar Resep"),
      ),
      body: FutureBuilder(
        future: fetchResep(CookieRequest()),
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
                "Belum ada resep.",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          } else {
            final products = snapshot.data!;
            favoriteProducts = products;
            for (var product in products) {
              totalPrice += product.fields.amount *
                  productDetailsMap[product.fields.product]["price"];
            }
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
                          child: ResepTile(
                            name: productDetailsMap[productId]["name"],
                            price: productDetailsMap[productId]["price"],
                            imageUrl: imageUrl,
                            drugForm: drugForm,
                            category: drugCategory,
                            // detailRoute: () => navigateToProductDetail(
                            //     context, productId, productPk, request),
                            quantity: product.fields.amount,
                            onQuantityChanged: (newQuantity, action) =>
                                updateProduct(product.pk, action, index,
                                    newQuantity, request),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Total Price: ${NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(totalPrice)}'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(
                          context, products, totalPrice, request);
                    },
                    child: Text('Checkout',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 211, 239, 211))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green, // Set the background color to green
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

  void _showConfirmationDialog(BuildContext context, List<Resep> products,
      double totalPrice, CookieRequest request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text('Purchase Summary'),
            ],
          ),
          content: SingleChildScrollView(
            // Added to handle overflow when list is long
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...products.map((product) {
                  return ListTile(
                    leading: Image.network(
                        baseUrl +
                            productDetailsMap[product.fields.product]["image"],
                        width: 50),
                    title:
                        Text(productDetailsMap[product.fields.product]["name"]),
                    subtitle: Text(
                        'Jumlah: ${product.fields.amount} - Total: ${NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(product.fields.amount * productDetailsMap[product.fields.product]["price"])}'),
                  );
                }).toList(),
                SizedBox(height: 16),
                Text(
                  'Total Price: ${NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(totalPrice)}', // Ensures the price is formatted correctly
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                removeAll(request);
              },
              child: Text('Remove all medications',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 252, 225, 223))),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red, // Set the background color to green
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Back to prescription',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 211, 239, 211))),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green, // Set the background color to green
              ),
            ),
          ],
        );
      },
    );
  }
}
