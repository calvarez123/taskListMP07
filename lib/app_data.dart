// app_data.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppData extends ChangeNotifier {
  Map<String, List<String>> todoLists = {};
  String selectedList = '';

  Future<void> loadTodoLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    todoLists = Map<String, List<String>>.from(
      (prefs.getString('todoLists') ?? '{}').split('\n').fold({}, (map, entry) {
        var parts = entry.split(':');
        if (parts.length == 2) {
          map[parts[0]] = parts[1].split(',').map((e) => e.trim()).toList();
        }
        return map;
      }),
    );
    notifyListeners();
  }

  Future<void> saveTodoLists() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> lines = [];
    todoLists.forEach((key, value) {
      lines.add('$key: ${value.join(',')}');
    });
    await prefs.setString('todoLists', lines.join('\n'));
    notifyListeners();
  }
}
