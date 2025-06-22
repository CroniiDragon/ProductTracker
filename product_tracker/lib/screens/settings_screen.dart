import 'package:flutter/material.dart';
import '../widgets/settings_dialogs.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Setări'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Notificări'),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificări produse'),
            subtitle: const Text('Primește alerte pentru produsele care expiră'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
              activeColor: const Color(0xFF2E7D32),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Avertisment în avans'),
            subtitle: const Text('Cu câte zile înainte să fii notificat'),
            trailing: DropdownButton<int>(
              value: 3,
              items: [1, 2, 3, 5, 7].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value zile'),
                );
              }).toList(),
              onChanged: (int? newValue) {},
            ),
          ),
          
          _buildSectionHeader('Aplicație'),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Limba'),
            subtitle: const Text('Română'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              SettingsDialogs.showLanguageDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Temă întunecată'),
            trailing: Switch(
              value: false,
              onChanged: (value) {},
              activeColor: const Color(0xFF2E7D32),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Gestionare date'),
            subtitle: const Text('Exportă sau șterge datele'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              SettingsDialogs.showDataManagementDialog(context);
            },
          ),
          
          _buildSectionHeader('Suport'),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Ajutor'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              SettingsDialogs.showHelpDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Despre aplicație'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              SettingsDialogs.showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Evaluează aplicația'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mulțumim pentru feedback!')),
              );
            },
          ),
          
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Versiunea 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E7D32),
        ),
      ),
    );
  }
}