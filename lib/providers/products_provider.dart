import 'dart:convert';

import 'package:Shop_App/models/http_exception.dart';
import 'package:flutter/material.dart';
import './product.dart';
import 'package:http/http.dart' as http;

class ProductsProvider with ChangeNotifier {
  String authToken;
  String userID;
  ProductsProvider(this.authToken, this.userID, this._items);
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly)
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    return [..._items];
  }

  // void showFavorites() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findByID(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
final filterString = filterByUser ? 'orderBy="creatorID"&equalTo="$userID"': '';
    var url =
        'https://flutter-update-ff233-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';
  //  var url =
  //       'https://flutter-update-ff233-default-rtdb.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.get(url);
      // print(json.decode(response.body));

      var extractedResponse =
          json.decode(response.body) as Map<String, dynamic>;

      if (extractedResponse == null) {
        return;
      }

      url =
          'https://flutter-update-ff233-default-rtdb.firebaseio.com/user-favorites/$userID.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      List<Product> loadedProducts = [];
      extractedResponse.forEach(
        (prodID, prodItem) {
          loadedProducts.add(
            Product(
              id: prodID,
              title: prodItem['title'],
              description: prodItem['description'],
              price: prodItem['price'],
              isFavorite:
                  favoriteData == null ? false : favoriteData[prodID] ?? false,
              imageUrl: prodItem['imageUrl'],
            ),
          );
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://flutter-update-ff233-default-rtdb.firebaseio.com/products.json?auth=$authToken';

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorID': userID,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'],
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> editProduct(String id, Product newProduct) async {
    final url =
        'https://flutter-update-ff233-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    await http.patch(
      url,
      body: json.encode(
        {
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        },
      ),
    );
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    _items[productIndex] = newProduct;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://flutter-update-ff233-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    // _items.removeWhere((prod) => prod.id == id);
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product..');
    }
    existingProduct = null;
  }
}
