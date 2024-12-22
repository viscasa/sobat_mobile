import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:sobat_mobile/drug/models/drug_entry.dart';

class ShopManageProductsPage extends StatefulWidget {
  final String shopId;

  const ShopManageProductsPage({
    super.key, 
    required this.shopId,
  });

  @override
  State<ShopManageProductsPage> createState() => _ShopManageProductsPageState();
}

class _ShopManageProductsPageState extends State<ShopManageProductsPage> {
  final String baseUrl = 'http://m-arvin-sobat.pbp.cs.ui.ac.id';
  List<DrugModel> _allProducts = [];
  Set<String> _selectedProducts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final request = context.read<CookieRequest>();
    try {
      // Get all products
      final productsResponse = await request.get('$baseUrl/product/json/');
      // Get shop's current products
      final shopProductsResponse = await request.get(
        '$baseUrl/shop/get-shop-products/${widget.shopId}/'
      );

      setState(() {
        // Parse all products
        _allProducts = (productsResponse as List)
            .map((item) => DrugModel.fromJson(item))
            .toList();

        // Set initially selected products
        _selectedProducts = Set.from(
          (shopProductsResponse as List).map((id) => id.toString())
        );
        
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load products'))
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    final request = context.read<CookieRequest>();

    try {
      final response = await request.post(
        '$baseUrl/shop/update-shop-products/${widget.shopId}/',
        {
          'selected_products': _selectedProducts.toList(),
        },
      );

      if (mounted) {
        if (response['status'] == 'success') {
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update products'))
          );
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error saving changes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error saving changes'))
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _allProducts.length,
              itemBuilder: (context, index) {
                final product = _allProducts[index];
                final isSelected = _selectedProducts.contains(product.pk);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isSelected ? Colors.green.shade50 : null,
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value ?? false) {
                          _selectedProducts.add(product.pk);
                        } else {
                          _selectedProducts.remove(product.pk);
                        }
                      });
                    },
                    title: Text(
                      product.fields.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${product.fields.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        if (product.fields.desc.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            product.fields.desc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                    secondary: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '${baseUrl}${product.fields.image}',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}