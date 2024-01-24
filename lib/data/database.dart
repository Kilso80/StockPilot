import 'dart:convert';
import 'package:stockpilot/data/login_system.dart';
import 'package:http/http.dart' as http;

class DataBase {
  LoginSystem idSystem = LoginSystem();
  String apiRootUrl = "https://nsi.stefa.org/stockpilot/API/";

  Future<Map> getCategories() async {
    String url = "${apiRootUrl}categories";
    var res = await http.get(Uri.parse(url), headers: idSystem.getHeader());
    return jsonDecode(res.body);
  }

  Future<Map> getAlerts() async {
    String url = "${apiRootUrl}items";
    var res = await http.get(Uri.parse(url), headers: idSystem.getHeader());
    return jsonDecode(res.body);
  }

  Future<void> createCategory(String name) async {
    String url =
        "${apiRootUrl}categories/?name=$name";
    // var res = 
    await http.post(Uri.parse(url), headers: idSystem.getHeader());
    // print(res.body);
  }

  Future<void> renameCategory(id, String name) async {
    String url =
        "${apiRootUrl}categories/?id=$id&name=$name";
    // var res = 
    await http.put(Uri.parse(url), headers: idSystem.getHeader());
    // print(res.body);
  }

  Future<void> deleteCategory(id) async {
    String url = "${apiRootUrl}categories/?id=$id";
    // var res = 
    await http.delete(Uri.parse(url), headers: idSystem.getHeader());
    // print(res.body);
  }

  Future<List<Map>> getCategoriesAndAlerts() async {
    return [await getCategories(), await getAlerts()];
  }

  Future<Map> getItemsOfCategory(categoryId) async {
    String url = "${apiRootUrl}categories/?id=$categoryId";
    var res = await http.get(Uri.parse(url), headers: idSystem.getHeader());
    // print(res.body);
    return jsonDecode(res.body);
  }

  Future<void> createItem(String name, category) async {
    String url = "${apiRootUrl}items/?name=$name&category=$category";
    // var res = 
    await http.post(Uri.parse(url), headers: idSystem.getHeader());
    // print(res.body);
  }

  Future<void> updateItem(id, String name, int stock, int? threshold) async {
    String url = "${apiRootUrl}items/?id=$id&name=$name&stock=$stock&threshold=$threshold";
    // var res = 
    await http.put(Uri.parse(url), headers: idSystem.getHeader());
    // print(res.body);
  }

  Future<void> deleteItem(id) async {
    String url = "${apiRootUrl}items/?id=$id";
    // var res = 
    await http.delete(Uri.parse(url), headers: idSystem.getHeader());
    // print(res.body);
  }

}
