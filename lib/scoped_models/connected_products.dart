import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';

import 'dart:convert';
import 'dart:async';

import '../models/product.dart';
import '../models/user.dart';
import '../models/auth.dart';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  User _authenticatedUser;
  String _selProductId;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void addProduct(String title, String description, String image,
      double price) {
    _isLoading = true;

    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image':
      'https://limnlcdn.akamaized.net/Assets/Images_Upload/2018/01/05/Chocolade.jpg?maxheight=460&maxwidth=629',
      'price': price
    };

    http
        .post('https://flutter-products-ddc20.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
        body: json.encode(productData))
        .then((http.Response response) {
      if (response.statusCode != 200) return;

      _isLoading = false;

      final Map<String, dynamic> value = json.decode(response.body);

      final newProduct = Product(
          id: value['name'],
          title: title,
          description: description,
          image: image,
          price: price,
          userId: _authenticatedUser.id,
          userEmail: _authenticatedUser.email);
      _products.add(newProduct);
      _selProductId = null;
    }).catchError((error) {

    });
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    return http
        .get('https://flutter-products-ddc20.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;

      final List<Product> fetchedProductList = [];

      final Map<String, dynamic> value = json.decode(response.body);

      if (value != null) {
        value.forEach((String key, dynamic data) {
          final Product product = Product(
              id: key,
              title: data['title'],
              description: data['description'],
              price: data['price'],
              image: data['image'],
              userId: _authenticatedUser.id,
              userEmail: _authenticatedUser.email);
          fetchedProductList.add(product);
        });
      }
      _products = fetchedProductList;
      notifyListeners();
    });
  }
}

class ProductsModel extends ConnectedProductsModel {
  bool _showFavorites = false;

  List<Product> get allProducts => List.from(_products);

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return List.from(_products.where((Product product) {
        return product.isFavorite;
      }));
    } else {
      return List.from(_products);
    }
  }

  bool get showFavorites => _showFavorites;

  String get selectedProductId => _selProductId;

  Product get selectedProduct {
    if (_selProductId == null) {
      return null;
    } else {
      return _products.firstWhere((Product product) {
        return product.id == _selProductId;
      });
    }
  }

  void toggleFavorite() {
    Product newProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userId: selectedProduct.userId,
        userEmail: selectedProduct.userEmail,
        isFavorite: !selectedProduct.isFavorite);

    final int selectProductIndex = _products.indexWhere((Product product) {
      return product.id == _selProductId;
    });

    _products[selectProductIndex] = newProduct;
    _selProductId = null;
    notifyListeners();
  }

  void updateProduct(String title, String description, String image,
      double price) {
    _isLoading = true;

    final Map<String, dynamic> updateProduct = {
      'title': title,
      'description': description,
      'price': price,
      'image':
      'https://limnlcdn.akamaized.net/Assets/Images_Upload/2018/01/05/Chocolade.jpg?maxheight=460&maxwidth=629'
    };

    http
        .put(
        'https://flutter-products-ddc20.firebaseio.com/products/${selectedProduct
            .id}.json?auth=${_authenticatedUser.token}',
        body: json.encode(updateProduct))
        .then((http.Response response) {
      _isLoading = false;

      final updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          image: image,
          price: price,
          userId: _authenticatedUser.id,
          userEmail: _authenticatedUser.email);
      final int selectProductIndex = _products.indexWhere((Product product) {
        return product.id == _selProductId;
      });

      _products[selectProductIndex] = updatedProduct;
      _selProductId = null;
      notifyListeners();
    });
  }

  void deleteProduct() {
    _isLoading = true;

    http.delete(
        'https://flutter-products-ddc20.firebaseio.com/products/${selectedProduct
            .id}.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;

      final int selectProductIndex = _products.indexWhere((Product product) {
        return product.id == _selProductId;
      });

      _products.removeAt(selectProductIndex);
      _selProductId = null;
      notifyListeners();
    });
  }

  void selectProduct(String productId) {
    _selProductId = productId;
  }

  void toogleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

class UserModel extends ConnectedProductsModel {

  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  PublishSubject<bool> get userSubject => _userSubject;

  User get authenticatedUser => _authenticatedUser;

  Future<Map<String, dynamic>> authenticate(String email, String password, AuthMode authMode) async {

    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true
    };

    http.Response response;
    if(authMode == AuthMode.LOGIN)
      response = await http.post('https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyByXcMJao6wu5GSCCF1JT_jFPjK9RG3RKQ',
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'});
    else
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyByXcMJao6wu5GSCCF1JT_jFPjK9RG3RKQ',
          body: json.encode(authData),
          headers: {'Content-Type': 'application/json'});

    Map<String, dynamic> resp = json.decode(response.body);

    bool hasError = response.statusCode != 200;
    String message = '';
    if(!hasError){
      message = 'Authenticated succass!';
    }else if(resp['error']['message'] == 'EMAIL_EXISTS'){
      message = 'This email already exists';
    }else if(resp['error']['message'] == 'EMAIL_NOT_FOUND'){
      message = 'This email not found';
    }else if(resp['error']['message'] == 'INVALID_PASSWORD'){
      message = 'Invalid password';
    }else{
      message = 'Somethink went wrong';
    }

    if(!hasError) {
      _authenticatedUser =
          User(id: resp['localId'], email: email, token: resp['idToken']);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', _authenticatedUser.token);
      prefs.setString('userEmail', _authenticatedUser.email);
      prefs.setString('userId', _authenticatedUser.id);

      final int time = int.parse(resp['expiresIn']);

      setAuthTimeout(time);
      _userSubject.add(true);

      final DateTime now = DateTime.now();
      final DateTime expiredTime = now.add(Duration(seconds: time));

      prefs.setString('expiredTime', expiredTime.toIso8601String());
    }

    _isLoading = false;
    notifyListeners();

    return {'success': !hasError, 'message': message};
  }

  void autoAthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');
    final String expiredTimeString = prefs.getString('expiredTime');
    if(token != null){
      final DateTime now = DateTime.now();
      final DateTime expiredTime = DateTime.parse(expiredTimeString);
      if(expiredTime.isBefore(now)){
        _authenticatedUser = null;
        notifyListeners();
        return;
      };

      final String userEmail = prefs.getString('userEmail');
      final String userId = prefs.getString('userId');
      _authenticatedUser = User(id: userId, email: userEmail, token: token);

      final int tokenLife = expiredTime.difference(now).inSeconds;
      setAuthTimeout(tokenLife);
      _userSubject.add(true);
      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
    notifyListeners();
  }

  void setAuthTimeout(int time){
    _authTimer = Timer(Duration(seconds: time), (){
      logout();
    });
  }

}
