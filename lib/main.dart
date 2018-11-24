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
  @override
  Widget build(BuildContext context) {
    MainModel model = MainModel();
    return ScopedModel<MainModel>(
      model: model,
      child: MaterialApp(
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.red,
            accentColor: Colors.teal),
//      home: AuthPage(),
        routes: {
          '/': (context) {
            return AuthPage();
          },
          '/products': (context) {
            return ProductsPage(model);
          },
          '/admin': (context) {
            return ProductsAdminPage(model);
          },
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split("/");
          if (pathElements[0] != '') return null;
          if (pathElements[1] == 'products') {
            final String productId = pathElements[2];
            model.selectProduct(productId);
            return MaterialPageRoute<String>(builder: (context) {
              return ProductPage();
            });
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(builder: (context) {
            return ProductsPage(model);
          });
        },
      ),
    );
  }
}
