import 'package:flutter/material.dart';
import 'dart:io';
import '../services/api_service.dart';

class ProcessingResultScreen extends StatefulWidget {
  final File image;
  final Map<String, dynamic> analysisResult;

  const ProcessingResultScreen({
    super.key, 
    required this.image,
    required this.analysisResult,
  });

  @override
  ProcessingResultScreenState createState() => ProcessingResultScreenState();
}

class ProcessingResultScreenState extends State<ProcessingResultScreen> {
  late List<Map<String, dynamic>> _products;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeProducts();
  }

  void _initializeProducts() {
    if (widget.analysisResult['products'] != null) {
      _products = List<Map<String, dynamic>>.from(widget.analysisResult['products']);
    } else if (widget.analysisResult['result'] != null && 
               widget.analysisResult['result']['invoice'] != null) {
      // Transformă datele din formatul vechi în cel nou
      final List<dynamic> invoiceItems = widget.analysisResult['result']['invoice'];
      _products = invoiceItems.map((item) {
        final now = DateTime.now();
        final expiryDate = now.add(const Duration(days: 30));
        return <String, dynamic>{
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': item['Product']?.toString() ?? '',
          'quantity': item['Stock']?.toString() ?? '1',
          'expiryDate': expiryDate.toIso8601String(),
          'daysLeft': 30,
          'category': 'Necategorizat',
          'price': '0.00 MDL',
        };
      }).toList();
    } else {
      _products = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezultat Procesare'),
        actions: [
          if (_products.isNotEmpty)
            IconButton(
              onPressed: _isSaving ? null : () => _saveProducts(context),
              icon: _isSaving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
            ),
        ],
      ),
      body: Column(
        children: [
          // Imaginea scanată
          SizedBox(
            height: 200,
            width: double.infinity,
            child: Image.file(
              widget.image,
              fit: BoxFit.cover,
            ),
          ),
          
          // Header cu numărul de produse
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  _products.isEmpty ? Icons.error_outline : Icons.check_circle, 
                  color: _products.isEmpty ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  _products.isEmpty 
                      ? 'Nu s-au detectat produse'
                      : 'Găsite ${_products.length} produse',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_products.isNotEmpty)
                  TextButton.icon(
                    onPressed: _addNewProduct,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Adaugă'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                    ),
                  ),
              ],
            ),
          ),
          
          // Lista de produse sau mesaj gol
          Expanded(
            child: _products.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nu s-au putut detecta produse',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Poți adăuga manual sau încearcă cu o imagine mai clară',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _products.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getExpiryColor(product['daysLeft'] as int? ?? 30),
                            child: Text(
                              '${product['daysLeft'] ?? 30}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            product['name']?.toString() ?? 'Produs necunoscut',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${product['quantity']?.toString() ?? '1'} • ${product['category']?.toString() ?? 'Necategorizat'}'),
                              const SizedBox(height: 2),
                              Text(
                                'Expiră: ${_formatDate(product['expiryDate']?.toString())}',
                                style: TextStyle(
                                  color: _getExpiryColor(product['daysLeft'] as int? ?? 30),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _editProduct(context, product, index),
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Editează',
                              ),
                              IconButton(
                                onPressed: () => _deleteProduct(index),
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Șterge',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          
          // Butonul de salvare
          if (_products.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : () => _saveProducts(context),
                icon: _isSaving 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Se salvează...' : 'Salvează Produsele'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getExpiryColor(int daysLeft) {
    if (daysLeft <= 0) return Colors.red;
    if (daysLeft <= 3) return Colors.red[400]!;
    if (daysLeft <= 7) return Colors.orange;
    return Colors.green;
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Necunoscută';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Necunoscută';
    }
  }

  DateTime? _parseDate(String dateString) {
    try {
      // Încearcă să parseze formatul dd/mm/yyyy
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      // Încearcă să parseze formatul ISO
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  int _calculateDaysLeft(DateTime? expiryDate) {
    if (expiryDate == null) return 0;
    final now = DateTime.now();
    final difference = expiryDate.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  void _addNewProduct() {
    final newProduct = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': '',
      'quantity': '1',
      'expiryDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'daysLeft': 30,
      'category': 'Necategorizat',
      'price': '0.00 MDL',
    };
    
    _editProduct(context, newProduct, -1, isNew: true);
  }

  void _editProduct(BuildContext context, Map<String, dynamic> product, int index, {bool isNew = false}) {
    final nameController = TextEditingController(text: product['name']?.toString() ?? '');
    final quantityController = TextEditingController(text: product['quantity']?.toString() ?? '1');
    final priceText = product['price']?.toString() ?? '0.00 MDL';
    final priceController = TextEditingController(text: priceText.replaceAll(' MDL', '').replaceAll('MDL', '').trim());
    final expiryController = TextEditingController(text: _formatDate(product['expiryDate']?.toString()));
    
    final categories = [
      'Necategorizat',
      'Lactate',
      'Carne și pește',
      'Fructe și legume',
      'Băuturi',
      'Pâine și produse de patiserie',
      'Conserve',
      'Produse congelate',
      'Produse de igienă',
      'Alte produse',
    ];
    
    // Verifică dacă categoria există în listă, dacă nu, folosește 'Necategorizat'
    String selectedCategory = product['category']?.toString() ?? 'Necategorizat';
    if (!categories.contains(selectedCategory)) {
      selectedCategory = 'Necategorizat';
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isNew ? 'Adaugă Produs Nou' : 'Editează Produs'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nume produs *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Cantitate *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Preț (MDL)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setDialogState(() {
                        selectedCategory = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: expiryController,
                  decoration: const InputDecoration(
                    labelText: 'Data expirării (dd/mm/yyyy) *',
                    hintText: '25/12/2025',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final currentDate = _parseDate(expiryController.text) ?? DateTime.now().add(const Duration(days: 30));
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: currentDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    
                    if (pickedDate != null) {
                      expiryController.text = '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validare
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Numele produsului este obligatoriu'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                
                if (quantityController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cantitatea este obligatorie'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final expiryDate = _parseDate(expiryController.text);
                if (expiryDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data expirării nu este validă. Folosește formatul dd/mm/yyyy'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // Actualizează produsul
                final updatedProduct = <String, dynamic>{
                  'id': product['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': nameController.text.trim(),
                  'quantity': quantityController.text.trim(),
                  'category': selectedCategory,
                  'expiryDate': expiryDate.toIso8601String(),
                  'daysLeft': _calculateDaysLeft(expiryDate),
                  'price': '${priceController.text.trim()} MDL',
                };

                setState(() {
                  if (isNew) {
                    _products.add(updatedProduct);
                  } else {
                    _products[index] = updatedProduct;
                  }
                });
                
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isNew ? 'Produs adăugat!' : 'Produs actualizat!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(isNew ? 'Adaugă' : 'Salvează'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmă ștergerea'),
        content: Text('Ești sigur că vrei să ștergi "${_products[index]['name']?.toString() ?? 'acest produs'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anulează'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _products.removeAt(index);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Produs șters'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Șterge', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProducts(BuildContext context) async {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nu există produse de salvat'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      int savedCount = 0;
      
      // Salvează fiecare produs prin API
      for (final product in _products) {
        await ApiService.saveProduct(product);
        savedCount++;
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$savedCount produse au fost salvate cu succes!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navighează înapoi la ecranul principal
      Navigator.of(context).popUntil((route) => route.isFirst);
      
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare la salvarea produselor: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}