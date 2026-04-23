import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/sentence_bar.dart';
import '../widgets/item_card.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/add_dialogs.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddCategoryDialog(),
    );
  }

  void _showAddSymbolDialog(BuildContext context, AppProvider provider) {
    if (provider.selectedCategory == null) return;
    showDialog(
      context: context,
      builder: (context) => AddSymbolDialog(category: provider.selectedCategory!),
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

  Widget _buildCategoriesGrid(BuildContext context, AppProvider provider, double maxCrossAxisExtent) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: provider.categories.length + (provider.editMode ? 1 : 0),
      itemBuilder: (context, index) {
        if (provider.editMode && index == provider.categories.length) {
          return _buildAddCard(
            onTap: () => _showAddCategoryDialog(context),
            title: "Nuova\nCartella"
          );
        }
        final cat = provider.categories[index];
        return ItemCard(
          imagePath: cat.coverImagePath,
          label: cat.name,
          isAsset: cat.isAsset,
          isFolder: true,
          onTap: () => provider.selectCategory(cat),
          onDelete: () => provider.removeCategory(cat),
        );
      },
    );
  }

  Widget _buildSymbolsGrid(BuildContext context, AppProvider provider, double maxCrossAxisExtent) {
    final catSymbols = provider.categorySymbols;

    return Column(
      children: [
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
            onPressed: () => provider.goBack(),
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
            itemCount: catSymbols.length + (provider.editMode ? 1 : 0),
            itemBuilder: (context, index) {
              if (provider.editMode && index == catSymbols.length) {
                return _buildAddCard(
                  onTap: () => _showAddSymbolDialog(context, provider),
                  title: "Nuovo\nSimbolo"
                );
              }
              final sym = catSymbols[index];
              return ItemCard(
                imagePath: sym.imagePath,
                label: sym.label,
                isAsset: sym.isAsset,
                isFolder: false,
                onTap: () => provider.handleSymbolTap(sym),
                onDelete: () => provider.removeSymbol(sym),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double baseSize = 140.0;
    double currentExt = baseSize * provider.imageScale;

    return Scaffold(
      appBar: AppBar(
        title: Text(provider.selectedCategory == null
          ? "Cartelle"
          : "Cartella: ${provider.selectedCategory!.name}"),
        backgroundColor: provider.editMode ? Colors.red[300] : null,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, size: 40, color: provider.editMode ? Colors.white : Colors.black87),
            onPressed: () => _openSettings(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
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
                    value: provider.isSentenceMode,
                    activeColor: Colors.purple,
                    inactiveThumbColor: Colors.blue,
                    inactiveTrackColor: Colors.blue[200],
                    onChanged: (val) => provider.toggleSentenceMode(val),
                  ),
                ),
                const SizedBox(width: 16),
                const Text("FRASE", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple)),
              ],
            ),
          ),

          if (provider.isSentenceMode) ...[
            const SentenceBar(),
            const Divider(height: 1, thickness: 4),
          ],

          Expanded(
            child: provider.selectedCategory == null
                  ? _buildCategoriesGrid(context, provider, currentExt)
                  : _buildSymbolsGrid(context, provider, currentExt),
          ),
        ],
      ),
    );
  }
}
