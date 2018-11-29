import 'package:flutter/material.dart';

import './products.dart';
import './product_list.dart';
import './product_edit.dart';
import '../scoped_models/main.dart';
import '../widgets/logout_list_tile.dart';

class ProductsAdminPage extends StatelessWidget {

  final MainModel model;

  ProductsAdminPage(this.model);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              AppBar(
                automaticallyImplyLeading: false,
                title: Text('Choose'),
              ),
              ListTile(
                leading: Icon(Icons.shop),
                title: Text('All products'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/products');
                },
              ),
              Divider(),
              LogoutListTile(),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text('Manage products'),
          bottom: TabBar(tabs: <Widget>[
            Tab(text: "Create Product", icon: Icon(Icons.create),),
            Tab(text: "My products", icon: Icon(Icons.list),)
          ]),
        ),
        body: TabBarView(children: <Widget>[
          ProductEditPage(),
          ProductListPage(model)
        ]),
      ),
    );
  }
}
