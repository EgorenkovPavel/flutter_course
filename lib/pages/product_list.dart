import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './product_edit.dart';
import '../scoped_models/main.dart';

class ProductListPage extends StatefulWidget {

  final MainModel model;

  ProductListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return ProductListPageState();
  }

}

class ProductListPageState extends State<ProductListPage>{

  @override
  void initState() {
    widget.model.fetchProducts(onlyForUser: true);
    super.initState();
  }

  Widget _buildEditButton(BuildContext context, int index) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget widget, MainModel model){
        return IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              model.selectProduct(model.allProducts[index].id);
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (BuildContext context) {
                return Scaffold(
                    appBar: AppBar(
                      title: Text('Edit product'),
                    ),
                    body: ProductEditPage());
              }));
            });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget widget, MainModel model){
        return ListView.builder(
            itemCount: model.allProducts.length,
            itemBuilder: (BuildContext context, int index) {
              return Dismissible(
                key: Key(model.allProducts[index].title),
                onDismissed: (DismissDirection direction) {
                  if (direction == DismissDirection.endToStart)
                    model.selectProduct(model.allProducts[index].id);
                    model.deleteProduct();
                },
                background: Container(
                  color: Colors.red,
                ),
                child: Column(
                  children: <Widget>[
                    ListTile(
                        leading: CircleAvatar(
                            backgroundImage: NetworkImage(model.allProducts[index].image)),
                        title: Text(model.allProducts[index].title),
                        subtitle: Text('\$${model.allProducts[index].price}'),
                        trailing: _buildEditButton(context, index)),
                    Divider()
                  ],
                ),
              );
            });
      }
    );
  }

}
