import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

import './product_item.dart';
import '../providers/products_provider.dart';

class ProductGrid extends StatelessWidget {
  final bool showFavs;
  const ProductGrid(this.showFavs, {super.key});

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    final product = showFavs ? productData.favouriteItems : productData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        //we use the ChangeNotifierProvider.value for data that is repeated. they are mostly used for list and grids
        //the way the changeNotifierProvider.value works is that the value e.g product[index] is supplied to other nested widgets so productItem is built by the builder and the changeNotifierValue acts as the counter for the list
        value: product[index], //this is what makes it count
        child: const ProductItem(),
      ),
      itemCount: product.length,
    );
  }
}
