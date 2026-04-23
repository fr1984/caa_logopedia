import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SentenceBar extends StatelessWidget {
  const SentenceBar({super.key});

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
    final sentence = provider.sentence;

    return Container(
      height: 140,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sentence.length,
              itemBuilder: (context, index) {
                final sym = sentence[index];
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 16, top: 12),
                      width: 100,
                      decoration: BoxDecoration(
                        color: provider.cardBgColor,
                        borderRadius: BorderRadius.circular(12),
                        border: provider.showBorder
                            ? Border.all(color: provider.borderColor, width: 2)
                            : null,
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
                        onTap: () => provider.removeSymbolFromSentence(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 28),
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
              onPressed: sentence.isEmpty ? null : () => provider.playSentence(),
              backgroundColor: sentence.isEmpty ? Colors.grey : Colors.green,
              child: const Icon(Icons.play_arrow, size: 60, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
