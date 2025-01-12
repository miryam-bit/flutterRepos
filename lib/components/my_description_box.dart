import 'package:flutter/material.dart';

class MyDescriptionBox extends StatelessWidget {
  const MyDescriptionBox({super.key});

  @override
  Widget build(BuildContext context) {
    var PrimaryTextStyle = TextStyle(
        color: Theme.of(context).colorScheme.inversePrimary, fontSize: 12);
    var SecondaryTextStyle =
        TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 14);

    return Container(
      padding: EdgeInsets.all(15.0),
      margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                "\$0.99",
                style: PrimaryTextStyle,
              ),
              Text("Delivery fee", style: SecondaryTextStyle)
            ],
          ),
          Column(
            children: [
              Text(
                "15-30 min",
                style: PrimaryTextStyle,
              ),
              Text("Delivery Time", style: SecondaryTextStyle)
            ],
          )
        ],
      ),
    );
  }
}
