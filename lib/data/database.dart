import 'dart:convert';
import 'package:stockpilot/data/login_system.dart';
import 'package:http/http.dart' as http;

class DataBase {
  LoginSystem idSystem = LoginSystem();

  Future<Map> getCategories() async {
    String url = "http://51.210.102.53/2FIOLET/StockPilot/categories";
    var res = await http.get(Uri.parse(url), headers: idSystem.getHeader());
    return jsonDecode(res.body);
  }

  Future<Map> getAlerts() async {
    String url = "http://51.210.102.53/2FIOLET/StockPilot/items";
    var res = await http.get(Uri.parse(url), headers: idSystem.getHeader());
    return jsonDecode(res.body);
  }

  Future<void> createCategory(String name) async {
    String url =
        "http://51.210.102.53/2FIOLET/StockPilot/categories/?name=$name";
    var res = await http.post(Uri.parse(url), headers: idSystem.getHeader());
    print(res.body);
  }

  Future<void> renameCategory(id, String name) async {
    String url =
        "http://51.210.102.53/2FIOLET/StockPilot/categories/?id=$id&name=$name";
    var res = await http.put(Uri.parse(url), headers: idSystem.getHeader());
    print(res.body);
  }

  Future<void> deleteCategory(id) async {
    String url = "http://51.210.102.53/2FIOLET/StockPilot/categories/?id=$id";
    var res = await http.delete(Uri.parse(url), headers: idSystem.getHeader());
    print(res.body);
  }

  Future<List<Map>> getCategoriesAndAlerts() async {
    return [await getCategories(), await getAlerts()];
  }
}
