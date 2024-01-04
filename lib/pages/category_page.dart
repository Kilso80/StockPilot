import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    print(ModalRoute.of(context)!.settings.arguments);
    int id = int.parse(ModalRoute.of(context)!.settings.arguments as String);
    String categoryName = "Câbles";
    List<List> items = [
      [0, "cable HDMI 1m"],
      [0, "cable HDMI 2m"],
      [0, "cable HDMI 5m"],
      [0, "cable HDMI 10m"],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: ListView.builder(
        itemCount: items.length + 1,
        itemBuilder: (context, index) => index == items.length? Row(children: [Expanded(child: IconButton(onPressed: () {}, icon: Icon(Icons.add)))],) : Row(
          children: [
            IconButton(
              icon: Icon(Icons.exposure_minus_1),
              onPressed: () {},
            ),
            Expanded(child: Text(items[index][1])),
            IconButton(icon: Icon(Icons.add), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
