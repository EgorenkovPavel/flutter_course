import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/products.dart';
import '../scoped_models/main.dart';

class ProductsPage extends StatefulWidget {
  final MainModel model;

  const ProductsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return ProductsPageState();
  }
}

class ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    widget.model.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
              automaticallyImplyLeading: false,
              title: Text('Choose'),
            ),
            ListTile(
                leading: Icon(Icons.edit),
                title: Text('Manage products'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/admin');
                })
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('EasyList'),
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: Icon(model.showFavorites
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () {
                  model.toogleDisplayMode();
                },
              );
            },
          )
        ],
      ),
      body: RefreshIndicator(
          child: Products(),
          onRefresh: () {
            return widget.model.fetchProducts();
          }),
    );
  }
}
