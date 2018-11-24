import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './product_card.dart';
import '../scoped_models/main.dart';
import '../models/product.dart';

class Products extends StatelessWidget {
  Widget _buildProductList(List<Product> products, bool isLoading) {
    Widget productList;
    if (isLoading){
      return Center(child: CircularProgressIndicator());
    }else if (products.length > 0) {
      productList = ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ProductCard(index);
        },
        itemCount: products.length,
      );
    } else {
      productList = Center(
        child: Text('No products found'),
      );
    }
    return productList;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget widget, MainModel model) {
      return _buildProductList(model.displayedProducts, model.isLoading);
    });
  }
}
