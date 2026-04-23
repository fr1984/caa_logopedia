import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/symbol_item.dart';
import '../providers/app_provider.dart';
import '../services/storage_service.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController nameCtrl = TextEditingController();
  String? selectedImagePath;

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

  @override
  Widget build(BuildContext context) {
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
                setState(() => selectedImagePath = path);
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
              final provider = context.read<AppProvider>();
              final storage = StorageService(); // Need it just for ID generation, or move generateId to util
              final newCat = Category(
                id: storage.generateId(),
                name: nameCtrl.text,
                coverImagePath: selectedImagePath!,
                isAsset: false,
              );
              await provider.addCategory(newCat);
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text("Salva"),
        )
      ],
    );
  }
}

class AddSymbolDialog extends StatefulWidget {
  final Category category;

  const AddSymbolDialog({super.key, required this.category});

  @override
  State<AddSymbolDialog> createState() => _AddSymbolDialogState();
}

class _AddSymbolDialogState extends State<AddSymbolDialog> {
  final TextEditingController nameCtrl = TextEditingController();
  String? selectedImagePath;

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Nuovo Simbolo in '${widget.category.name}'"),
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
                setState(() => selectedImagePath = path);
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
              final provider = context.read<AppProvider>();
              final storage = StorageService();
              final newSym = SymbolItem(
                id: storage.generateId(),
                categoryId: widget.category.id,
                label: nameCtrl.text,
                imagePath: selectedImagePath!,
                isAsset: false,
              );
              await provider.addSymbol(newSym);
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text("Salva"),
        )
      ],
    );
  }
}
