import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class LoginSystem {
  final _myBox = Hive.box("credentials");
  String apiRootUrl = "https://nsi.stefa.org/stockpilot/API/";

  Map<String, String> getHeader() {
    if (_myBox.get("time") == null) {
      return {};
    }
    if (DateTime.now().isAfter(_myBox.get("time"))) {
      login();
    }
    return {"auth-token": _myBox.get("token")};
  }

  void logout() {
    _myBox.clear();
  }

  void saveCredentials(username, password) {
    _myBox.put("id", username);
    _myBox.put("password", password);
  }

  Future<bool> isAdmin() async {
    String url = "${apiRootUrl}users/organizations/isAdmin.php";
    var res = await http.put(Uri.parse(url), headers: getHeader());
    return res.statusCode == 200;
  }

  Future<List<Map>> getSubUsers() async {
    String url = "${apiRootUrl}users/organizations/isAdmin.php";
    var res = await http.put(Uri.parse(url), headers: getHeader());
    return jsonDecode(res.body);
  }

  Future<int> register() async {
    try {
      String url =
          "${apiRootUrl}users/register/index.php?username=${_myBox.get('id')}&password=${_myBox.get("password")}";
      var res = await http.post(Uri.parse(url));
      var json = jsonDecode(res.body);
      switch (json["status"]) {
        case 200:
          // print("Registered");
          await login();
          return 0;
        case 400:
          // print("Request error");
          return 1;
        default:
          // print("Server error");
          return 2;
      }
    } catch (error) {
      return 3; // Connexion error
    }
  }

  Future<int> login() async {
    try {
      var res = await http.get(Uri.https(
          "nsi.stefa.org",
          "/stockpilot/API/users/login/index.php",
          {"username": _myBox.get('id'), "password": _myBox.get('password')}));
      print(jsonDecode(res.body));
      var json = jsonDecode(res.body);
      switch (json["status"]) {
        case 200:
          _myBox.put("token", json["token"]);
          _myBox.put("time", DateTime.now().add(const Duration(minutes: 55)));
          print("Logged in ${json['token']}");
          return 0;
        case 401:
          print("Invalid credentials");
          // print(url);
          return 1;
        default:
          print("Server error");
          return 2;
      }
    } catch (error) {
      print("Connexion error");
      return 3; // Connexion error
    }
  }

  Future<bool> isUsernameAvailable(
      String username, BuildContext context) async {
    try {
      String url =
          "${apiRootUrl}users/register/is_username_taken.php?username=$username";
      var res = await http.get(Uri.parse(url));
      bool ans = jsonDecode(res.body)["disponible"];
      return ans;
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vérifiez votre connexion")));
      return false;
    }
  }

  Future<void> changeUsername(String newUsername) async {
    String url = "${apiRootUrl}users/edit/username.php?new=$newUsername";
    // var res =
    await http.put(Uri.parse(url), headers: getHeader());
    _myBox.put("id", newUsername);
    // print(res.body);
  }

  Future<void> changePassword(String newPassword) async {
    String url = "${apiRootUrl}users/edit/password.php?new=$newPassword";
    // var res =
    await http.put(Uri.parse(url), headers: getHeader());
    _myBox.put("password", newPassword);
    // print(res.body);
  }

  String getUsername() {
    return _myBox.get("id");
  }

  Future<void> deleteAccount(context) async {
    String url = "${apiRootUrl}users/delete.php";
    var res = await http.put(Uri.parse(url), headers: getHeader());
    // print(res.body);
    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Compte supprimé avec succès")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Erreur lors de la suppression du compte")));
    }
  }
}
