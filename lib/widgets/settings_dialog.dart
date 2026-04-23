import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  Widget _colorBtn(Color c, BuildContext context, AppProvider provider, {bool isBorder = false, IconData? icon}) {
    return GestureDetector(
      onTap: () {
        if (isBorder) {
          provider.setBorderColor(c);
        } else {
          provider.setCardBgColor(c);
        }
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

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
                  const Expanded(
                    child: Text("Modalità Modifica", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))
                  ),
                  Switch(
                    value: provider.editMode,
                    activeColor: Colors.red,
                    onChanged: (val) {
                      provider.toggleEditMode(val);
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            const Text("Dimensione Simboli:", style: TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: provider.imageScale,
              min: 0.5,
              max: 3.0,
              onChanged: (val) {
                provider.setImageScale(val);
              },
            ),
            const SizedBox(height: 16),
            const Text("Sfondo della carta:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _colorBtn(Colors.white, context, provider),
                _colorBtn(Colors.yellow[200]!, context, provider),
                _colorBtn(Colors.green[200]!, context, provider),
                _colorBtn(Colors.blue[100]!, context, provider),
                _colorBtn(Colors.pink[100]!, context, provider),
                _colorBtn(Colors.transparent, context, provider, icon: Icons.format_color_reset),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Mostra bordo:", style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: provider.showBorder,
                  onChanged: (val) {
                    provider.setShowBorder(val);
                  },
                ),
              ],
            ),
            if (provider.showBorder) ...[
              const SizedBox(height: 8),
              const Text("Colore Bordo:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _colorBtn(Colors.black, context, provider, isBorder: true),
                  _colorBtn(Colors.red, context, provider, isBorder: true),
                  _colorBtn(Colors.blue, context, provider, isBorder: true),
                  _colorBtn(Colors.green, context, provider, isBorder: true),
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
}
