import 'package:flutter/material.dart';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/title_default.dart';
import '../widgets/address_tag.dart';
import '../scoped_models/main.dart';
import '../widgets/product_fab.dart';

class ProductPage extends StatelessWidget {

  _showDeleteDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('This action cannot be undone!'),
            actions: <Widget>[
              FlatButton(
                child: Text('DISCART'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('CONTINUE'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, 'delete');
                },
              )
            ],
          );
        });
  }

  void _showMap(){
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: ScopedModelDescendant<MainModel>(builder: (BuildContext context, Widget widget, MainModel model){
        return Scaffold(
          appBar: AppBar(
            title: Text(model.selectedProduct.title),
          ),
          body: Column(
            children: <Widget>[
              Image.network(model.selectedProduct.image),
              TitleDefault(model.selectedProduct.title),
              GestureDetector(child: AddressTag(model.selectedProduct.location.address),
              onTap: (){
                _showMap();
              },),
              Text(
                '\$${model.selectedProduct.price}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26.0),
              ),
              Text(
                model.selectedProduct.description,
              ),

              RaisedButton(
                child: Text('DELETE'),
                onPressed: () {
                  _showDeleteDialog(context);
                },
              )
            ],
          ),
          floatingActionButton: ProductFab(),
        );
      }),
      onWillPop: () {
        Navigator.pop(context, '');
        return Future.value(false);
      },
    );
  }
}
