import 'dart:convert';
import 'package:http/http.dart' as http;

class GoldApiProvider {
  // WARNING: Storing API keys directly in code is insecure for production apps.
  // Consider using environment variables or a secure configuration management approach.
  final String _apiKey = '9a3d8c0dd64594a0d616dff03e7594da'; // From context.md
  final String _baseUrl = 'https://api.metalpriceapi.com/v1';

  // Fetches the latest gold price for a specific currency (e.g., INR)
  Future<Map<String, dynamic>> getLatestGoldPrice(String currency) async {
    final url = Uri.parse(
        '$_baseUrl/latest?api_key=$_apiKey&base=XAU&currencies=$currency');

    print('Fetching gold rate from: $url'); // For debugging

    try {
      final response = await http.get(url);

      print('API Response Status: ${response.statusCode}'); // Debug
      print('API Response Body: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null &&
            data['rates'] != null &&
            data['rates'][currency] != null) {
          // The API gives price per OUNCE. We need per GRAM.
          // 1 Troy Ounce = 31.1035 grams (approx)
          double pricePerOunce =
              1 / data['rates'][currency]; // Price of 1 oz Gold in INR
          double pricePerGram = pricePerOunce / 31.1035;

          return {
            'success': true,
            'rate_per_gram': pricePerGram,
            'currency': currency,
            'timestamp': data['timestamp'] ??
                DateTime.now().millisecondsSinceEpoch ~/ 1000,
          };
        } else {
          print('API Error: Invalid data format in response');
          return {'success': false, 'error': 'Invalid data format from API'};
        }
      } else {
        print('API Error: Status code ${response.statusCode}');
        // Attempt to parse error message if available
        String errorMessage =
            'Failed to fetch gold price (Code: ${response.statusCode})';
        try {
          final errorData = json.decode(response.body);
          if (errorData != null && errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // Ignore parsing error, use default message
        }
        return {'success': false, 'error': errorMessage};
      }
    } catch (e) {
      print('API Exception: $e');
      return {'success': false, 'error': 'Network error or exception: $e'};
    }
  }
}
