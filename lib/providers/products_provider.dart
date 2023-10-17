import 'dart:convert';
import 'package:flutter/material.dart ';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'product.dart';
import '../models/http_exception.dart';

class ProductProvider with ChangeNotifier {
  //this is like inheritance but lower than it lets call it inheritance lite with mixin we can have many classes to add to it but with inheritance we can only inherit from one class
  // ignore: prefer_final_fields
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
  final String? authToken;
  final String? userId;
  ProductProvider(this.authToken, this.userId, this._items);
  // var _showFavouritesOnly = false;  this method filters the list globally and most app this is not required because the list may still be needed somewhere else so to do something like that we use a stateful widget

  List<Product> get items {
    // if (_showFavouritesOnly) {
    //   return _items.where((productItem) => productItem.isFavourite).toList();
    // }
    return [..._items];
  }

  List<Product> get favouriteItems {
    return _items
        .where((productItem) => productItem.isFavourite)
        .toList(); //this is to return where productItem.isFavourite is true
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavouritesOnly() {
  //   _showFavouritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavouritesOnly = false;
  //   notifyListeners();
  // }

  // Future<void> addProduct(Product product) {
  //   final url =
  //       Uri.https('shop-app-fbd22-default-rtdb.firebaseio.com', '/products.json');
  //   return http // so to make it work we return http because the addProduct function would need to return a future and that future is the future return by .then()
  //       .post(url, //async codes are codes that executes while other codes doesn't wait for it example is the http.post()
  //           body: json.encode({
  //             'title': product.title,
  //             'description': product.description,
  //             'imageUrl': product.imageUrl,
  //             'price': product.price,
  //             'isFavourite': product.isFavourite
  //           }))
  //       .then((response) {
  //     final newProduct = Product(
  //         id: json.decode(response.body)['name'],
  //         title: product.title,
  //         imageUrl: product.imageUrl,
  //         description: product.description,
  //         price: product.price);
  //     _items.add(newProduct);
  //     notifyListeners();
  //     // _items.insert(0, newProduct); this is used to add to the beginning of the list
  //   }).catchError((error) {
  //     throw error;
  //   });
  //   // return Future.value(); this would not work because flutter would run the http.post() and when it see then he would ignore the anonymous function and would have run the return Future.value() too early so this would not work
  // } an alternative method is to use async
  Future<void> addProduct(Product product) async {
    final url = Uri.https('shop-app-fbd22-default-rtdb.firebaseio.com',
        '/products.json', {'auth': '$authToken'});
    try {
      final response =
          await http // so to make it work we return http because the addProduct function would need to return a future and that future is the future return by .then()
              .post(
                  url, //async codes are codes that executes while other codes doesn't wait for it example is the http.post()
                  body: json.encode({
                    'title': product.title,
                    'description': product.description,
                    'imageUrl': product.imageUrl,
                    'price': product.price,
                    'creatorId': userId,
                  })); //when using async the code that would take time before completing would be wrapped in async then the remaining code can be written normally
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          imageUrl: product.imageUrl,
          description: product.description,
          price: product.price);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    var url = Uri.https(
      'shop-app-fbd22-default-rtdb.firebaseio.com',
      '/products.json',
      filterByUser
          ? {
              'auth': '$authToken',
              'orderBy': '"creatorId"',
              'equalTo': '"$userId"',
            }
          : {
              'auth': '$authToken',
            },
    );
    // The problem lay in the way I was defining the URL. The parameter format for the Uri.https constructor should be
    // Uri.https(String authority, String unencodedPath, [Map<String, dynamic>? queryParameters]). this is the format
    try {
      final response = await http.get(
        url,
      );
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProduct = [];
      // ignore: unnecessary_null_comparison
      if (extractedData == null) {
        return;
      }
      url = Uri.https('shop-app-fbd22-default-rtdb.firebaseio.com',
          '/userFavorites/$userId.json', {
        'auth': '$authToken',
      }); // thid id how u add a query parameter
      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);
      extractedData.forEach((prodId, prodData) {
        loadedProduct.add(Product(
            id: prodId,
            title: prodData['title'],
            imageUrl: prodData['imageUrl'],
            description: prodData['description'],
            isFavourite:
                favouriteData == null ? false : favouriteData[prodId] ?? false,
            price: prodData['price']));
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https('shop-app-fbd22-default-rtdb.firebaseio.com',
          '/products/$id.json', {'auth': '$authToken'});
      try {
        await http.patch(url,
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
            }));
      } catch (error) {
        throw error;
      } finally {
        _items[prodIndex] = newProduct;
        notifyListeners();
      }
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https('shop-app-fbd22-default-rtdb.firebaseio.com',
        '/products/$id.json', {'auth': '$authToken'});
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;

    // _items.removeWhere(
    //   (prod) => prod.id == id,
    // );

    notifyListeners();
  }
}
