import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart';
import '../widgets/order_items.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders-screen';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;
  Future ordersFutureObtained() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrder();
  }

  @override
  void initState() {
    _ordersFuture = ordersFutureObtained();
    // TODO: implement initState
    super.initState();
  }
  // @override
  // void initState() {
  //   Future.delayed(Duration.zero).then(
  //     (_) async {
  //       setState(() {
  //         isLoading = true;
  //       });
  //       await Provider.of<Orders>(context, listen: false).fetchAndSetOrder();
  //       setState(() {
  //         isLoading = false;
  //       });
  //     },
  //   );
  //   // TODO: implement initState
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _ordersFuture,
          builder: (ctx, dataSnapShot) {
            if (dataSnapShot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapShot.error != null) {
                return Center(
                  child: Text('an Unknown error occured!'),
                );
              } else {
                return Consumer<Orders>(
                  builder: (ctx, orderData, child) {
                    return ListView.builder(
                      itemBuilder: (ctx, index) {
                        return OrderItems(orderData.orders[index]);
                      },
                      itemCount: orderData.orders.length,
                    );
                  },
                );
              }
            }
          },
        )
        // body: isLoading
        //     ? Center(
        //         child: CircularProgressIndicator(),
        //       )
        //     : ListView.builder(
        //         itemBuilder: (ctx, index) {
        //           return OrderItems(orderData.orders[index]);
        //         },
        //         itemCount: orderData.orders.length,
        //       ),
        );
  }
}
