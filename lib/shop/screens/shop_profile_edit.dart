import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:sobat_mobile/shop/models/shop_model.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;

class ShopEditPage extends StatefulWidget {
  final ShopEntry shop;

  const ShopEditPage({super.key, required this.shop});

  @override
  State<ShopEditPage> createState() => _ShopEditPageState();
}

class _ShopEditPageState extends State<ShopEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _openingTimeController;
  late TextEditingController _closingTimeController;
  File? _selectedImage;
  String? _selectedImageBase64;
  String? _currentImageUrl;
  static const String baseUrl = 'http://m-arvin-sobat.pbp.cs.ui.ac.id';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.shop.fields.name);
    _addressController =
        TextEditingController(text: widget.shop.fields.address);
    _openingTimeController =
        TextEditingController(text: widget.shop.fields.openingTime);
    _closingTimeController =
        TextEditingController(text: widget.shop.fields.closingTime);
    _currentImageUrl = widget.shop.fields.profileImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  Future<String?> _pickImageWeb() async {
    final completer = Completer<String>();
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) async {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((_) {
          completer.complete(reader.result as String);
        });
      }
    });

    return completer.future;
  }

  Future<File?> _pickImageNonWeb() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      return File(pickedImage.path);
    }
    return null;
  }

  Future<void> _selectImage() async {
    if (kIsWeb) {
      final base64Image = await _pickImageWeb();
      if (base64Image != null) {
        setState(() {
          _selectedImage = null;
          _selectedImageBase64 = base64Image;
          _currentImageUrl = null;
        });
      }
    } else {
      final pickedImage = await _pickImageNonWeb();
      if (pickedImage != null) {
        setState(() {
          _selectedImage = pickedImage;
          _selectedImageBase64 = null;
          _currentImageUrl = null;
        });
      }
    }
  }

  String? _imageToBase64() {
    if (kIsWeb && _selectedImageBase64 != null) {
      return _selectedImageBase64;
    } else if (_selectedImage != null) {
      final bytes = _selectedImage!.readAsBytesSync();
      return 'data:image/${_selectedImage!.path.split('.').last};base64,${base64Encode(bytes)}';
    }
    return null;
  }

  String formatTime(String time) {
    try {
      if (time.contains(':') && time.length == 8) {
        final DateTime parsedTime = DateFormat('HH:mm:ss').parse(time);
        return DateFormat('HH:mm').format(parsedTime);
      }

      final DateTime parsedTime = DateFormat.jm().parse(time);
      return DateFormat('HH:mm').format(parsedTime);
    } catch (e) {
      print('Error parsing time: $time, Error: $e');
      return time;
    }
  }

  Future<void> _submitForm(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final shopData = {
        'name': _nameController.text,
        'address': _addressController.text,
        'opening_time': formatTime(_openingTimeController.text),
        'closing_time': formatTime(_closingTimeController.text),
      };

      if (_selectedImage != null || _selectedImageBase64 != null) {
        shopData['profile_image'] = _imageToBase64()!;
      }

      final response = await request.post(
        '$baseUrl/shop/edit_shop_flutter/${widget.shop.pk}/',
        shopData,
      );

      if (response is Map<String, dynamic>) {
        if (response['status'] == 'success') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Shop updated successfully!')),
            );

            // Return updated shop data
            Navigator.pop(context, {
              'name': _nameController.text,
              'address': _addressController.text,
              'opening_time': formatTime(_openingTimeController.text),
              'closing_time': formatTime(_closingTimeController.text),
              'profile_image': response['data']['profile_image'] ??
                  widget.shop.fields.profileImage,
            });
          }
        } else {
          throw Exception(response['message'] ?? 'Update failed');
        }
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Widget _buildCurrentImage() {
    if (_selectedImage != null || _selectedImageBase64 != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(_selectedImage != null || _selectedImageBase64 != null
              ? 'New image selected'
              : 'No image selected'),
        ),
      );
    }

    if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            _currentImageUrl!.startsWith('http')
                ? _currentImageUrl!
                : '$baseUrl$_currentImageUrl',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text('Error loading image'));
            },
          ),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Center(child: Text('No image available')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Shop Profile'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCurrentImage(),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: _selectImage,
                icon: const Icon(Icons.image),
                label: const Text('Change Profile Image'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Shop Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a shop name' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Shop Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a shop address' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _openingTimeController,
                decoration: const InputDecoration(
                  labelText: 'Opening Time',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectTime(context, _openingTimeController),
                validator: (value) =>
                    value!.isEmpty ? 'Please select opening time' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _closingTimeController,
                decoration: const InputDecoration(
                  labelText: 'Closing Time',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () => _selectTime(context, _closingTimeController),
                validator: (value) =>
                    value!.isEmpty ? 'Please select closing time' : null,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => _submitForm(request),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
