import 'package:flutter/material.dart';
import 'package:stockpilot/data/login_system.dart';
import 'package:stockpilot/utils/sub_user_list.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final idSystem = LoginSystem();
  bool usernameOk = true;
  bool verifying = false;
  final idController = TextEditingController(text: LoginSystem().getUsername());
  final passwordController = TextEditingController();

  void logout(context) {
    idSystem.logout();
    Navigator.of(context).pop();
    Navigator.of(context).popAndPushNamed('/login');
  }

  void deleteAccount(context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text(
                  "Êtes-vous sûr de vouloir supprimer votre compte ?"),
              actions: [
                ActionChip(
                  label: const Text("Annuler"),
                  onPressed: Navigator.of(context).pop,
                ),
                ActionChip(
                  backgroundColor: Colors.red,
                  label: const Text("Supprimer"),
                  onPressed: () async {
                    await idSystem.deleteAccount(context);
                    idSystem.logout();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).popAndPushNamed("/login");
                  },
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profil"),
        ),
        body: ListView(
          children: [
            const Text('Modifier le nom d\'utilisateur'),
            TextField(
              maxLength: 15,
              controller: idController,
              onChanged: (value) {
                setState(() {
                  verifying = true;
                });
                idSystem
                    .isUsernameAvailable(value, context)
                    .then((ok) => setState(() {
                          verifying = false;
                          usernameOk = value.length <= 15 &&
                              value != "" &&
                              (ok || (value == idSystem.getUsername()));
                        }));
              },
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: "Nom d'utilisateur",
                  helperText: "Nom d'utilisateur disponible",
                  errorText:
                      usernameOk ? null : "Nom d'utilisateur indisponible"),
            ),
            ElevatedButton(
                onPressed: usernameOk && !verifying
                    ? () async {
                        await idSystem.changeUsername(idController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Nom d'utilisateur modifié")));
                      }
                    : null,
                child: const Text('Enregistrer')),
            const SizedBox(
              height: 4,
            ),
            const Divider(),
            const SizedBox(
              height: 4,
            ),
            const Text('Modifier le mot de passe'),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), hintText: "Mot de passe"),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(
              height: 14,
            ),
            ElevatedButton(
                onPressed: passwordController.text != ""
                    ? () async {
                        await idSystem.changePassword(passwordController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Mot de passe modifié")));
                      }
                    : null,
                child: const Text('Enregistrer')),
            const SizedBox(
              height: 4,
            ),
            const Divider(),
            const SizedBox(
              height: 4,
            ),
            ElevatedButton(
                onPressed: () => logout(context),
                child: const Text('Se déconnecter')),
            const SizedBox(
              height: 14,
            ),
            ElevatedButton(
                onPressed: () => deleteAccount(context),
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.red),
                    overlayColor: MaterialStateProperty.all(
                        const Color.fromARGB(112, 244, 67, 54))),
                child: const Text("Supprimer le compte")),
            const Divider(),
            const Center(child: Text("Gérer vos utilisateurs")),
            const SubUsersList(),
          ],
        ));
  }
}
