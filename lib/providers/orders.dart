import '../providers/cart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final List<CartItems> products;
  final double price;
  final DateTime dateTime;

  OrderItem({
    this.id,
    this.products,
    this.price,
    this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String authToken;
  final String userID;
  Orders(this.authToken, this.userID, this._orders);
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrder() async {
    final url =
        'https://flutter-update-ff233-default-rtdb.firebaseio.com/orders/$userID.json?auth=$authToken';
    final response = await http.get(url);
    // print(json.decode(response.body));
    List<OrderItem> loadedOrders = [];
    var extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach(
      (orderID, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderID,
            dateTime: DateTime.parse(
              orderData['dateTime'],
            ),
            price: orderData['price'],
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (cartItems) => CartItems(
                    id: cartItems['id'],
                    price: cartItems['price'],
                    title: cartItems['title'],
                    quantity: cartItems['quantity'],
                  ),
                )
                .toList(),
          ),
        );
      },
    );
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItems> cartProducts, double total) async {
    final url =
        'https://flutter-update-ff233-default-rtdb.firebaseio.com/orders/$userID.json?auth=$authToken';
    final timeStamp = DateTime.now();

    final response = await http.post(
      url,
      body: json.encode(
        {
          'price': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map(
                (prod) => {
                  'id': prod.id,
                  'title': prod.title,
                  'price': prod.price,
                  'quantity': prod.quantity
                },
              )
              .toList(),
        },
      ),
    );

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        products: cartProducts,
        price: total,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }
}
