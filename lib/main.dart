import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'models/category.dart';
import 'models/symbol_item.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const CaaApp());
}

class CaaApp extends StatelessWidget {
  const CaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App CAA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final StorageService _storage = StorageService();

  // Data State
  List<Category> _categories = [];
  List<SymbolItem> _allSymbols = [];
  
  // Navigation State
  Category? _selectedCategory; // null = View Categories, not null = View Symbols inside category

  // Loading State
  bool _isLoading = true;

  // Settings & Edit State
  bool _editMode = false;
  double _imageScale = 1.0;
  Color _cardBgColor = Colors.white;
  bool _showBorder = true;
  Color _borderColor = Colors.black;

  // App mode state
  bool _isSentenceMode = false;
  final List<SymbolItem> _sentence = [];

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadData();
  }

  Future<void> _loadData() async {
    final cats = await _storage.loadCategories();
    final syms = await _storage.loadSymbols();
    setState(() {
      _categories = cats;
      _allSymbols = syms;
      _isLoading = false;
    });
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("it-IT");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    flutterTts.speak(text);
    int durationMs = (text.length * 100).clamp(1000, 5000);
    await Future.delayed(Duration(milliseconds: durationMs));
  }

  Future<void> _playSentence() async {
    if (_sentence.isEmpty) return;
    String fullText = _sentence.map((e) => e.label).join(' ');
    await _speak(fullText);
    setState(() {
      _sentence.clear();
    });
  }

  // ---- Navigation ----
  void _onCategoryTap(Category category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onSymbolTap(SymbolItem symbol) {
    if (_isSentenceMode) {
      setState(() {
        _sentence.add(symbol);
      });
    } else {
      _speak(symbol.label);
    }
  }

  void _onBackFromCategory() {
    setState(() {
      _selectedCategory = null;
    });
  }

  void _removeSymbolFromSentence(int index) {
    setState(() {
      _sentence.removeAt(index);
    });
  }

  // ---- Image Utils ----
  Future<String?> _pickAndSaveImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return null;

    final directory = await getApplicationDocumentsDirectory();
    final ext = pickedFile.name.split('.').last;
    final newPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.$ext';
    final savedFile = await File(pickedFile.path).copy(newPath);
    return savedFile.path;
  }

  Widget _buildImage(String path, bool isAsset) {
    if (isAsset) {
      return Image.asset(path, fit: BoxFit.contain);
    } else {
      return Image.file(File(path), fit: BoxFit.contain);
    }
  }

  // ---- Add / Edit Dialogs ----
  void _showAddCategoryDialog() {
    final TextEditingController nameCtrl = TextEditingController();
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text("Nuova Cartella/Categoria"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome Categoria'),
                ),
                const SizedBox(height: 16),
                selectedImagePath != null
                    ? SizedBox(height: 100, child: Image.file(File(selectedImagePath!)))
                    : const Text("Nessuna immagine selezionata"),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text("Scegli Immagine"),
                  onPressed: () async {
                    final path = await _pickAndSaveImage();
                    if (path != null) {
                      setDialogState(() => selectedImagePath = path);
                    }
                  },
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty && selectedImagePath != null) {
                    final newCat = Category(
                      id: _storage.generateId(),
                      name: nameCtrl.text,
                      coverImagePath: selectedImagePath!,
                      isAsset: false,
                    );
                    setState(() {
                      _categories.add(newCat);
                    });
                    await _storage.saveCategories(_categories);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Salva"),
              )
            ],
          );
        }
      )
    );
  }

  void _showAddSymbolDialog() {
    if (_selectedCategory == null) return;
    
    final TextEditingController nameCtrl = TextEditingController();
    String? selectedImagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Nuovo Simbolo in '${_selectedCategory!.name}'"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nome Simbolo (Parola)'),
                ),
                const SizedBox(height: 16),
                selectedImagePath != null
                    ? SizedBox(height: 100, child: Image.file(File(selectedImagePath!)))
                    : const Text("Nessuna immagine selezionata"),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text("Scegli Immagine"),
                  onPressed: () async {
                    final path = await _pickAndSaveImage();
                    if (path != null) {
                      setDialogState(() => selectedImagePath = path);
                    }
                  },
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isNotEmpty && selectedImagePath != null) {
                    final newSym = SymbolItem(
                      id: _storage.generateId(),
                      categoryId: _selectedCategory!.id,
                      label: nameCtrl.text,
                      imagePath: selectedImagePath!,
                      isAsset: false,
                    );
                    setState(() {
                      _allSymbols.add(newSym);
                    });
                    await _storage.saveSymbols(_allSymbols);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Salva"),
              )
            ],
          );
        }
      )
    );
  }

  // ---- Settings Menu ----
  void _openSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Impostazioni"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Edit mode toggle
                    Container(
                      color: Colors.red[50],
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          const Icon(Icons.edit, color: Colors.red),
                          const SizedBox(width: 8),
                          const Expanded(child: Text("Modalità Modifica", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))),
                          Switch(
                            value: _editMode,
                            activeColor: Colors.red,
                            onChanged: (val) {
                              setModalState(() => _editMode = val);
                              setState(() => _editMode = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    const Text("Dimensione Simboli:", style: TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _imageScale,
                      min: 0.5,
                      max: 3.0,
                      onChanged: (val) {
                        setModalState(() => _imageScale = val);
                        setState(() => _imageScale = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text("Sfondo della carta:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                         _colorBtn(Colors.white, setModalState),
                         _colorBtn(Colors.yellow[200]!, setModalState),
                         _colorBtn(Colors.green[200]!, setModalState),
                         _colorBtn(Colors.blue[100]!, setModalState),
                         _colorBtn(Colors.pink[100]!, setModalState),
                         _colorBtn(Colors.transparent, setModalState, icon: Icons.format_color_reset),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                         const Text("Mostra bordo:", style: TextStyle(fontWeight: FontWeight.bold)),
                         Switch(
                           value: _showBorder,
                           onChanged: (val) {
                             setModalState(() => _showBorder = val);
                             setState(() => _showBorder = val);
                           },
                         ),
                      ],
                    ),
                    if (_showBorder) ...[
                      const SizedBox(height: 8),
                      const Text("Colore Bordo:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _colorBtn(Colors.black, setModalState, isBorder: true),
                          _colorBtn(Colors.red, setModalState, isBorder: true),
                          _colorBtn(Colors.blue, setModalState, isBorder: true),
                          _colorBtn(Colors.green, setModalState, isBorder: true),
                        ],
                      )
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Chiudi", style: TextStyle(fontSize: 18)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _colorBtn(Color c, Function setModalState, {bool isBorder = false, IconData? icon}) {
    return GestureDetector(
      onTap: () {
        setModalState(() {
          if (isBorder) _borderColor = c;
          else _cardBgColor = c;
        });
        setState(() {
          if (isBorder) _borderColor = c;
          else _cardBgColor = c;
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: c,
          border: Border.all(color: Colors.grey),
          shape: BoxShape.circle,
        ),
        child: icon != null ? Icon(icon, size: 16) : null,
      ),
    );
  }

  // ---- UI Builders ----
  Widget _buildSentenceBar() {
    return Container(
      height: 140, // Aumentata l'altezza per renderla più grande
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _sentence.length,
              itemBuilder: (context, index) {
                final sym = _sentence[index];
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 16, top: 12),
                      width: 100, // Più ampio
                      decoration: BoxDecoration(
                        color: _cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: _showBorder ? Border.all(color: _borderColor, width: 2) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: _buildImage(sym.imagePath, sym.isAsset),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              sym.label.toUpperCase(),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _removeSymbolFromSentence(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 28), // Molto visibile
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            height: 80,
            child: FloatingActionButton(
              heroTag: "playBtn",
              onPressed: _sentence.isEmpty ? null : _playSentence,
              backgroundColor: _sentence.isEmpty ? Colors.grey : Colors.green,
              child: const Icon(Icons.play_arrow, size: 60, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(double maxCrossAxisExtent) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0, 
      ),
      itemCount: _categories.length + (_editMode ? 1 : 0),
      itemBuilder: (context, index) {
        if (_editMode && index == _categories.length) {
          // Add Category Button
          return _buildAddCard(onTap: _showAddCategoryDialog, title: "Nuova\nCartella");
        }
        final cat = _categories[index];
        return _buildCard(
          imagePath: cat.coverImagePath,
          label: cat.name,
          isAsset: cat.isAsset,
          onTap: () => _onCategoryTap(cat),
          isFolder: true,
        );
      },
    );
  }

  Widget _buildSymbolsGrid(double maxCrossAxisExtent) {
    final catSymbols = _allSymbols.where((s) => s.categoryId == _selectedCategory!.id).toList();
    
    return Column(
      children: [
        // Pulsante indietro GIGANTE e accessibile
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[100],
              foregroundColor: Colors.blue[900],
              padding: const EdgeInsets.symmetric(vertical: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.arrow_back_rounded, size: 48),
            label: const Text("INDIETRO", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            onPressed: _onBackFromCategory,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCrossAxisExtent,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0, 
            ),
            itemCount: catSymbols.length + (_editMode ? 1 : 0),
            itemBuilder: (context, index) {
              if (_editMode && index == catSymbols.length) {
                // Add Symbol Button
                return _buildAddCard(onTap: _showAddSymbolDialog, title: "Nuovo\nSimbolo");
              }
              final sym = catSymbols[index];
              return _buildCard(
                imagePath: sym.imagePath,
                label: sym.label,
                isAsset: sym.isAsset,
                onTap: () => _onSymbolTap(sym),
                isFolder: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String imagePath,
    required String label,
    required bool isAsset,
    required VoidCallback onTap,
    required bool isFolder,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: _showBorder ? Border.all(color: _borderColor, width: 4) : null,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))
          ],
        ),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: _buildImage(imagePath, isAsset),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: isFolder ? 22 : 18,
                  fontWeight: FontWeight.w900,
                  color: isFolder ? Colors.blue[900] : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCard({required VoidCallback onTap, required String title}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green, width: 4, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo, size: 64, color: Colors.green),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double baseSize = 140.0;
    double currentExt = baseSize * _imageScale;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCategory == null 
          ? "Cartelle" 
          : "Cartella: ${_selectedCategory!.name}"),
        backgroundColor: _editMode ? Colors.red[300] : null,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 40, color: _editMode ? Colors.white : Colors.black87),
            onPressed: _openSettings,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Mode Toggle GIGANTE
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("PAROLA", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(width: 16),
                Transform.scale(
                  scale: 1.8,
                  child: Switch(
                    value: _isSentenceMode,
                    activeColor: Colors.purple,
                    inactiveThumbColor: Colors.blue,
                    inactiveTrackColor: Colors.blue[200],
                    onChanged: (val) {
                      setState(() {
                        _isSentenceMode = val;
                        if (!val) _sentence.clear(); 
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                const Text("FRASE", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple)),
              ],
            ),
          ),
          
          if (_isSentenceMode) ...[
            _buildSentenceBar(),
            const Divider(height: 1, thickness: 4),
          ],

          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : (_selectedCategory == null 
                  ? _buildCategoriesGrid(currentExt)
                  : _buildSymbolsGrid(currentExt)),
          ),
        ],
      ),
    );
  }
}
