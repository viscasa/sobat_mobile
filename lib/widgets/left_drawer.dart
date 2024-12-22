import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sobat_mobile/colors.dart';
import 'package:sobat_mobile/daftar_favorite/screens/daftar_favorite.dart';
import 'package:sobat_mobile/forum/screens/forum.dart';
// import 'package:mental_health_tracker/screens/list_moodentry.dart';
// import 'package:mental_health_tracker/screens/menu.dart';
import 'package:sobat_mobile/homepage.dart';
import 'package:sobat_mobile/drug/screens/list_drugentry.dart';
import 'package:sobat_mobile/resep/screen/resep.dart';
import 'package:sobat_mobile/shop/screens/shop_main_page.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solo Obat',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  "Ayo Cari Obat Terbaikmu!",
                  style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                        color: Colors.white
                        ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.house),
            title: const Text('Halaman Utama'),
            // Bagian redirection ke MyHomePage
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyHomePage(),
                  ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Daftar Favorite'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ProductListScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.prescriptionBottleMedical),
            title: const Text('Product'),
            onTap: () {
              // Route menu ke halaman mood
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DrugEntryPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.solidComments),
            title: const Text('Forum'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForumPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.shop),
            title: const Text('Shop'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ShopMainPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.cartShopping),
            title: const Text('Cart'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CartList()),
              );
            },
          ),
        ],
      ),
    );
  }
}
