import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';

class MapPage extends StatelessWidget {
  final void Function(int alley) onSelect;
  const MapPage({super.key, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF2C1A0E),
      appBar: AppBar(backgroundColor: const Color(0xFF1A1009), title: Text(l10n.locale.languageCode=='en' ? 'Nebelheim Map' : 'Mapa de Nebelheim', style: const TextStyle(color: Colors.amber))),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: 8,
            itemBuilder: (_, i) => InkWell(
              onTap: () { Navigator.pop(context); onSelect(i+1); },
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.location_on, color: Colors.brown),
                  Text('${l10n.locale.languageCode=='en' ? 'Alley' : 'Callejón'} ${i+1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
