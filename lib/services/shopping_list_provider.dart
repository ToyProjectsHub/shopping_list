import 'package:flutter/foundation.dart';
import '../models/shopping_list.dart';
import '../models/shopping_item.dart';
import 'storage_service.dart';

class ShoppingListProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<ShoppingList> _lists = [];
  bool _isLoading = false;

  List<ShoppingList> get lists => _lists;
  bool get isLoading => _isLoading;

  ShoppingListProvider() {
    loadLists();
  }

  Future<void> loadLists() async {
    _isLoading = true;
    notifyListeners();

    _lists = await _storageService.loadLists();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveLists() async {
    await _storageService.saveLists(_lists);
  }

  void addList(String title) {
    final newList = ShoppingList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    _lists.add(newList);
    _saveLists();
    notifyListeners();
  }

  void removeList(String listId) {
    _lists.removeWhere((list) => list.id == listId);
    _saveLists();
    notifyListeners();
  }

  void updateListTitle(String listId, String newTitle) {
    final index = _lists.indexWhere((list) => list.id == listId);
    if (index != -1) {
      _lists[index].title = newTitle;
      _saveLists();
      notifyListeners();
    }
  }

  void addItem(String listId, String itemName) {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final newItem = ShoppingItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: itemName,
      );
      _lists[listIndex].items.add(newItem);
      _saveLists();
      notifyListeners();
    }
  }

  void removeItem(String listId, String itemId) {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      _lists[listIndex].items.removeWhere((item) => item.id == itemId);
      _saveLists();
      notifyListeners();
    }
  }

  void toggleItemComplete(String listId, String itemId) {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final itemIndex =
          _lists[listIndex].items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        _lists[listIndex].items[itemIndex].isCompleted =
            !_lists[listIndex].items[itemIndex].isCompleted;
        _saveLists();
        notifyListeners();
      }
    }
  }

  void updateItem(String listId, String itemId, ShoppingItem updatedItem) {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      final itemIndex =
          _lists[listIndex].items.indexWhere((item) => item.id == itemId);
      if (itemIndex != -1) {
        _lists[listIndex].items[itemIndex] = updatedItem;
        _saveLists();
        notifyListeners();
      }
    }
  }

  void deleteCompletedItems(String listId) {
    final listIndex = _lists.indexWhere((list) => list.id == listId);
    if (listIndex != -1) {
      _lists[listIndex].items.removeWhere((item) => item.isCompleted);
      _saveLists();
      notifyListeners();
    }
  }

  ShoppingList? getListById(String listId) {
    try {
      return _lists.firstWhere((list) => list.id == listId);
    } catch (e) {
      return null;
    }
  }
}
