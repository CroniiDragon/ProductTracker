import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Înlocuiește cu URL-ul real al backend-ului tău
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  // Pentru Android emulator folosește: 'http://10.0.2.2:8000'
  // Pentru device fizic folosește: 'http://YOUR_IP:8000'
  
  static const String analyzeEndpoint = '$baseUrl/api/analyze';

  /// Analizează o factură prin încărcarea unui fișier
  static Future<Map<String, dynamic>> analyzeInvoice(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(analyzeEndpoint));
      
      // Adaugă fișierul la request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // numele câmpului din backend
          imageFile.path,
        ),
      );

      // Trimite request-ul
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Eroare la analizarea facturii: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Eroare de rețea: $e', 0);
    }
  }

  /// Obține toate produsele salvate
  static Future<List<Map<String, dynamic>>> getProducts({String? filter}) async {
    try {
      String url = '$baseUrl/api/products';
      if (filter != null) {
        url += '?filter_type=$filter';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['products'] ?? []);
      } else {
        throw ApiException(
          'Eroare la obținerea produselor: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Eroare de rețea: $e', 0);
    }
  }

  /// Obține statistici despre produse
  static Future<Map<String, int>> getProductsStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'total': data['total'] ?? 0,
          'expired': data['expired'] ?? 0,
          'expiring_soon': data['expiring_soon'] ?? 0,
          'fresh': data['fresh'] ?? 0,
        };
      } else {
        throw ApiException(
          'Eroare la obținerea statisticilor: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Eroare de rețea: $e', 0);
    }
  }

  /// Salvează un produs
  static Future<Map<String, dynamic>> saveProduct(Map<String, dynamic> product) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Eroare la salvarea produsului: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Eroare de rețea: $e', 0);
    }
  }

  /// Actualizează un produs existent
  static Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> product) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/products/$productId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException(
          'Eroare la actualizarea produsului: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Eroare de rețea: $e', 0);
    }
  }

  /// Șterge un produs
  static Future<void> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/products/$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          'Eroare la ștergerea produsului: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Eroare de rețea: $e', 0);
    }
  }
}

/// Clasă pentru excepții API
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}