import 'package:flutter/material.dart';
import 'package:stockpilot/data/database.dart';
import 'package:stockpilot/data/login_system.dart';
import 'package:stockpilot/pages/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final db = DataBase();

  void logout(context) {
    LoginSystem().logout();
    Navigator.of(context).popAndPushNamed('/login');
  }

  void createCategory(context) {
    TextEditingController nameController = TextEditingController();

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("Créer une catégorie"),
              content: TextField(
                controller: nameController,
                maxLength: 15,
                autofocus: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Nom de la catégorie"),
              ),
              actions: [
                ActionChip.elevated(
                    onPressed: () async {
                      await db.createCategory(nameController.text);
                      nameController.text = "";
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    label: const Text("Créer")),
                ActionChip.elevated(
                    onPressed: () {
                      Navigator.of(context).pop();
                      nameController.text = "";
                    },
                    label: const Text("Annuler")),
              ],
            ));
  }

  void editCategory(context, id, name) {
    TextEditingController nameController = TextEditingController(text: name);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text("Modifier une catégorie"),
              content: TextField(
                autofocus: true,
                controller: nameController,
                maxLength: 15,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Nom de la catégorie"),
              ),
              actions: [
                ActionChip.elevated(
                    backgroundColor: Colors.red,
                    onPressed: () async {
                      await db.deleteCategory(id);
                      Navigator.of(context).pop();
                      nameController.text = "";
                      setState(() {});
                    },
                    label: const Text("Supprimer")),
                ActionChip.elevated(
                    onPressed: () async {
                      await db.renameCategory(id, nameController.text);
                      Navigator.of(context).pop();
                      nameController.text = "";
                      setState(() {});
                    },
                    label: const Text("Sauvegarder")),
                // ActionChip.elevated(
                //     onPressed: () {
                //       Navigator.of(context).pop();
                //       nameController.text = "";
                //     },
                //     label: Text("Annuler")),
              ],
            ));
  }

  Widget buildWithData(BuildContext context, AsyncSnapshot<dynamic> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      // print(snapshot.data);
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
                const Text("Vérifiez votre connexion et réessayez.",
                    style: TextStyle(color: Colors.red)),
                IconButton(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(Icons.autorenew))
              ],
            )));
      }
      Map categories = snapshot.data[0];
      Map alerts = snapshot.data[1];
      if (snapshot.data[0]["status"] == null &&
          snapshot.data[1]["status"] == 200) {
        String idToCategoryName(id) {
          for (var category in categories["categories"]) {
            if (category["id"] == id) return category["name"];
          }
          return "";
        }

        List<Widget> children = [
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, index) => ListTile(
              textColor: alerts["items"][index]['underThreshold'] == "1"
                  ? Colors.red
                  : null,
              title: Text(alerts["items"][index]["name"]),
              subtitle:
                  Text(idToCategoryName(alerts["items"][index]["category"])),
              trailing: Text(
                  "${alerts["items"][index]["stock"]}/${alerts["items"][index]["threshold"]}"),
              onTap: () {
                Navigator.of(context)
                    .pushNamed("/category",
                        arguments: alerts["items"][index]["category"])
                    .then((_) => setState(() {}));
              },
            ),
            itemCount: alerts["items"].length,
          )),
          Expanded(
            flex: 2,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250, childAspectRatio: 1.618),
              itemBuilder: (context, index) => categories["n"] == index
                  ? GestureDetector(
                      onTap: () {
                        createCategory(context);
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Theme.of(context).primaryColor)),
                              child: const Center(
                                  child: Icon(Icons.add_outlined)))))
                  : GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed("/category",
                                arguments: categories["categories"][index]
                                    ["id"])
                            .then((_) => setState(() {}));
                      },
                      onLongPress: () {
                        editCategory(
                            context,
                            categories["categories"][index]["id"],
                            categories["categories"][index]["name"]);
                      },
                      onSecondaryTap: () {
                        editCategory(
                            context,
                            categories["categories"][index]["id"],
                            categories["categories"][index]["name"]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Theme.of(context).primaryColor)),
                          child: Center(
                              child: Text(
                                  categories["categories"][index]["name"])),
                        ),
                      ),
                    ),
              itemCount: categories["n"] + 1,
            ),
          ),
        ];

        return Scaffold(
            appBar: AppBar(
              title: const Text("StockPilot"),
              actions: [
                IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/editProfile');
                    }),
                IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      logout(context);
                    })
              ],
            ),
            body: Container(
                child: MediaQuery.of(context).size.width >
                            MediaQuery.of(context).size.height ||
                        MediaQuery.of(context).size.width > 900
                    ? Row(children: children)
                    : Column(children: children)));
      } else if (categories["status"] == 401) {
        return const LoginPage();
      } else {
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
                const Text("Une erreur est survenue",
                    style: TextStyle(color: Colors.red)),
                IconButton(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(Icons.autorenew))
              ],
            )));
      }
    } else if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: db.getCategoriesAndAlerts(), builder: buildWithData);
  }
}
