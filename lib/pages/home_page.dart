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
    // Déconnecte et remplace la page actuelle par la page de login
    LoginSystem().logout();
    Navigator.of(context).popAndPushNamed('/login');
  }

  void createCategory(context) {
    // Affiche une popup permettant de créer une catégorie 
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
                ActionChip(
                    onPressed: () async {
                      await db.createCategory(nameController.text);
                      nameController.text = "";
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    label: const Text("Créer")),
                ActionChip(
                    onPressed: () {
                      Navigator.of(context).pop();
                      nameController.text = "";
                    },
                    label: const Text("Annuler")),
              ],
            ));
  }

  void editCategory(context, id, name) {
    // Affiche une popup permettant de renommer ou de supprimer une catégorie 
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
                ActionChip(
                    backgroundColor: Colors.red,
                    onPressed: () async {
                      await db.deleteCategory(id);
                      Navigator.of(context).pop();
                      nameController.text = "";
                      setState(() {}); // Reload la page (sans la catégorie supprimée)
                    },
                    label: const Text("Supprimer")),
                ActionChip(
                    onPressed: () async {
                      await db.renameCategory(id, nameController.text);
                      Navigator.of(context).pop();
                      nameController.text = "";
                      setState(() {}); // Juste reload la page principale pour afficher le nouveau nom de la catégorie 
                    },
                    label: const Text("Sauvegarder")),
                // Ce bouton est désactivé pour éviter la surcharge visuelle. On obtient le même résultat en cliquant en dehors de la popup, donc il n'est pas indispensable et j'ai donc décidé de ne pas le garder
                // ActionChip(
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
      // La requête est terminée 
      // print(snapshot.data);
      if (snapshot.data == null) {
        // Aucun résultat n'a été récupéré de la requête. Cela arrive quand l'utilisateur n'a pas de connexion 
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
      // Des données ont bien été récupérées
      Map categories = snapshot.data[0];
      Map alerts = snapshot.data[1];
      if (snapshot.data[0]["status"] == null &&
          snapshot.data[1]["status"] == 200) {
        // La requête a abouti avec succès et les informations ont bien été obtenues, on les affiche donc
        String idToCategoryName(id) {
          for (var category in categories["categories"]) {
            if (category["id"] == id) return category["name"];
          }
          return "";
        }

        // Cette liste est la liste des items sur la gauche de l'écran, triée par proximité au seuil d'alerte ainsi que la liste des catégories sur la droite 
        List<Widget> children = [
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, index) => ListTile(
              textColor: alerts["items"][index]['underThreshold'] == "1"
                  ? Colors.red
                  : null, // Si l'item est en dessous du seuil d'alerte, on l'affiche en rouge
              title: Text(alerts["items"][index]["name"]),
              subtitle:
                  Text(idToCategoryName(alerts["items"][index]["category"])),
              trailing: Text(
                  "${alerts["items"][index]["stock"]}/${alerts["items"][index]["threshold"]}"), // Pas besoin de gérer les cas où le seuil n'est pas défini, puisque seuls les items avec un seuil sont retournés par la requête 
              onTap: () {
                Navigator.of(context)
                    .pushNamed("/category",
                        arguments: alerts["items"][index]["category"])
                    .then((_) => setState(() {})); // CE SETSTATE EST IMPORTANT. Il est appelé lorsque la page catégorie ouverte par clic sur un item est fermée, sans lui les informations de la page ne seraient pas mises à jour avec les possibles modifications effectuées 
              },
            ),
            itemCount: alerts["items"].length,
          )),
          Expanded(
            flex: 2,// Pour que la liste des catégories prenne deux tiers de la place, et que les items n'en prennent qu'un seul 
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250, childAspectRatio: 1.618), // Golden ratio parce que j'avais pas d'idée et que ça s'approchait de ce que je voulais
              itemBuilder: (context, index) => categories["n"] == index // On vérifie ça car le dernier élément ne doit pas être une catégorie mais le bouton pour en créér une nouvelle 
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
                                  child: Icon(Icons.add_outlined))))) // Bouton création de catégorie 
                  : GestureDetector( // Élément catégorie 
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed("/category",
                                arguments: categories["categories"][index]["id"])
                            .then((_) => setState(() {})); // Comme plus haut, réactualise la page avec les données possiblement modifiées par l'utilisateur 
                      },
                      onLongPress: () {
                        // Affiche la boîte de dialogue permettant de modifier ou supprimer la catégorie 
                        editCategory(
                            context,
                            categories["categories"][index]["id"],
                            categories["categories"][index]["name"]);
                      },
                      onSecondaryTap: () {
                        // Same, que juste là ↑, mais pour les clics droits. Il faudrait bloquer le comportement par défaut (essayez le clic droit sur la version web, vous verrez de quoi je parle)
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
            body: Container( // Si la largeur est plus importante que la hauteur ou qu'elle dépasse un certain seuil, on veut un display horizontal, sinon on préfèrera un vertical (sur téléphone par exemple)
                child: MediaQuery.of(context).size.width >
                            MediaQuery.of(context).size.height ||
                        MediaQuery.of(context).size.width > 900
                    ? Row(children: children)
                    : Column(children: children)));
      } else if (categories["status"] == 401) {
        // L'authentification a échoué. On ne déconnecte pas l'utilisateur au cas où c'est une erreur de notre part, mais on le renvoie vers la page de connexion 
        return const LoginPage();
      } else {
        // wtf, jsp ce qu'il a pû se passer, c'est probablement une erreur serveur (code 500)
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
