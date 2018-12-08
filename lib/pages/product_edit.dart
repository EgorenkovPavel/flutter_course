import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';
import '../scoped_models/main.dart';
import '../widgets/location.dart';
import '../models/location_data.dart';

class ProductEditPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _productEditPageState();
  }
}

class _productEditPageState extends State<ProductEditPage> {
  Map<String, dynamic> _formData = {
    'title': null,
    'image': 'assets/food.jpg',
    'description': null,
    'price': null,
    'location': null
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget _buildTitleTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Title'),
      initialValue: product == null ? '' : product.title,
      validator: (String value) {
        if (value.isEmpty || value.length < 5) {
          return 'Title is requared';
        }
      },
      onSaved: (String value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    return TextFormField(
      initialValue: product == null ? '' : product.description,
      maxLines: 4,
      decoration: InputDecoration(labelText: 'Description'),
      validator: (String value) {
        if (value.isEmpty || value.length < 10) {
          return 'Description is requared';
        }
      },
      onSaved: (String value) {
        _formData['description'] = value;
      },
    );
  }

  Widget _buildPriceTextField(Product product) {
    return TextFormField(
      initialValue: product == null ? '' : product.price.toString(),
      decoration: InputDecoration(labelText: 'Price'),
      keyboardType: TextInputType.number,
      validator: (String value) {
        if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:[.,]\d+)?$').hasMatch(value)) {
          return 'Price is requared';
        }
      },
      onSaved: (String value) {
        _formData['price'] = double.parse(value);
      },
    );
  }

  void _setLocation(LocationData locationData){
    _formData['location'] = locationData;
  }

  void _submitForm(Product product, Function addProduct,
      Function updateProduct) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    ;
    _formKey.currentState.save();
//    Product newProduct = Product(
//        title: _formData['title'],
//        description: _formData['description'],
//        price: _formData['price'],
//        image: _formData['image']);
    if (product == null) {
      addProduct(_formData['title'],
          _formData['description'],
          _formData['image'],
          _formData['price'],
          _formData['location']);
    } else {
      updateProduct(_formData['title'],
          _formData['description'],
          _formData['image'],
          _formData['price'],
          _formData['location']);
    }

    Navigator.pushReplacementNamed(context, '/');
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
          return RaisedButton(
              color: Theme
                  .of(context)
                  .accentColor,
              textColor: Colors.white,
              child: Text('Save'),
              onPressed: () {
                return _submitForm(model.selectedProduct, model.addProduct,
                    model.updateProduct);
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final targetPadding = (deviceWidth - targetWidth) / 2;

    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
          Product product = model.selectedProduct;
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
              margin: EdgeInsets.all(10.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: targetPadding),
                  children: <Widget>[
                    _buildTitleTextField(product),
                    _buildDescriptionTextField(product),
                    _buildPriceTextField(product),
                    SizedBox(
                      height: 10.0,
                    ),
                    LocationInput(_setLocation, product),
                    SizedBox(
                      height: 10.0,
                    ),
                    _buildSubmitButton()
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}
