import 'package:flutter/material.dart';
import 'package:stockpilot/data/login_system.dart';

class CreateSubUserPopup extends StatefulWidget {
  const CreateSubUserPopup({super.key});

  @override
  State<CreateSubUserPopup> createState() => _CreateSubUserPopupState();
}

class _CreateSubUserPopupState extends State<CreateSubUserPopup> {
  final idSystem = LoginSystem();
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  String usernameMsg = "L'identifiant doit être unique";

  void checkUsername(String username) async {
    setState(() {
      usernameMsg = "Vérification...";
    });
    if (await idSystem.isUsernameAvailable(username, context)) {
      setState(() {
        usernameMsg = "Identifiant disponibe";
      });
    } else {
      setState(() {
        usernameMsg = "Identifiant indisponible";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text("Créer un nouvel utilisateur"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(
                  hintText: "Identifiant", helperText: usernameMsg),
              textInputAction: TextInputAction.next,
              maxLength: 15,
              onChanged: checkUsername,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(hintText: "Mot de passe"),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
          ],
        ),
        actions: [
          ActionChip(
              onPressed: () {
                idController.text = "";
                passwordController.text = "";
                Navigator.of(context).pop();
              },
              label: const Text('Annuler')),
          ActionChip(
              onPressed: idController.text.isNotEmpty &&
                      idController.text.length < 16 &&
                      usernameMsg == "Identifiant disponibe"
                  ? () async {
                      await idSystem.createSubAccount(
                          idController.text, passwordController.text);
                      Navigator.of(context).pop();
                      idController.text = "";
                      passwordController.text = "";
                    }
                  : null,
              label: const Text('Créer')),
        ]);
  }
}

class EditSubUserPopup extends StatefulWidget {
  final String id;
  final String name;

  const EditSubUserPopup({
    required this.id,
    required this.name,
    Key? key,
  }) : super(key: key);

  @override
  State<EditSubUserPopup> createState() => _EditSubUserPopupState();
}

class _EditSubUserPopupState extends State<EditSubUserPopup> {
  String get id => widget.id;
  String get name => widget.name;
  final idSystem = LoginSystem();
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  String usernameMsg = "L'identifiant doit être unique";

  @override
  void initState() {
    super.initState();
    idController.text = name;
  }

  void checkUsername(String username) async {
    setState(() {
      usernameMsg = "Vérification...";
    });
    if (username == name ||
        await idSystem.isUsernameAvailable(username, context)) {
      setState(() {
        usernameMsg = "Identifiant disponibe";
      });
    } else {
      setState(() {
        usernameMsg = "Identifiant indisponible";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text("Éditer l'utilisateur $name"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(
                  hintText: "Nouvel identifiant", helperText: usernameMsg),
              textInputAction: TextInputAction.next,
              maxLength: 15,
              onChanged: checkUsername,
            ),
            TextField(
              controller: passwordController,
              decoration:
                  const InputDecoration(hintText: "Nouveau mot de passe"),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
          ],
        ),
        actions: [
          ActionChip(
              onPressed: () {
                idController.text = "";
                passwordController.text = "";
                Navigator.of(context).pop();
              },
              label: const Text('Annuler')),
          ActionChip(
              onPressed: idController.text.isNotEmpty &&
                      idController.text.length < 16 &&
                      usernameMsg == "Identifiant disponibe"
                  ? () async {
                      await idSystem.changePassword(
                          passwordController.text, id);
                      await idSystem.changeUsername(idController.text, id);
                      idController.text = "";
                      passwordController.text = "";
                      Navigator.of(context).pop();
                    }
                  : null,
              label: const Text('Enregistrer')),
        ]);
  }
}
