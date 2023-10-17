import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'dart:math';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  const OrderItem(this.order, {super.key});

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height:
          _expanded ? min(widget.order.products.length * 20.00 + 110, 200) : 95,
      child: Card(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: [
              ListTile(
                title: Text('\$${widget.order.amount}'),
                subtitle: Text(DateFormat('dd/MM/yyyy hh:mm')
                    .format(widget.order.dateTime)),
                trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        _expanded = !_expanded;
                      });
                    },
                    icon: Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more)),
              ),
              AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  height: _expanded
                      ? min(widget.order.products.length * 20.00, 180)
                      : 0, //this is telling us that each item in the products would have an height of 20 untill it surpases 180 then they would have an height of 180
                  child: ListView.builder(
                    itemBuilder: (ctx, index) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.order.products[index].title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.order.products[index].quantity}x \$${widget.order.products[index].price}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    itemCount: widget.order.products.length,
                  )),
            ],
          )),
    );
  }
}
