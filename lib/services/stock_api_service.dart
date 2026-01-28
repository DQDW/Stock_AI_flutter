import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/stock_prediction.dart';
import 'auth_service.dart';

class StockApiService {
  final AuthService _authService = AuthService();

  static String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api/stocks';
    return 'http://10.46.9.8:8080/api/stocks';
  }

  Future<List<StockPrediction>> fetchStocks({
    String? search,
    String? ticker,
    String? name,
    String? date,
    String? startDate,
    String? endDate,
    String? useYN,
  }) async {
    var url = Uri.parse(_baseUrl);
    
    // ... (중략: queryParams 설정 로직은 동일)
    Map<String, String> queryParams = {};
    if (search != null && search.isNotEmpty) {
      final isTicker = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(search);
      if (isTicker) {
        queryParams['ticker'] = search;
      } else {
        queryParams['name'] = search;
      }
    }
    if (ticker != null && ticker.isNotEmpty) queryParams['ticker'] = ticker;
    if (name != null && name.isNotEmpty) queryParams['name'] = name;
    if (date != null) queryParams['date'] = date;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;
    if (useYN != null) queryParams['useYN'] = useYN;

    if (queryParams.isNotEmpty) {
      url = url.replace(queryParameters: queryParams);
    }

    print('Requesting: $url');

    try {
      // 1. 토큰 가져오기
      final token = await _authService.getToken();

      // 2. 헤더에 토큰 추가
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        print('Response Body: $decodedBody');

        final List<dynamic> decodedData = json.decode(decodedBody);
        return decodedData
            .map((json) => StockPrediction.fromJson(json))
            .toList();
      } else {
        print('Error Response: ${response.body}');
        throw Exception(
          'Failed to load stocks (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      print('Service Error: $e');
      rethrow;
    }
  }
}
