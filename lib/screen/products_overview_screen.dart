import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products_provider.dart';

import '../widget/app_drawer.dart';
import '../widget/badge.dart';
import '../widget/product_grid.dart';
import '../screen/cart_screen.dart';

enum FilterOptions {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  const ProductOverviewScreen({super.key});

  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showFavouritesOnly = false;
  var _isinit = true;
  var _isLoading = false;
  @override
  void initState() {
    // Provider.of<ProductProvider>(context).fetchAndSetProducts(); this would not work because of initState does not have access to context
    //this is the perfect way to call data because it only runs once and because we want to make our code as small as possible we add the http.get in the productsprovider
    // Future.delayed(Duration.zero).then(
    //     (value) => Provider.of<ProductProvider>(context).fetchAndSetProducts()); this is a solution to initstate not having a context but it more like an hack or cheat method so alternatively u can use didchangedependency
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isinit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductProvider>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isinit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ImmAde'),
        actions: [
          PopupMenuButton(
              onSelected: (FilterOptions selectedValue) {
                setState(() {
                  if (selectedValue == FilterOptions.Favorites) {
                    _showFavouritesOnly = true;
                  } else {
                    _showFavouritesOnly = false;
                  }
                });
              },
              icon: const Icon(Icons.more_vert),
              itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: FilterOptions.Favorites,
                        child: Text('Only Favorites')),
                    const PopupMenuItem(
                        value: FilterOptions.All, child: Text('Show All')),
                  ]),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badges(
                value: cart.itemCount
                    .toString(), // the cart item only counts when an items as not been selected before
                color: Theme.of(context).colorScheme.secondary,
                child: ch!),
            child: IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
                icon: const Icon(Icons.shopping_cart)),
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            )
          : ProductGrid(_showFavouritesOnly),
    );
  }
}
