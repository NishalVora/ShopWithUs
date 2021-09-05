import 'package:flutter/material.dart';
import '../providers/orders.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class OrderItems extends StatefulWidget {
  final OrderItem orderData;
  OrderItems(this.orderData);

  @override
  _OrderItemsState createState() => _OrderItemsState();
}

class _OrderItemsState extends State<OrderItems> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
      height: _expanded
                ? min(widget.orderData.products.length * 10.0 + 200, 100)
                : 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              title: Text('Total:Rs.${widget.orderData.price}'),
              subtitle: Text(
                  'Order placed on : ${DateFormat('dd/MM/yyyy,hh:mm').format(widget.orderData.dateTime)}'),
              trailing: IconButton(
                icon: _expanded
                    ? Icon(Icons.expand_less)
                    : Icon(Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeIn,
              alignment: Alignment.center,
              padding: EdgeInsets.all(10),
              // margin: EdgeInsets.all(10),
              height: _expanded
                  ? min(widget.orderData.products.length * 10.0 + 100, 100)
                  : 0,
              child: ListView(
                  children: widget.orderData.products
                      .map(
                        (prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              prod.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${prod.quantity}x Rs.${prod.price}',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      )
                      .toList()),
            ),
          ],
        ),
      ),
    );
  }
}
