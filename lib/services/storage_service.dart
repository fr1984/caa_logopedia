import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/symbol_item.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  static const String categoriesKey = 'categories';
  static const String symbolsKey = 'symbols';
  final _uuid = const Uuid();

  Future<void> saveCategories(List<Category> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = categories.map((c) => c.toJson()).toList();
    await prefs.setString(categoriesKey, json.encode(jsonList));
  }

  Future<List<Category>> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(categoriesKey);
      if (jsonString != null && jsonString != "[]") {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((e) => Category.fromJson(e)).toList();
      }
    } catch (e) {
      print('Errore caricamento categorie: $e');
    }
    // Dati iniziali di default
    return [
      Category(id: 'cat_base', name: 'Parole Base', coverImagePath: 'assets/images/io.png', isAsset: true),
      Category(id: 'cat_azioni', name: 'Azioni', coverImagePath: 'assets/images/mangiare.png', isAsset: true),
    ];
  }

  Future<void> saveSymbols(List<SymbolItem> symbols) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = symbols.map((s) => s.toJson()).toList();
    await prefs.setString(symbolsKey, json.encode(jsonList));
  }

  Future<List<SymbolItem>> loadSymbols() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(symbolsKey);
      if (jsonString != null && jsonString != "[]") {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((e) => SymbolItem.fromJson(e)).toList();
      }
    } catch (e) {
      print('Errore caricamento simboli: $e');
    }
    // Dati iniziali di default
    return [
      SymbolItem(id: 's1', categoryId: 'cat_base', label: 'Io', imagePath: 'assets/images/io.png', isAsset: true),
      SymbolItem(id: 's2', categoryId: 'cat_base', label: 'Voglio', imagePath: 'assets/images/voglio.png', isAsset: true),
      SymbolItem(id: 's3', categoryId: 'cat_azioni', label: 'Mangiare', imagePath: 'assets/images/mangiare.png', isAsset: true),
      SymbolItem(id: 's4', categoryId: 'cat_azioni', label: 'Bere', imagePath: 'assets/images/bere.png', isAsset: true),
    ];
  }

  String generateId() {
    return _uuid.v4();
  }
}
