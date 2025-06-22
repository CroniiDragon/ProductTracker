import 'package:flutter/material.dart';

class SettingsDialogs {
  static void showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selectează limba'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Română'),
              value: 'ro',
              groupValue: 'ro',
              onChanged: (value) {
                Navigator.of(context).pop();
              },
              activeColor: const Color(0xFF2E7D32),
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: 'ro',
              onChanged: (value) {
                Navigator.of(context).pop();
              },
              activeColor: const Color(0xFF2E7D32),
            ),
            RadioListTile<String>(
              title: const Text('Русский'),
              value: 'ru',
              groupValue: 'ro',
              onChanged: (value) {
                Navigator.of(context).pop();
              },
              activeColor: const Color(0xFF2E7D32),
            ),
          ],
        ),
      ),
    );
  }

  static void showDataManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestionare date'),
        content: const Text('Alege ce dorești să faci cu datele tale:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Datele au fost exportate')),
              );
            },
            child: const Text('Exportă'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showDeleteAllDataDialog(context);
            },
            child: const Text('Șterge tot', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anulează'),
          ),
        ],
      ),
    );
  }

  static void _showDeleteAllDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atenție!'),
        content: const Text('Această acțiune va șterge permanent toate datele tale. Ești sigur?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anulează'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toate datele au fost șterse'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Șterge tot', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajutor'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cum să folosești aplicația:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Scanează sau încarcă o factură fiscală'),
              SizedBox(height: 4),
              Text('2. Verifică produsele detectate'),
              SizedBox(height: 4),
              Text('3. Salvează produsele în aplicație'),
              SizedBox(height: 4),
              Text('4. Primește notificări despre expirare'),
              SizedBox(height: 16),
              Text(
                'Pentru suport tehnic:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Email: support@monitorproduse.md'),
              Text('Telefon: +373 XX XXX XXX'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Închide'),
          ),
        ],
      ),
    );
  }

  static void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Despre aplicație'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Monitor Produse',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Versiunea 1.0.0'),
              SizedBox(height: 16),
              Text(
                'O aplicație dezvoltată special pentru micile afaceri din Moldova pentru a gestiona eficient produsele și a preveni risipa alimentară.',
              ),
              SizedBox(height: 16),
              Text(
                'Funcționalități:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Scanare automată a facturilor'),
              Text('• Detectare produse cu AI'),
              Text('• Notificări de expirare'),
              Text('• Gestionare inventar'),
              SizedBox(height: 16),
              Text(
                'Tehnologii folosite:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Flutter pentru interfață'),
              Text('• Python pentru backend'),
              Text('• MistralAI pentru procesare'),
              Text('• OCR pentru recunoaștere text'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Închide'),
          ),
        ],
      ),
    );
  }
}