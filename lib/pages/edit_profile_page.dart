import 'package:flutter/material.dart';
import 'package:stockpilot/data/login_system.dart';

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
              title: Text("Êtes-vous sûr de vouloir supprimer votre compte ?"),
              actions: [
                ActionChip(
                  label: Text("Annuler"),
                  onPressed: Navigator.of(context).pop,
                ),
                ActionChip(
                  label: Text("Supprimer"),
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
          title: Text("Profil"),
        ),
        body: Column(
          children: [
            Text('Modifier le nom d\'utilisateur'),
            TextField(
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
                  border: OutlineInputBorder(),
                  hintText: "Nom d'utilisateur",
                  helperText: "Nom d'utilisateur disponible",
                  errorText:
                      usernameOk ? null : "Nom d'utilisateur indisponible"),
            ),
            ElevatedButton(
                onPressed: usernameOk && !verifying
                    ? () async {
                        await idSystem.changeUsername(idController.text);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Nom d'utilisateur modifié")));
                      }
                    : null,
                child: Text('Enregistrer')),
            SizedBox(
              height: 4,
            ),
            Divider(),
            SizedBox(
              height: 4,
            ),
            Text('Modifier le mot de passe'),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "Mot de passe"),
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              onChanged: (_) => setState(() {}),
            ),
            ElevatedButton(
                onPressed: passwordController.text != ""
                    ? () async {
                        await idSystem.changePassword(passwordController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Mot de passe modifié")));
                      }
                    : null,
                child: Text('Enregistrer')),
            SizedBox(
              height: 4,
            ),
            Divider(),
            SizedBox(
              height: 4,
            ),
            ElevatedButton(
                onPressed: () => logout(context),
                child: Text('Se déconnecter')),
            ElevatedButton(
                onPressed: () => deleteAccount(context),
                child: Text("Supprimer le compte"),
                style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.red),
                    overlayColor: MaterialStateProperty.all(
                        const Color.fromARGB(112, 244, 67, 54))))
          ],
        ));
  }
}
