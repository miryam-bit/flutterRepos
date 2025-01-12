import 'package:delivery_app/pages/cart_page.dart';
import 'package:flutter/material.dart';

class MySliverAppBar extends StatelessWidget {
  final Widget child;
  final Widget title;
  const MySliverAppBar({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
        expandedHeight: 275,
        collapsedHeight: 120,
        floating: false,
        pinned: false,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(),
                ),
              );
            },
          )
        ],
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(
          child: Text(
            'BQA Restaurant',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        flexibleSpace: FlexibleSpaceBar(
          background: Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: child,
          ),
          title: title,
          centerTitle: true,
          titlePadding: EdgeInsets.only(left: 0, right: 0, top: 0),
          expandedTitleScale: 1,
        ));
  }
}
