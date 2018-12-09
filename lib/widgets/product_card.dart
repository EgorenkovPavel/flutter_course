import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './price_tag.dart';
import './title_default.dart';
import './address_tag.dart';
import '../scoped_models/main.dart';

class ProductCard extends StatelessWidget {
  final int productIndex;

  ProductCard(this.productIndex);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget widget, MainModel model) {
      return Card(
        child: Column(
          children: <Widget>[
            Hero(
              tag: model.allProducts[productIndex].id,
              child: FadeInImage(
                placeholder: AssetImage('assets/background.jpg'),
                image: NetworkImage(model.allProducts[productIndex].image),
                height: 300.0,
                fit: BoxFit.cover,
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 10.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TitleDefault(model.allProducts[productIndex].title),
                      SizedBox(
                        width: 8.0,
                      ),
                      PriceTag(
                          model.allProducts[productIndex].price.toString()),
                    ])),
            AddressTag(model.allProducts[productIndex].location.address),
            Text(model.allProducts[productIndex].userEmail),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.info),
                  color: Colors.blue,
                  onPressed: () {
                    Navigator.pushNamed<String>(
                        context, '/products/' + model.allProducts[productIndex].id);
                  },
                ),
                IconButton(
                  icon: Icon(model.allProducts[productIndex].isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border),
                  color: Colors.red,
                  onPressed: () {
                    model.selectProduct(model.allProducts[productIndex].id);
                    model.toggleFavorite();
                  },
                )
              ],
            )
          ],
        ),
      );
    });
  }
}
