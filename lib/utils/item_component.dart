import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockpilot/data/database.dart';

class ItemElement extends StatefulWidget {
  Map? item;
  int categoryId;
  ItemElement({super.key, required this.item, required this.categoryId});

  @override
  State<ItemElement> createState() => _ItemElementState();
}

class _ItemElementState extends State<ItemElement> {
  @override
  Widget build(BuildContext context) {
    void editItem() {
      TextEditingController nameController =
          TextEditingController(text: widget.item!["name"]);
      TextEditingController stockController =
          TextEditingController(text: widget.item!["stock"].toString());
      TextEditingController thresholdController = TextEditingController(
          text: widget.item!["threshold"] == null
              ? ""
              : widget.item!["threshold"].toString());

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Modifier ou supprimer"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TODO
                    TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: "Nom*"),
                      maxLength: 15,
                      textInputAction: TextInputAction.next,
                      controller: nameController,
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: "Stock*"),
                      textInputAction: TextInputAction.next,
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: "Seuil"),
                      controller: thresholdController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
                actions: [
                  ActionChip(
                    backgroundColor: Colors.red,
                    label: Text("Supprimer"),
                    onPressed: () {
                      DataBase().deleteItem(widget.item!['id']);
                      Navigator.of(context).pop();
                      widget.item = null;
                      setState(() {});
                    },
                  ),
                  ActionChip(
                    label: Text("Enregistrer"),
                    onPressed: () {
                      // TODO
                      String name = nameController.text;
                      int stock = int.parse(stockController.text);
                      int? threshold = thresholdController.text == ""
                          ? null
                          : int.parse(thresholdController.text);
                      widget.item!['name'] = name;
                      widget.item!['stock'] = stock;
                      widget.item!['threshold'] = threshold;
                      DataBase().updateItem(
                          widget.item!['id'], name, stock, threshold);
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                  )
                ],
              ));
    }

    if (widget.item == null) {
      return const SizedBox(
        height: 0,
        width: 0,
      );
    }
    if (widget.item!["stock"].runtimeType == String) {
      widget.item!["stock"] = int.parse(widget.item!["stock"]);
    }
    if (widget.item!["threshold"].runtimeType == String) {
      widget.item!["threshold"] = int.parse(widget.item!["threshold"]);
    }
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.exposure_minus_1),
          onPressed: widget.item!["stock"] > 0
              ? () async {
                  widget.item!["stock"] -= 1;
                  DataBase().updateItem(
                      widget.item!["id"],
                      widget.item!["name"],
                      widget.item!["stock"],
                      widget.item!["threshold"]);
                  setState(() {});
                }
              : null,
        ),
        Expanded(child: Text(widget.item!["name"])),
        Text(widget.item!["threshold"] == null
            ? "${widget.item!["stock"]} en stock"
            : "${widget.item!["stock"]} / ${widget.item!["threshold"]}"),
        IconButton(onPressed: editItem, icon: Icon(Icons.more_vert)),
        IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              widget.item!["stock"] += 1;
              DataBase().updateItem(widget.item!["id"], widget.item!["name"],
                  widget.item!["stock"], widget.item!["threshold"]);
              setState(() {});
            }),
      ],
    );
  }
}
