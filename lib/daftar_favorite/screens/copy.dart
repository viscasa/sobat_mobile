// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:pbp_django_auth/pbp_django_auth.dart';
// import 'package:sobat_mobile/daftar_favorite/models/models.dart';
// import 'package:sobat_mobile/daftar_favorite/widgets/list_product.dart';

// class copyDaftar extends StatefulWidget {
//   const copyDaftar({Key? key}) : super(key: key);

//   @override
//   _copyDaftarState createState() => _copyDaftarState();
// }

// class _copyDaftarState extends State<copyDaftar> {
//   final String baseUrl = 'http://localhost:8000/media/';
//   int totalFavorit = 0;
//   Map<String, dynamic> productDetailsMap = {};
//   Map<String, String> productPKMap = {};
//   late Future<void> fetchFuture;
//   @override
//   void initState() {
//     super.initState();
//     fetchFuture = fetchMood(CookieRequest()); // Memuat data awal
//   }

//   Future<List<FavoriteEntry>> fetchMood(CookieRequest request) async {
//     final response = await request.get('http://127.0.0.1:8000/favorite/json/');
//     var data = response;
//     print(data);

//     // Melakukan konversi data json menjadi object MoodEntry
//     List<FavoriteEntry> listMood = [];
//     for (var d in data) {
//       if (d != null) {
//         totalFavorit++;
//         listMood.add(FavoriteEntry.fromJson(d));
//         String b = d["fields"]["product"];
//         String pk = d['pk'];
//         productPKMap[b] = pk;

//         final responses =
//             await http.get(Uri.parse('http://127.0.0.1:8000/product/json/$b/'));
//         var test = jsonDecode(responses.body);
//         var fields = test[0]["fields"];
//         productDetailsMap[b] = fields;

//         // print(productDetailsMap);
//         // var test = responseJson;
//         // print(test);
//       }
//     }
//     // print(listMood.toString());
//     return listMood;
//   }

//   Future<void> deleteProduct(String productId) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('http://127.0.0.1:8000/favorite/delete/$productId/'),
//         // headers: {
//         //   'Content-Type': 'application/json',
//         // },
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           productDetailsMap.remove(productId.toString());
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Produk berhasil dihapus!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Gagal menghapus produk.')),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Terjadi kesalahan: $error')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Daftar Produk Favorit"),
//       ),
//       body: FutureBuilder(
//         future: fetchMood(CookieRequest()),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 "Terjadi kesalahan: ${snapshot.error}",
//                 style: const TextStyle(color: Colors.red),
//               ),
//             );
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(
//               child: Text(
//                 "Belum ada produk favorit.",
//                 style: TextStyle(fontSize: 18, color: Colors.grey),
//               ),
//             );
//           } else {
//             final products = snapshot.data!;
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10.0),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [Text("Item : $totalFavorit")],
//                   ),
//                   GridView.builder(
//                     physics: NeverScrollableScrollPhysics(),
//                     shrinkWrap: true,
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       childAspectRatio: 0.75,
//                     ),
//                     itemCount: products.length,
//                     itemBuilder: (context, index) {
//                       final product = products[index];
//                       String productId = product.fields.product;
//                       String url = productDetailsMap[productId]["image"];
//                       String imageUrl = '$baseUrl$url';
//                       String productPk = productPKMap[productId] ?? '';
//                       String drugForm =
//                           productDetailsMap[productId]["drug_form"];
//                       String drugCategory =
//                           productDetailsMap[productId]["category"];
//                       // print("ini pk" + productPk);
//                       // print(productPKMap);
//                       // print(productDetailsMap);

//                       // Get the product details from the map (this should be updated once product data is loaded)
//                       // Map<String, dynamic>? productDetails =
//                       //     productDetailsMap[productId];
//                       // String productName = productDetails != null
//                       //     ? productDetails['fields']['name']
//                       //     : 'Loading...';

//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // productTile(
//                           //     name: productDetailsMap[productId]["name"],
//                           //     price: productDetailsMap[productId]["price"]),
//                           productTile(
//                             name: productDetailsMap[productId]["name"],
//                             price: productDetailsMap[productId]["price"],
//                             imageUrl: imageUrl,
//                             onPressed: () => deleteProduct(productPk),
//                             drugForm: drugForm,
//                             category: drugCategory,
//                             detailRoute: () {},
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
