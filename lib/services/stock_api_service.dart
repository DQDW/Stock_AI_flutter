import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_prediction.dart';

class StockApiService {
  static const String _baseUrl = 'http://10.46.9.8:8080/api/stocks';

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

    Map<String, String> queryParams = {};

    // 1. Search (Generic) -> Ticker or Name
    if (search != null && search.isNotEmpty) {
      // Heuristic: If English/Numbers only -> Ticker, Otherwise (e.g. Korean) -> Name
      final isTicker = RegExp(r'^[a-zA-Z0-9]+$').hasMatch(search);
      if (isTicker) {
        queryParams['ticker'] = search;
      } else {
        queryParams['name'] = search;
      }
    }

    // 2. Specific Filters (Override generic search if provided)
    if (ticker != null && ticker.isNotEmpty) queryParams['ticker'] = ticker;
    if (name != null && name.isNotEmpty) queryParams['name'] = name;

    // 3. Date Filters
    if (date != null) queryParams['date'] = date;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    // 4. Usage Filter
    if (useYN != null) queryParams['useYN'] = useYN;

    if (queryParams.isNotEmpty) {
      url = url.replace(queryParameters: queryParams);
    }

    print('Requesting: $url');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

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
