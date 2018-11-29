import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './pages/auth.dart';
import './pages/products_admin.dart';
import './pages/products.dart';
import './pages/product.dart';

import './scoped_models/main.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {

  MainModel _model = MainModel();

  @override
  void initState() {
    _model.autoAthenticate();
    

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.red,
            accentColor: Colors.teal),
//      home: AuthPage(),
        routes: {
          '/': (context) {
            return ScopedModelDescendant(builder: (BuildContext context, Widget child, MainModel model){
              return model.authenticatedUser == null ? AuthPage() : ProductsPage(_model);
            });
          },
          '/products': (context) {
            return ProductsPage(_model);
          },
          '/admin': (context) {
            return ProductsAdminPage(_model);
          },
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split("/");
          if (pathElements[0] != '') return null;
          if (pathElements[1] == 'products') {
            final String productId = pathElements[2];
            _model.selectProduct(productId);
            return MaterialPageRoute<String>(builder: (context) {
              return ProductPage();
            });
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(builder: (context) {
            return ProductsPage(_model);
          });
        },
      ),
    );
  }

}
