import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/stock_prediction.dart';
import 'services/stock_api_service.dart';
import 'widgets/main_drawer.dart';

class PredictionListScreen extends StatefulWidget {
  const PredictionListScreen({super.key});

  @override
  State<PredictionListScreen> createState() => _PredictionListScreenState();
}

class _PredictionListScreenState extends State<PredictionListScreen> {
  final currencyFormat = NumberFormat("#,###"); // 3자리마다 콤마
  final dateFormat = DateFormat('yyyy-MM-dd');
  final _apiService = StockApiService();

  // 검색 조건
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'name'; // 'name' or 'ticker'
  DateTimeRange? _selectedDateRange;

  // 화면에 보여줄 모델 리스트
  List<StockPrediction> _displayList = [];
  bool _isLoading = false;

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  String get _dateRangeText {
    if (_selectedDateRange == null) return '날짜 범위 선택';
    return '${dateFormat.format(_selectedDateRange!.start)} ~ ${dateFormat.format(_selectedDateRange!.end)}';
  }

  Future<void> _searchData() async {
    FocusScope.of(context).unfocus();

    print('Starting search...');
    setState(() => _isLoading = true);

    try {
      final results = await _apiService.fetchStocks(
        name: _searchType == 'name' ? _searchController.text : null,
        ticker: _searchType == 'ticker' ? _searchController.text : null,
        startDate: _selectedDateRange != null
            ? dateFormat.format(_selectedDateRange!.start)
            : null,
        endDate: _selectedDateRange != null
            ? dateFormat.format(_selectedDateRange!.end)
            : null,
        useYN: 'Y', // 기본적으로 사용 중인 데이터만 조회
      );

      print('Search completed, found ${results.length} items');
      setState(() {
        _displayList = results;
        _isLoading = false;
      });
    } catch (e) {
      print('UI Layer Error: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('에러 발생: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '예측 목록 조회',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),
      endDrawer: const MainDrawer(),
      body: Column(
        children: [
          _buildSearchHeader(),
          _buildListHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              // 검색 타입 선택 드롭다운
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _searchType,
                    items: const [
                      DropdownMenuItem(value: 'name', child: Text('종목명')),
                      DropdownMenuItem(value: 'ticker', child: Text('종목코드')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _searchType = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 검색어 입력 필드
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: '검색어 입력',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _pickDateRange,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _dateRangeText,
                          style: TextStyle(
                            color: _selectedDateRange == null
                                ? Colors.grey[600]
                                : Colors.black,
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _searchData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 20,
                  ),
                ),
                child: const Text(
                  '조회',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.grey[100],
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '종목명',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '기준일',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '현재가',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '예측가',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '차이',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ▼▼▼ 여기가 끊겨있던 부분입니다. 완성했습니다. ▼▼▼
  Widget _buildBody() {
    // 1. 로딩 중
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    // 2. 데이터 없음
    if (_displayList.isEmpty) {
      return const Center(
        child: Text('조회된 데이터가 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }

    // 3. 데이터 리스트 출력 (이 부분이 없으면 에러가 납니다!)
    return ListView.builder(
      itemCount: _displayList.length,
      itemBuilder: (context, index) {
        final item = _displayList[index];

        // --- 값 계산 및 안전장치 ---
        double currentPrice = item.curPrice;
        double predictedPrice = item.predictPrice;
        double diffRate = 0.0;

        if (currentPrice != 0) {
          diffRate = ((predictedPrice - currentPrice) / currentPrice) * 100;
        }

        // 색상: 수익(빨강), 손실(파랑)
        Color valueColor = diffRate >= 0 ? Colors.red : Colors.blue;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
          ),
          child: Row(
            children: [
              // 종목명
              Expanded(
                flex: 3,
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // 기준일
              Expanded(
                flex: 2,
                child: Text(
                  item.date,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              // 현재가
              Expanded(
                flex: 2,
                child: Text(
                  currencyFormat.format(currentPrice),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              // 예측가
              Expanded(
                flex: 2,
                child: Text(
                  currencyFormat.format(predictedPrice),
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // 차이
              Expanded(
                flex: 2,
                child: Text(
                  '${diffRate.toStringAsFixed(1)}%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
