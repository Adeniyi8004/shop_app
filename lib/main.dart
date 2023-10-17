import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:provider/provider.dart';

import './providers/cart.dart';
import './screen/products_overview_screen.dart'; //the pattern i am using is provider
import './screen/product_detail_screen.dart';
import './providers/products_provider.dart';
import './screen/cart_screen.dart';
import './providers/orders.dart';
import './screen/orders_screen.dart';
import './screen/user_product_screen.dart';
import './screen/edit_product_screen.dart';
import './screen/auth_screen.dart';
import './providers/auth.dart';
import './screen/splash_screen.dart';
import './helpers/custom_route.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, ProductProvider>(
            create: (ctx) => ProductProvider(null, null, []),
            update: (ctx, auth, previousProduct) => ProductProvider(
                auth.token,
                auth.userId,
                previousProduct == null ? [] : previousProduct.items),
          ),
          ChangeNotifierProvider(
            create: (context) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (context) => Orders(null, null, []),
            update: (ctx, auth, previousOrders) => Orders(
                auth.token,
                auth.userId,
                previousOrders == null ? [] : previousOrders.orders),
          ),
        ],
        child: Consumer<Auth>(
          builder: (context, auth, _) => MaterialApp(
              title: 'MyShop',
              theme: ThemeData(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.purple,
                    secondary: Colors.deepOrange,
                  ),
                  pageTransitionsTheme: PageTransitionsTheme(builders: {
                    TargetPlatform.android: CustomPageTransitionBuilder(),
                    TargetPlatform.iOS: CustomPageTransitionBuilder(),
                  })),
              home: auth.isAuth
                  ? const ProductOverviewScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (ctx, authResultSnapshot) =>
                          authResultSnapshot == ConnectionState.waiting
                              ? SplashScreen()
                              : const AuthScreen(),
                    ),
              //const ProductOverviewScreen(),
              routes: {
                ProductDetailScreen.routeName: (ctx) =>
                    const ProductDetailScreen(),
                CartScreen.routeName: (ctx) => const CartScreen(),
                OrderScreen.routeName: (ctx) => const OrderScreen(),
                UserProductScreen.routeName: (ctx) => const UserProductScreen(),
                EditProductScreen.routeName: (ctx) => const EditProductScreen(),
              }),
        ));
  }
}
