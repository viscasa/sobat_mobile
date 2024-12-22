// screens/shop_detail_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sobat_mobile/shop/models/shop_model.dart';
import 'package:sobat_mobile/drug/models/drug_entry.dart';
import 'package:sobat_mobile/shop/screens/shop_form.dart';
import 'package:sobat_mobile/shop/screens/shop_manage_product.dart';
import 'package:sobat_mobile/shop/widgets/drug_card.dart';
import 'package:sobat_mobile/shop/screens/shop_profile_edit.dart';

class ShopDetailPage extends StatefulWidget {
  final ShopEntry shop;

  const ShopDetailPage({super.key, required this.shop});

  @override
  _ShopDetailPageState createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  static const String baseUrl = 'https://m-arvin-sobat.pbp.cs.ui.ac.id';
  List<DrugModel>? _drugs;
  List<DrugModel> _filteredDrugs = [];
  bool _isLoading = true;
  String _error = '';
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _loadDrugs();
    // We'll check ownership in build now since we need context for Provider
  }

  void _checkOwnership(BuildContext context) {
    try {
      final request = context.watch<CookieRequest>();
      int userId = request.jsonData['id'];

      setState(() {
        _isOwner = userId != 0 && userId == widget.shop.fields.owner;
      });
    } catch (e) {
      setState(() {
        _isOwner = false;
      });
      print('Error fetching user ID: $e');
    }
  }

  void _navigateToEditProfile() async {
      final result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShopEditPage(shop: widget.shop),
          ),
      );

      if (result != null && result is Map<String, dynamic>) {
          // Update the shop data in the state
          setState(() {
              widget.shop.fields.name = result['name'];
              widget.shop.fields.address = result['address'];
              widget.shop.fields.openingTime = result['opening_time'];
              widget.shop.fields.closingTime = result['closing_time'];
              widget.shop.fields.profileImage = result['profile_image'];
          });
          
          // Refresh the page
          if (mounted) {
              setState(() {});
          }
      }
  }

  void _navigateToManageProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShopManageProductsPage(shopId: '',), // shopId tidak disediakan
      ),
    );
  }

  Future<void> _loadDrugs() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/json/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (response.headers['content-type']?.contains('application/json') ?? false) {
          final List<DrugModel> drugs = welcomeFromJson(response.body);
          setState(() {
            _drugs = drugs;
            _filteredDrugs = drugs
                .where((drug) => drug.fields.shops.contains(widget.shop.pk))
                .toList();
            _isLoading = false;
          });
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _filteredDrugs = [];
        _isLoading = false;
        _error = 'Failed to load products. Please try again later.';
      });
    }
  }

  void _searchDrug(String query) {
    if (_drugs == null) return;

    setState(() {
      if (query.isEmpty) {
        _filteredDrugs = _drugs!;
      } else {
        _filteredDrugs = _drugs!.where((drug) {
          return drug.fields.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }
  
  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDrugs,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading products...'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check ownership here since we have access to context
    _checkOwnership(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: RefreshIndicator(
              color: Colors.green[900],
              onRefresh: _loadDrugs,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShopDetails(),
                  if (_isOwner) _buildOwnerActions(),
                  _buildSearchBar(),
                  if (_error.isNotEmpty)
                    _buildErrorWidget()
                  else if (_isLoading)
                    _buildLoadingWidget()
                  else
                    _buildDrugList(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isOwner
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShopFormPage()),
                );
              },
              backgroundColor: Colors.green[900],
              elevation: 2,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.green[900],
      flexibleSpace: FlexibleSpaceBar(
        background: widget.shop.fields.profileImage.isNotEmpty
            ? Image.network(
                widget.shop.fields.profileImage.startsWith('http')
                    ? widget.shop.fields.profileImage
                    : '$baseUrl${widget.shop.fields.profileImage}',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildPlaceholderIcon(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              )
            : _buildPlaceholderIcon(),
        title: Text(
          widget.shop.fields.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.green[100],
      child: Center(
        child: Icon(
          Icons.storefront_outlined,
          size: 80,
          color: Colors.green[900]?.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: _searchDrug,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.green[900], size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildOwnerActions() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              onPressed: _navigateToEditProfile,
              icon: Icons.edit_outlined,
              label: 'Edit Profile',
              isDark: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              onPressed: _navigateToManageProducts,
              icon: Icons.inventory_2_outlined,
              label: 'Manage Products',
              isDark: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: isDark ? Colors.green[900] : Colors.green[50],
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isDark ? Colors.white : Colors.green[900],
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.green[900],
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopDetails() {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            icon: Icons.location_on_outlined,
            title: 'Address',
            content: widget.shop.fields.address,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.access_time_outlined,
            title: 'Operating Hours',
            content:
                '${widget.shop.fields.openingTime} - ${widget.shop.fields.closingTime}',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.calendar_today_outlined,
            title: 'Established',
            content: widget.shop.fields.createdAt.toLocal().toString().split(' ')[0],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.green[900], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugList() {
    if (_filteredDrugs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.medication_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                "No products available in this shop.",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredDrugs.length, // Corrected the itemCount
        itemBuilder: (context, index) {
          final drug = _filteredDrugs[index];
          return DrugCard(drug: drug); // Assuming DrugCard widget exists and works
        },
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const DetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green[900], size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}