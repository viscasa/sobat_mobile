import 'package:flutter/material.dart';
import 'package:sobat_mobile/shop/models/shop_model.dart' as model;
import 'package:sobat_mobile/shop/screens/shop_detail_page.dart';

class ShopCard extends StatelessWidget {
  final model.ShopEntry shop;

  const ShopCard({
    super.key,
    required this.shop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (Colors.green[900] ?? Colors.green).withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                image: shop.fields.profileImage.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(shop.fields.profileImage),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: shop.fields.profileImage.isEmpty
                  ? Center(
                      child: Icon(
                        Icons.storefront_outlined,
                        size: 64,
                        color: Colors.green[900]?.withOpacity(0.3),
                      ),
                    )
                  : null,
            ),

            // Content Section
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Name
                  Text(
                    shop.fields.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.green[800]?.withOpacity(0.9),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          shop.fields.address,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            height: 1.5,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Opening Hours
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        color: Colors.green[800]?.withOpacity(0.9),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${shop.fields.openingTime} - ${shop.fields.closingTime}',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          height: 1.5,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopDetailPage(shop: shop),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green[900]?.withOpacity(0.9),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}