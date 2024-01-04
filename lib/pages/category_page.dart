import 'package:flutter/material.dart';
import 'package:stockpilot/data/database.dart';
import 'package:stockpilot/data/login_system.dart';
import 'package:stockpilot/utils/item_component.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  Widget buildWithData(
      BuildContext context, AsyncSnapshot<Map<dynamic, dynamic>> snapshot) {
    void logout(context) {
      LoginSystem().logout();
      Navigator.of(context).pop();
      Navigator.of(context).popAndPushNamed('/login');
    }

    Future<void> createItem(context, id) async {
      final TextEditingController nameController = TextEditingController();
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Ajouter un élément"),
                content: TextField(
                  maxLength: 15,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Nom de l'élément"),
                  autofocus: true,
                  controller: nameController,
                ),
                actions: [
                  ActionChip(
                    label: Text("Annuler"),
                    onPressed: () {
                      nameController.text = '';
                      Navigator.of(context).pop();
                    },
                  ),
                  ActionChip(
                      label: Text("Créer"),
                      onPressed: () async {
                        await DataBase().createItem(nameController.text, id);
                        nameController.text = '';
                        Navigator.of(context).pop();
                        setState(() {});
                      })
                ],
              ));
    }

    if (snapshot.connectionState == ConnectionState.done) {
      print(snapshot.data);
      if (snapshot.data == null) {
        return Scaffold(
            appBar: AppBar(
              title: const Text("StockPilot"),
              actions: [
                IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      logout(context);
                    })
              ],
            ),
            body: Center(
                child: Column(
              children: [
                Text("Vérifiez votre connexion et réessayez.",
                    style: TextStyle(color: Colors.red)),
                IconButton(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: Icon(Icons.autorenew))
              ],
            )));
      }

      if (snapshot.data!["name"] != null) {
        String categoryName = snapshot.data!["name"];
        List items = snapshot.data!["items"];
        int nbItems = snapshot.data!["itemCount"];
        int id = snapshot.data!["id"];

        return Scaffold(
          appBar: AppBar(
            title: Text(categoryName),
          ),
          body: ListView.builder(
            itemCount: nbItems + 1,
            itemBuilder: (context, index) => index == nbItems
                ? Row(
                    children: [
                      Expanded(
                          child: IconButton(
                              onPressed: () =>
                                  createItem(context, id),
                              icon: Icon(Icons.add)))
                    ],
                  )
                : ItemElement(item: items[index], categoryId: id,)
          ),
        );
      }
    } else if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("StockPilot"),
          actions: [
            IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  logout(context);
                })
          ],
        ),
        body: Center(
            child: Column(
          children: [
            Text("Une erreur est survenue",
                style: TextStyle(color: Colors.red)),
            IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: Icon(Icons.autorenew))
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
    DataBase db = DataBase();
    int id = int.parse(ModalRoute.of(context)!.settings.arguments as String);
    return FutureBuilder(
        future: () async {
          var res = await db.getItemsOfCategory(id);
          res["id"] = id;
          return res;
        }(),
        builder: buildWithData);
  }
}
