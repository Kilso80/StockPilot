import 'package:flutter/material.dart';
import 'package:stockpilot/data/login_system.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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

  void register() async {
    idSystem.saveCredentials(idController.text, passwordController.text);
    switch (await idSystem.register()) {
      case 3:
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vérifiez votre connexion")));
        break;
      case 2:
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Erreur lors de la création de votre compte. Réessayez plus tard.")));
        break;
      case 1:
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Veuillez préciser un nom d'utilisateur et un mot de passe.")));
        break;
      case 0:
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Compte créé avec succès.")));
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        Navigator.of(context).popAndPushNamed("/");
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("StockPilot"),
      ),
      body: Center(
          child: Column(
        children: [
          Icon(
            Icons.person_add_alt_1_rounded,
            size: 120,
            color: Theme.of(context).primaryColor,
          ),
          const Text(
            "Créer un compte",
            style: TextStyle(fontSize: 20),
          ),
          TextField(
            controller: idController,
            decoration: InputDecoration(
                hintText: "Identifiant", helperText: usernameMsg),
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
          const Text(""),
          ElevatedButton(
              onPressed: register, child: const Text('Créer mon compte')),
          const Expanded(child: SizedBox()),
          const Text("Vous avez déjà un compte ?"),
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: const Text("Connexion"))
        ],
      )),
    );
  }
}
