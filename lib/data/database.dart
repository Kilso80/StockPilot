import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockpilot/data/login_system.dart';
import 'package:http/http.dart' as http;

class DataBase {
  LoginSystem idSystem = LoginSystem();
  String apiDomain = "nsi.stefa.org";
  String apiPath = "/stockpilot/API";

  Future<void> export(context) async {
    String path = "/export.php";
    var res = await http.get(Uri.https(apiDomain, apiPath + path),
        headers: idSystem.getHeader());
    Clipboard.setData(ClipboardData(text: res.body)).then((value) =>
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Export copié dans le presse-papier"))));
  }

  Future<void> import(BuildContext context, String csv) async {
    String path = '/import.php';
    await http.post(Uri.https(apiDomain, apiPath + path),
        headers: idSystem.getHeader(), body: csv);
  }

  Future<Map> getCategories() async {
    String path = "/categories/index.php";
    var res = await http.get(Uri.https(apiDomain, apiPath + path),
        headers: idSystem.getHeader());
    return jsonDecode(res.body);
  }

  Future<Map> getAlerts() async {
    String path = "/items/index.php";
    var res = await http.get(Uri.https(apiDomain, apiPath + path),
        headers: idSystem.getHeader());
    return jsonDecode(res.body);
  }

  Future<void> createCategory(String name) async {
    String path = "/categories/index.php";
    // var res =
    await http.post(Uri.parse("https://$apiDomain$apiPath$path?name=$name"),
        headers: idSystem.getHeader());
    // print(res.body);
  }

  Future<void> renameCategory(id, String name, String salle) async {
    String path = "/categories/index.php";
    // var res =

    await http.put(
        Uri.parse("https://$apiDomain$apiPath$path?name=$name&id=$id&salle=$salle"),
        headers: idSystem.getHeader());
    // print(res.body);
  }

  Future<void> deleteCategory(id) async {
    String path = "/categories/index.php";
    // var res =
    await http.delete(Uri.parse("https://$apiDomain$apiPath$path?id=$id"),
        headers: idSystem.getHeader());
    // print(res.body);
  }

  Future<List> getCategoriesAndAlerts() async {
    return [await getCategories(), await getAlerts(), await idSystem.isAdmin()];
  }

  Future<Map> getItemsOfCategory(categoryId) async {
    String path = "/categories/index.php";
    var res = await http.get(
        Uri.parse("https://$apiDomain$apiPath$path?id=$categoryId"),
        headers: idSystem.getHeader());
    // print(res.body);
    return jsonDecode(res.body);
  }

  Future<void> createItem(String name, category) async {
    String path = "/items/index.php";
    // var res =
    await http.post(
        Uri.parse(
            "https://$apiDomain$apiPath$path?name=$name&category=$category"),
        headers: idSystem.getHeader());
    // print(res.body);
  }

  Future<void> updateItem(id, String name, int stock, int? threshold) async {
    String path = "/items/index.php";
    // var res =
    await http.put(
        Uri.parse(
            "https://$apiDomain$apiPath$path?id=$id&name=$name&stock=$stock&threshold=$threshold"),
        headers: idSystem.getHeader());
    // print(res.body);
  }

  Future<void> deleteItem(id) async {
    String path = "/items/index.php";
    // var res =
    await http.delete(Uri.parse("https://$apiDomain$apiPath$path?id=$id"),
        headers: idSystem.getHeader());
    // print(res.body);
  }
}
