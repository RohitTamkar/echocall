import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _db = FirebaseFirestore.instance;

  // Signup: store user in Firestore
  Future<bool> signup(String mobile, String name, String dept, String pin) async {
    try {
      final doc = await _db.collection("users").doc(mobile).get();
      if (doc.exists) return false; // user already exists
      await _db.collection("users").doc(mobile).set({
        "name": name,
        "mobile": mobile,
        "department": dept,
        "pin": pin,
      });
      return true;
    } catch (e) {
      print("Signup error: $e");
      return false;
    }
  }

  // Login: match pin with Firestore
  Future<bool> login(String mobile, String pin) async {
    try {
      final doc = await _db.collection("users").doc(mobile).get();
      if (doc.exists && doc["pin"] == pin) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("mobile", mobile);
        await prefs.setString("name", doc["name"]);
        await prefs.setString("department", doc["department"]);
        await prefs.setString("pin", doc["pin"]);
        return true;
      }
      return false;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLoggedIn") ?? false;
  }
  Future<String?> getLoggedInMobileNo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("mobile");
  }
  Future<String?> getLoggedInUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("name");
  }
  Future<Map<String, String?>> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "mobile": prefs.getString("mobile"),
      "name": prefs.getString("name"),
      "department": prefs.getString("department"),
      "pin": prefs.getString("pin"),
    };
  }
}
