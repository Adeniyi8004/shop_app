import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widget/order_item.dart';
import '../widget/app_drawer.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/orders';
  const OrderScreen(
      {super.key}); //init state and didchangedependencies can only be used in a stateful widget
  // var _isLoading = false;
  // var _isLoading = false;
  // @override
  // void initState() {
  //   // Future.delayed(Duration.zero).then((_) async {
  //   //   setState(() {
  //   //     _isLoading = true;            //now if in you provider is with listen false u do not need the Future.delayed or an async function i.e no await before the provider and any code i want to run after the provider is complete should be wrapped in a then()
  //   //   });
  //   //   await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  //   //   setState(() {
  //   //     _isLoading = false;
  //   //   });
  //   // });
  //   // super.initState();
  // }
  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context); in the alternate method if the provider is declared in this position it would for an infinite loop and the solution is shown below
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Orders'),
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
            future:
                Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
            builder: (context, snapShot) {
              if (snapShot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.amber,
                  ),
                );
              } else if (snapShot.error != null) {
                return const Center(
                  child: Text('An error as occured please add an Order'),
                );
              } else {
                return Consumer<Orders>(
                  builder: (context, orderData, child) => ListView.builder(
                    //this is the solution u add a cusumer to the part that need the provider so the build widget is not in an infinit loop
                    scrollDirection: Axis
                        .vertical, //this is an alternative way of doing this instead
                    shrinkWrap: true,
                    itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                    itemCount: orderData.orders.length,
                  ),
                );
              }
            }

            // },) _isLoading
            //     ? Center(
            //         child: CircularProgressIndicator(
            //           color: Colors.amber,
            //         ),
            //       )
            //     : ListView.builder(
            //         scrollDirection: Axis.vertical,
            //         shrinkWrap: true,
            //         itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
            //         itemCount: orderData.orders.length,
            //       ),
            ));
  }
}
