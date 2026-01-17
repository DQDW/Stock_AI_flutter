import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PredictionListScreen extends StatefulWidget {
  const PredictionListScreen({super.key});

  @override
  State<PredictionListScreen> createState() => _PredictionListScreenState();
}

class _PredictionListScreenState extends State<PredictionListScreen> {
  final currencyFormat = NumberFormat("#,###");
  final dateFormat = DateFormat('yyyy-MM-dd');

  // 검색 조건
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  // 1. 화면에 보여줄 실제 데이터 리스트 (처음엔 비어있음 [])
  List<Map<String, dynamic>> _displayList = [];

  // 2. DB에서 가져온 데이터라고 가정하는 '원본' 더미 데이터
  final List<Map<String, dynamic>> _dummyDbData = [
    {
      "name": "삼성전자",
      "curprice": 138100.0,
      "predictprice": 139224.0,
      "predictgap": 1124.0,
      "date": "2026-01-05",
      "ticker": "005930.KS",
    },
    {
      "name": "SK하이닉스",
      "curprice": 696000.0,
      "predictprice": 700490.0,
      "predictgap": 4490.0,
      "date": "2026-01-05",
      "ticker": "000660.KS",
    },
    {
      "name": "LG에너지솔루션",
      "curprice": 371500.0,
      "predictprice": 366794.0,
      "predictgap": -4706.0,
      "date": "2026-01-05",
      "ticker": "373220.KS",
    },
    {
      "name": "보잉",
      "curprice": 227.77,
      "predictprice": 227.32,
      "predictgap": -0.45,
      "date": "2026-01-04",
      "ticker": "BA",
    },
  ];

  // 날짜 선택 함수
  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0066FF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String get _dateRangeText {
    if (_selectedDateRange == null) {
      return '날짜 범위 선택';
    }
    return '${dateFormat.format(_selectedDateRange!.start)} ~ ${dateFormat.format(_selectedDateRange!.end)}';
  }

  // 3. 조회 버튼 눌렀을 때 실행되는 함수
  void _searchData() {
    // 키보드 내리기
    FocusScope.of(context).unfocus();

    // 로딩하는 척 0.5초 기다렸다가 데이터 보여주기 (리얼함 추가)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context); // 로딩창 끄기

      setState(() {
        // 더미 데이터를 화면용 리스트에 복사!
        // (나중에는 여기서 실제 DB API를 호출하면 됩니다)
        _displayList = List.from(_dummyDbData);
      });
    });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),
      body: Column(
        children: [
          // 검색 조건 영역
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: '종목명 또는 코드',
                    hintText: '예) 삼성전자, 005930',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                    isDense: true,
                  ),
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

                    // ========== [조회 버튼] ==========
                    ElevatedButton(
                      onPressed: _searchData, // 위에서 만든 함수 연결
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
          ),

          // 리스트 헤더
          Container(
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
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '현재가',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '예측가',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '차이',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // 데이터 리스트 영역
          Expanded(
            child: _displayList.isEmpty
                ? const Center(
                    child: Text(
                      "검색 조건을 입력하고\n[조회] 버튼을 눌러주세요.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: _displayList.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, thickness: 0.5),
                    itemBuilder: (context, index) {
                      final item = _displayList[index];
                      final double gap = item['predictgap'];
                      final double rate = (gap / item['curprice']) * 100;
                      final Color gapColor = gap > 0
                          ? Colors.red
                          : (gap < 0 ? Colors.blue : Colors.black);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    item['ticker'],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                item['date'].toString().substring(5),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                currencyFormat.format(item['curprice']),
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                currencyFormat.format(item['predictprice']),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    gap > 0
                                        ? "+${gap.toInt()}"
                                        : "${gap.toInt()}",
                                    style: TextStyle(
                                      color: gapColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "(${rate.toStringAsFixed(1)}%)",
                                    style: TextStyle(
                                      color: gapColor,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
