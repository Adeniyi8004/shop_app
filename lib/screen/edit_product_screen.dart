import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product-screen';

  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionNode = FocusNode();
  final _imageController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: '',
    imageUrl: '',
    description: '',
    price: 0,
  );
  var _initValues = {
    'tittle': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String?;
      if (productId != null) {
        final product = Provider.of<ProductProvider>(context, listen: false)
            .findById(productId);
        _editedProduct = product;
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
        };
        _imageController.text = _editedProduct.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode
        .dispose(); //this is necesary because the focusnode need to be disposed of if not it would still remain after it use which can later affect the code
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _descriptionNode.dispose();
    _imageController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageController.text.startsWith('http') &&
              !_imageController.text.startsWith('https')) ||
          (!_imageController.text.endsWith('.png') &&
              !_imageController.text.endsWith('.jpg') &&
              !_imageController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      await Provider.of<ProductProvider>(context, listen: false)
          .updateProduct(_editedProduct.id!, _editedProduct);
    } else {
      try {
        await Provider.of<ProductProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog(
          //note when using await showdialog does not have null in front of it
          context: context,
          builder: (context) {
            return AlertDialog(
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'))
              ],
              content: const Text('Something went wrong'),
              title: const Text('An error as occured'),
            );
          },
        );
      }
      // finally {
      //   setState(() {
      //     // this is basically telling us that when .addproduct is done running then he should run the .then()
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }

      // this is using the future method
      //  Provider.of<ProductProvider>(context, listen: false)
      //     .addProduct(_editedProduct)
      //     .catchError((error) {
      //   //the catch error return a future so the .then() function can run and since show dialog returns a future so depending on what the showdialog brings .then() would run
      //   return showDialog<Null>(
      //     context: context,
      //     builder: (context) {
      //       return AlertDialog(
      //         actions: [
      //           TextButton(
      //               onPressed: () {
      //                 Navigator.of(context).pop();
      //               },
      //               child: const Text('Close'))
      //         ],
      //         content: const Text('Something went wrong'),
      //         title: const Text('An error as occured'),
      //       );
      //     },
      //   );
      // }).then((_) {
      //   setState(() {
      //     // this is basically telling us that when .addproduct is done running then he should run the .then()
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // });
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Product'),
          actions: [
            TextButton.icon(
                onPressed: _saveForm,
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                )),
          ],
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Colors.amber,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    key: _form,
                    child: ListView(
                      //in case of an app that should work in landscape instead of using listview it would be better that we use column and singlechildscrollview
                      children: [
                        TextFormField(
                          initialValue: _initValues['title'],
                          decoration: const InputDecoration(
                            labelText: 'Title',
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                title: value!,
                                imageUrl: _editedProduct.imageUrl,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                isFavourite: _editedProduct.isFavourite);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a value';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['price'],
                          decoration: const InputDecoration(
                            labelText: 'Price',
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          focusNode: _priceFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_descriptionNode);
                          },
                          onSaved: (value) {
                            _editedProduct = Product(
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              imageUrl: _editedProduct.imageUrl,
                              description: _editedProduct.description,
                              price: double.parse(value!),
                              isFavourite: _editedProduct.isFavourite,
                            );
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a value';
                            }
                            if (double.tryParse(value!) == null) {
                              return 'Please enter a valid number.';
                            }
                            if (double.parse(value!) <= 0) {
                              return 'Please enter a number greater than zero.';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          initialValue: _initValues['description'],
                          decoration: const InputDecoration(
                            labelText: 'Description',
                          ),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          focusNode: _descriptionNode,
                          onSaved: (value) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                imageUrl: _editedProduct.imageUrl,
                                description: value!,
                                price: _editedProduct.price,
                                isFavourite: _editedProduct.isFavourite);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide a value.';
                            }
                            if (value!.length < 10) {
                              return 'Should be at least 10 characters long.';
                            }
                            return null;
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(
                                top: 8,
                                right: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                  color: Colors.grey,
                                ),
                              ),
                              child: _imageController.text.isEmpty
                                  ? const Text('Enter a URL')
                                  : FittedBox(
                                      fit: BoxFit.cover,
                                      child:
                                          Image.network(_imageController.text),
                                    ),
                            ),
                            Expanded(
                              child: TextFormField(
                                // initialValue: _initValues['imageUrl'],
                                decoration: const InputDecoration(
                                    labelText: 'Image URL'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller: _imageController,
                                focusNode: _imageUrlFocusNode,
                                onFieldSubmitted: (_) => _saveForm(),
                                onSaved: (value) {
                                  _editedProduct = Product(
                                      id: _editedProduct.id,
                                      title: _editedProduct.title,
                                      imageUrl: value!,
                                      description: _editedProduct.description,
                                      price: _editedProduct.price,
                                      isFavourite: _editedProduct.isFavourite);
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter an image URL.';
                                  }
                                  if (!value.startsWith('http') &&
                                      !value.startsWith('https')) {
                                    return 'Please enter a valid URL. ';
                                  }
                                  if (!value.endsWith('.png') &&
                                      !value.endsWith('.jpg') &&
                                      !value.endsWith('.jpeg')) {
                                    return 'Please enter a valid image URL. ';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                    )),
              ));
  }
}
