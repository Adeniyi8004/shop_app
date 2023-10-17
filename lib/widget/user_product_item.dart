import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screen/edit_product_screen.dart';
import '../providers/products_provider.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItem(this.id, this.title, this.imageUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    final scafoldMessenger = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ), //when dealing with background image we use networkImage instead of imag.network, because background image takes an image provider not a widget like image.network, for image includede in the app w
      trailing: Container(
        width: 100,
        child: Row(children: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditProductScreen.routeName, arguments: id);
            },
            icon: const Icon(Icons.edit),
            color: Theme.of(context).colorScheme.primary,
          ),
          IconButton(
            onPressed: () async {
              try {
                await Provider.of<ProductProvider>(context, listen: false)
                    .deleteProduct(id);
              } catch (error) {
                scafoldMessenger.showSnackBar(
                  SnackBar(
                      content: Text(
                    'Deleting failed!',
                    textAlign: TextAlign.center,
                  )),
                );
              }
            },
            icon: const Icon(Icons.delete),
            color: Theme.of(context).colorScheme.error,
          ),
        ]),
      ),
    );
  }
}
