import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/stat_card.dart';
import 'scan_receipt_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  ProductsScreenState createState() => ProductsScreenState();
}

class ProductsScreenState extends State<ProductsScreen> {
  String _selectedFilter = 'Toate';
  List<Map<String, dynamic>> _allProducts = [];
  bool _isLoading = false;
  Map<String, int>? _stats;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getProducts();
      setState(() {
        _allProducts = response;
        _calculateStats();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la încărcarea produselor: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateStats() {
    final total = _allProducts.length;
    final expired = _allProducts.where((p) => (p['daysLeft'] as int? ?? 0) <= 0).length;
    final expiringSoon = _allProducts.where((p) {
      final daysLeft = p['daysLeft'] as int? ?? 0;
      return daysLeft > 0 && daysLeft <= 7;
    }).length;

    _stats = {
      'total': total,
      'expired': expired,
      'expiring_soon': expiringSoon,
    };
  }

  List<Map<String, dynamic>> get _filteredProducts {
    switch (_selectedFilter) {
      case 'Expirate':
        return _allProducts.where((p) => (p['daysLeft'] as int? ?? 0) <= 0).toList();
      case 'Aproape expirate':
        return _allProducts.where((p) {
          final daysLeft = p['daysLeft'] as int? ?? 0;
          return daysLeft > 0 && daysLeft <= 7;
        }).toList();
      case 'Valabile':
        return _allProducts.where((p) => (p['daysLeft'] as int? ?? 0) > 7).toList();
      default:
        return _allProducts;
    }
  }

  DateTime? _parseDate(String? dateString) {
    if (dateString == null) return null;
    try {
      // Încearcă să parseze formatul dd/mm/yyyy
      if (dateString.contains('/')) {
        final parts = dateString.split('/');
        if (parts.length == 3) {
          final day = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final year = int.parse(parts[2]);
          return DateTime(year, month, day);
        }
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

  void _editProduct(BuildContext context, Map<String, dynamic> product, int productIndex) {
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
          title: const Text('Editează Produs'),
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
              onPressed: () async {
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
                  'id': product['id']?.toString() ?? '',
                  'name': nameController.text.trim(),
                  'quantity': quantityController.text.trim(),
                  'category': selectedCategory,
                  'expiryDate': expiryDate.toIso8601String(),
                  'daysLeft': _calculateDaysLeft(expiryDate),
                  'price': '${priceController.text.trim()} MDL',
                };

                Navigator.of(context).pop();

                // Afișează loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const AlertDialog(
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 16),
                        Text('Se actualizează produsul...'),
                      ],
                    ),
                  ),
                );

                try {
                  // Apelează API pentru actualizare
                  await ApiService.updateProduct(product['id']?.toString() ?? '', updatedProduct);
                  
                  if (!context.mounted) return;
                  Navigator.of(context).pop(); // Închide loading
                  
                  // Actualizează lista locală
                  setState(() {
                    final allProductsIndex = _allProducts.indexWhere((p) => p['id'] == product['id']);
                    if (allProductsIndex != -1) {
                      _allProducts[allProductsIndex] = updatedProduct;
                      _calculateStats();
                    }
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produs actualizat cu succes!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop(); // Închide loading
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Eroare la actualizarea produsului: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Salvează'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produsele Mele'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem(value: 'Toate', child: Text('Toate')),
              PopupMenuItem(value: 'Expirate', child: Text('Expirate')),
              PopupMenuItem(value: 'Aproape expirate', child: Text('Aproape expirate')),
              PopupMenuItem(value: 'Valabile', child: Text('Valabile')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedFilter),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Statistici rapide
                if (_stats != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Total',
                            value: '${_stats!['total']}',
                            color: Colors.blue,
                            icon: Icons.inventory,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Expiră în 7 zile',
                            value: '${_stats!['expiring_soon']}',
                            color: Colors.orange,
                            icon: Icons.warning,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            title: 'Expirate',
                            value: '${_stats!['expired']}',
                            color: Colors.red,
                            icon: Icons.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Lista de produse
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadProducts,
                    child: _filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _allProducts.isEmpty 
                                      ? 'Nu există produse'
                                      : 'Nu există produse în această categorie',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _allProducts.isEmpty 
                                      ? 'Adaugă prima factură pentru a începe'
                                      : 'Încearcă o altă categorie',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getExpiryColor(product['daysLeft'] as int? ?? 0),
                                    child: Text(
                                      '${product['daysLeft'] ?? 0}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    product['name']?.toString() ?? 'Produs necunoscut',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${product['quantity']?.toString() ?? '1'} • ${product['category']?.toString() ?? 'Necategorizat'}'),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Expiră: ${_formatDate(product['expiryDate']?.toString())}',
                                        style: TextStyle(
                                          color: _getExpiryColor(product['daysLeft'] as int? ?? 0),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Editează'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Șterge'),
                                      ),
                                      PopupMenuItem(
                                        value: 'used',
                                        child: Text('Marchează ca folosit'),
                                      ),
                                    ],
                                    onSelected: (value) {
                                      _handleProductAction(context, product, value.toString(), index);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScanReceiptScreen()),
          );
          
          // Reîncarcă produsele dacă s-au adăugat unele noi
          if (result == true) {
            _loadProducts();
          }
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add),
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

  Future<void> _handleProductAction(BuildContext context, Map<String, dynamic> product, String action, int index) async {
    switch (action) {
      case 'edit':
        _editProduct(context, product, index);
        break;
      case 'delete':
        await _showDeleteConfirmation(context, product);
        break;
      case 'used':
        await _markAsUsed(context, product);
        break;
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Map<String, dynamic> product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmă ștergerea'),
        content: Text('Ești sigur că vrei să ștergi ${product['name']?.toString() ?? 'acest produs'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Anulează'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Șterge'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteProduct(product['id']?.toString() ?? '');
        await _loadProducts(); // Reîncarcă produsele
        
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product['name']?.toString() ?? 'Produsul'} a fost șters'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la ștergerea produsului: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsUsed(BuildContext context, Map<String, dynamic> product) async {
    try {
      await ApiService.deleteProduct(product['id']?.toString() ?? '');
      await _loadProducts(); // Reîncarcă produsele
      
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product['name']?.toString() ?? 'Produsul'} marcat ca folosit'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}