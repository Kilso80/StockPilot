import 'package:flutter/material.dart';

class ItemsList extends StatefulWidget {
  Map alerts;
  Function idToCategoryName;
  ItemsList({required this.alerts, required this.idToCategoryName, super.key});

  @override
  State<ItemsList> createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {
  String filter = '';

  @override
  Widget build(BuildContext context) {
    List alerts = List.from(widget.alerts["items"].where((item) =>
        item["name"].toLowerCase().contains(filter.toLowerCase()) == true));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              filter = value;
            });
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.search)
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) => ListTile(
              textColor: alerts[index]['underThreshold'] == "1"
                  ? Colors.red
                  : null, // Si l'item est en dessous du seuil d'alerte, on l'affiche en rouge
              title: Text(alerts[index]["name"]),
              subtitle:
                  Text(widget.idToCategoryName(alerts[index]["category"])),
              trailing: Text(alerts[index]["threshold"] != null
                  ? "${alerts[index]["stock"]}/${alerts[index]["threshold"]}"
                  : "${alerts[index]["stock"]} en stock"), // Pas besoin de gérer les cas où le seuil n'est pas défini, puisque seuls les items avec un seuil sont retournés par la requête
              onTap: () {
                Navigator.of(context)
                    .pushNamed("/category",
                        arguments: alerts[index]["category"])
                    .then((_) => setState(
                        () {})); // CE SETSTATE EST IMPORTANT. Il est appelé lorsque la page catégorie ouverte par clic sur un item est fermée, sans lui les informations de la page ne seraient pas mises à jour avec les possibles modifications effectuées
              },
            ),
            itemCount: alerts.length,
          ),
        ),
      ],
    );
  }
}
