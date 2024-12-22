import 'dart:convert'; // Import for jsonDecode
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class EditDrugForm extends StatefulWidget {
  final String productId; // The primary key of the product to edit

  const EditDrugForm({Key? key, required this.productId}) : super(key: key);

  @override
  _EditDrugFormState createState() => _EditDrugFormState();
}

class _EditDrugFormState extends State<EditDrugForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController drugTypeController = TextEditingController();
  TextEditingController drugFormController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  Uint8List? _image;
  String? _imageName;
  bool _isLoading = true; // To handle loading state
  String? existingImageUrl;
  final String baseUrl =
      'https://m-arvin-sobat.pbp.cs.ui.ac.id/media/'; // Adjust if needed

  @override
  void initState() {
    super.initState();
    fetchExistingData(); // Fetch data when the widget initializes
  }

  Future<void> fetchExistingData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://m-arvin-sobat.pbp.cs.ui.ac.id/product/json/${widget.productId}/')); // Adjust endpoint
      if (response.statusCode == 200) {
        final data =
            jsonDecode(response.body); // Ensure jsonDecode is available
        setState(() {
          nameController.text = data['fields']['name'];
          descController.text = data['fields']['desc'];
          categoryController.text = data['fields']['category'];
          drugTypeController.text = data['fields']['drug_type'];
          drugFormController.text = data['fields']['drug_form'];
          priceController.text = data['fields']['price'].toString();
          existingImageUrl = '$baseUrl${data['fields']['image']}';
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load product data')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching product data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while fetching data')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        // Handling for Flutter Web
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _image = bytes;
          _imageName = pickedFile.name;
        });
      } else {
        // Handling for Mobile
        final file = File(pickedFile.path);
        final bytes = await file.readAsBytes();
        setState(() {
          _image = bytes;
          _imageName = pickedFile.name;
        });
      }
    }
  }

  Future<void> submitEdit() async {
    if (_formKey.currentState!.validate()) {
      var uri = Uri.parse(
          'https://m-arvin-sobat.pbp.cs.ui.ac.id/edit-drug-ajax/${widget.productId}/');
      var request = http.MultipartRequest('POST', uri)
        ..fields['name'] = nameController.text
        ..fields['desc'] = descController.text
        ..fields['category'] = categoryController.text
        ..fields['drug_type'] = drugTypeController.text
        ..fields['drug_form'] = drugFormController.text
        ..fields['price'] = priceController.text;

      if (_image != null && _imageName != null) {
        request.files.add(http.MultipartFile.fromBytes('image', _image!,
            filename: _imageName));
      }

      try {
        var response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Drug updated successfully')),
          );
          Navigator.pop(context); // Go back to the previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update drug')),
          );
        }
      } catch (e) {
        print('Error updating drug: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred while updating')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Drug Entry'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    // Name Field
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the drug name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Description Field
                    TextFormField(
                      controller: descController,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Category Field
                    TextFormField(
                      controller: categoryController,
                      decoration: InputDecoration(labelText: 'Category'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Drug Type Field
                    TextFormField(
                      controller: drugTypeController,
                      decoration: InputDecoration(labelText: 'Drug Type'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the drug type';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Drug Form Field
                    TextFormField(
                      controller: drugFormController,
                      decoration: InputDecoration(labelText: 'Drug Form'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the drug form';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Price Field
                    TextFormField(
                      controller: priceController,
                      decoration: InputDecoration(labelText: 'Price'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the price';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    // Image Preview
                    existingImageUrl != null && _image == null
                        ? Image.network(
                            existingImageUrl!,
                            height: 200,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey.shade200,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : _image != null
                            ? Image.memory(
                                _image!,
                                height: 200,
                              )
                            : SizedBox.shrink(),
                    SizedBox(height: 16),
                    // Image Picker
                    ElevatedButton(
                      onPressed: pickImage,
                      child: Text('Pick New Image'),
                    ),
                    SizedBox(height: 16),
                    // Submit Button
                    ElevatedButton(
                      onPressed: submitEdit,
                      child: Text('Update'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
