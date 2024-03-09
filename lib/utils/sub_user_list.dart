import 'package:flutter/material.dart';
import 'package:stockpilot/data/login_system.dart';
import 'package:stockpilot/utils/subuser_popup.dart';

class SubUsersList extends StatefulWidget {
  const SubUsersList({super.key});

  @override
  State<SubUsersList> createState() => _SubUsersListState();
}

class _SubUsersListState extends State<SubUsersList> {
  void createSubUser(BuildContext context) {
    showDialog(
            context: context, builder: (context) => const CreateSubUserPopup())
        .then((value) => setState(
              () {},
            ));
  }

  void deleteAccount(context, name, id) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                  "Êtes-vous sûr de vouloir supprimer le compte de $name ?"),
              actions: [
                ActionChip(
                  label: const Text("Annuler"),
                  onPressed: Navigator.of(context).pop,
                ),
                ActionChip(
                  backgroundColor: Colors.red,
                  label: const Text("Supprimer"),
                  onPressed: () async {
                    await LoginSystem().deleteAccount(context, id);
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
              ],
            ));
  }

  Widget buildWithData(BuildContext context, AsyncSnapshot<List> snapshot) {
    List<Widget> children = [];
    for (var subUserData in snapshot.data ?? []) {
      var name = subUserData["name"];
      var id = subUserData["id"];
      children.add(ListTile(
          leading: Text(name),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    showDialog(
                            context: context,
                            builder: (context) =>
                                EditSubUserPopup(id: id, name: name))
                        .then((value) => setState(
                              () {},
                            ));
                  },
                  icon: const Icon(
                    Icons.edit,
                  )),
              IconButton(
                  onPressed: () {
                    deleteAccount(context, name, id);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  )),
            ],
          )));
    }

    children.add(IconButton(
        onPressed: () {
          createSubUser(context);
        },
        icon: const Icon(Icons.add)));

    return Column(
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: LoginSystem().getSubUsers(),
      builder: buildWithData,
      initialData: const [],
    );
  }
}
