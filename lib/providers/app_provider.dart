import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/symbol_item.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

class AppProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  final TtsService _ttsService = TtsService();

  // Data State
  List<Category> _categories = [];
  List<SymbolItem> _allSymbols = [];

  // Navigation State
  Category? _selectedCategory;

  // Loading State
  bool _isLoading = true;

  // Settings State
  bool _editMode = false;
  double _imageScale = 1.0;
  Color _cardBgColor = Colors.white;
  bool _showBorder = true;
  Color _borderColor = Colors.black;

  // Sentence State
  bool _isSentenceMode = false;
  final List<SymbolItem> _sentence = [];

  // Getters
  List<Category> get categories => _categories;
  List<SymbolItem> get allSymbols => _allSymbols;
  Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get editMode => _editMode;
  double get imageScale => _imageScale;
  Color get cardBgColor => _cardBgColor;
  bool get showBorder => _showBorder;
  Color get borderColor => _borderColor;
  bool get isSentenceMode => _isSentenceMode;
  List<SymbolItem> get sentence => _sentence;

  List<SymbolItem> get categorySymbols =>
    _selectedCategory == null
        ? []
        : _allSymbols.where((s) => s.categoryId == _selectedCategory!.id).toList();

  Future<void> init() async {
    await _ttsService.init();

    // Load Data
    _categories = await _storage.loadCategories();
    _allSymbols = await _storage.loadSymbols();

    // Load Settings
    final settings = await _storage.loadSettings();
    _imageScale = settings['imageScale'] ?? 1.0;
    _cardBgColor = Color(settings['cardBgColor'] ?? Colors.white.value);
    _showBorder = settings['showBorder'] ?? true;
    _borderColor = Color(settings['borderColor'] ?? Colors.black.value);
    _isSentenceMode = settings['isSentenceMode'] ?? false;

    _isLoading = false;
    notifyListeners();
  }

  // ---- Navigation ----
  void selectCategory(Category category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void goBack() {
    _selectedCategory = null;
    notifyListeners();
  }

  // ---- Sentence & TTS ----
  void handleSymbolTap(SymbolItem symbol) {
    if (_isSentenceMode) {
      _sentence.add(symbol);
      notifyListeners();
    } else {
      _ttsService.speak(symbol.label);
    }
  }

  void removeSymbolFromSentence(int index) {
    _sentence.removeAt(index);
    notifyListeners();
  }

  Future<void> playSentence() async {
    if (_sentence.isEmpty) return;
    String fullText = _sentence.map((e) => e.label).join(' ');
    await _ttsService.speak(fullText);
    _sentence.clear();
    notifyListeners();
  }

  void toggleSentenceMode(bool value) {
    _isSentenceMode = value;
    if (!value) {
      _sentence.clear();
    }
    _saveSettings();
    notifyListeners();
  }

  // ---- Settings & Edit Mode ----
  void toggleEditMode(bool value) {
    _editMode = value;
    notifyListeners();
  }

  void setImageScale(double value) {
    _imageScale = value;
    _saveSettings();
    notifyListeners();
  }

  void setCardBgColor(Color color) {
    _cardBgColor = color;
    _saveSettings();
    notifyListeners();
  }

  void setShowBorder(bool value) {
    _showBorder = value;
    _saveSettings();
    notifyListeners();
  }

  void setBorderColor(Color color) {
    _borderColor = color;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    await _storage.saveSettings({
      'imageScale': _imageScale,
      'cardBgColor': _cardBgColor.value,
      'showBorder': _showBorder,
      'borderColor': _borderColor.value,
      'isSentenceMode': _isSentenceMode,
    });
  }

  // ---- Data Management ----
  Future<void> addCategory(Category category) async {
    _categories.add(category);
    await _storage.saveCategories(_categories);
    notifyListeners();
  }

  Future<void> addSymbol(SymbolItem symbol) async {
    _allSymbols.add(symbol);
    await _storage.saveSymbols(_allSymbols);
    notifyListeners();
  }

  Future<void> removeCategory(Category category) async {
    _categories.removeWhere((c) => c.id == category.id);
    _allSymbols.removeWhere((s) => s.categoryId == category.id);
    await _storage.saveCategories(_categories);
    await _storage.saveSymbols(_allSymbols);
    notifyListeners();
  }

  Future<void> removeSymbol(SymbolItem symbol) async {
    _allSymbols.removeWhere((s) => s.id == symbol.id);
    await _storage.saveSymbols(_allSymbols);
    notifyListeners();
  }
}
