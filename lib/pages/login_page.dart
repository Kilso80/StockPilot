import 'package:flutter/material.dart';
import 'package:stockpilot/data/login_system.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final idSystem = LoginSystem();
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  String msg = "";

  void login() async {
    idSystem.saveCredentials(idController.text, passwordController.text);
    passwordController.text = "";
    int ans = await idSystem.login();
    if (ans == 0) {
      // Successfully logged in
      while (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      setState(() {
        msg = "";
      });
      Navigator.of(context).popAndPushNamed("/");
    } else {
      Map<int, String> reponses = {
        1: "Identifiant ou mot de passe incorrect",
        2: "Erreur lors de la connexion au serveur. Réessayez plus tard",
        3: "Pas de connexion. Vérifiez votre réseau et réessayez"
      };
      setState(() {
        msg = reponses[ans]!;
      });
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
            Icons.account_circle,
            size: 120,
            color: Theme.of(context).primaryColor,
          ),
          const Text(
            "Connexion",
            style: TextStyle(fontSize: 20),
          ),
          TextField(
            controller: idController,
            decoration: const InputDecoration(hintText: "Identifiant"),
            textInputAction: TextInputAction.next,
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(hintText: "Mot de passe"),
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
          ),
          Text(
            msg,
            style: const TextStyle(color: Colors.red),
          ),
          ElevatedButton(onPressed: login, child: const Text('Se connecter')),
          const Expanded(child: SizedBox()),
          const Text("Première fois ici ?"),
          ElevatedButton(onPressed: () {Navigator.pushNamed(context, '/register');}, child: const Text("Créer un compte"))
        ],
      )),
    );
  }
}
