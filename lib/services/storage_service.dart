import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_list.dart';

class StorageService {
  static const String _listsKey = 'shopping_lists';

  Future<List<ShoppingList>> loadLists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? listsJson = prefs.getString(_listsKey);

      if (listsJson == null) {
        return [];
      }

      final List<dynamic> decoded = json.decode(listsJson) as List<dynamic>;
      return decoded
          .map((item) => ShoppingList.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading lists: $e');
      return [];
    }
  }

  Future<bool> saveLists(List<ShoppingList> lists) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        lists.map((list) => list.toJson()).toList(),
      );
      return await prefs.setString(_listsKey, encoded);
    } catch (e) {
      print('Error saving lists: $e');
      return false;
    }
  }

  Future<bool> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_listsKey);
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }
}
