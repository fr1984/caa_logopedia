import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ItemCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final bool isAsset;
  final VoidCallback onTap;
  final bool isFolder;
  final VoidCallback? onDelete;

  const ItemCard({
    super.key,
    required this.imagePath,
    required this.label,
    required this.isAsset,
    required this.onTap,
    required this.isFolder,
    this.onDelete,
  });

  Widget _buildImage(String path, bool isAsset) {
    if (isAsset) {
      return Image.asset(path, fit: BoxFit.contain);
    } else {
      return Image.file(File(path), fit: BoxFit.contain);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isEditMode = provider.editMode;

    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: provider.cardBgColor,
              borderRadius: BorderRadius.circular(16),
              border: provider.showBorder
                  ? Border.all(color: provider.borderColor, width: 4)
                  : null,
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
        ),
        if (isEditMode && onDelete != null)
          Positioned(
            right: -5,
            top: -5,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete, color: Colors.white, size: 28),
              ),
            ),
          ),
      ],
    );
  }
}
