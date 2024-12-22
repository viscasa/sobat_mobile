import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddDrugForm extends StatefulWidget {
  @override
  _AddDrugFormState createState() => _AddDrugFormState();
}

class _AddDrugFormState extends State<AddDrugForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController drugTypeController = TextEditingController();
  TextEditingController drugFormController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  Uint8List? _image;
  String? _imageName;

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

  Future<void> submitDrug() async {
    if (_formKey.currentState!.validate()) {
      var uri = Uri.parse('https://m-arvin-sobat.pbp.cs.ui.ac.id/product/create-drug-ajax/');
      var request = http.MultipartRequest('POST', uri)
        ..fields['name'] = nameController.text
        ..fields['desc'] = descController.text
        ..fields['category'] = categoryController.text
        ..fields['drug_type'] = drugTypeController.text
        ..fields['drug_form'] = drugFormController.text
        ..fields['price'] = priceController.text;

      if (_image != null && _imageName != null) {
        request.files.add(http.MultipartFile.fromBytes('image', _image!, filename: _imageName));
      }

      var response = await request.send();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Drug added successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add drug')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Drug Entry')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    pickImage();
                  },
                  child: Text('Pick Image'),
                ),
              ),
              ElevatedButton(
                onPressed: submitDrug,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
