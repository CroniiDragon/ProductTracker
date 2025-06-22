import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/api_service.dart';
import 'processing_result_screen.dart';

class UploadReceiptScreen extends StatefulWidget {
  const UploadReceiptScreen({super.key});

  @override
  UploadReceiptScreenState createState() => UploadReceiptScreenState();
}

class UploadReceiptScreenState extends State<UploadReceiptScreen> {
  String? _fileName;
  bool _isProcessing = false;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
          _isProcessing = true;
        });

        // Procesează fișierul prin API
        final file = File(result.files.single.path!);
        await _processFile(file);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la încărcarea fișierului: $e')),
      );
    }
  }

  Future<void> _processFile(File file) async {
    try {
      final analysisResult = await ApiService.analyzeInvoice(file);
      
      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;

      // Navighează la ecranul de rezultate
      final success = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ProcessingResultScreen(
            image: file,
            analysisResult: analysisResult,
          ),
        ),
      );
      
      // Dacă produsele au fost salvate cu succes, întoarce-te cu rezultat pozitiv
      if (success == true && mounted) {
        Navigator.of(context).pop(true);
      }
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare la procesarea fișierului: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Încarcă Factură'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _fileName ?? 'Niciun fișier selectat',
                      style: TextStyle(
                        fontSize: 16,
                        color: _fileName != null ? Colors.black : Colors.grey[600],
                        fontWeight: _fileName != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Formate acceptate: PDF, JPG, PNG',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            if (_isProcessing) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Se procesează fișierul cu AI...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Selectează Fișier'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}