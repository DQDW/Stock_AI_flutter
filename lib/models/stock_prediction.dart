class StockPrediction {
  final int id;
  final String date;
  final String ticker;
  final String name;
  final double curPrice;
  final double predictPrice;
  final double predictGap;
  final String useYN;

  StockPrediction({
    required this.id,
    required this.date,
    required this.ticker,
    required this.name,
    required this.curPrice,
    required this.predictPrice,
    required this.predictGap,
    required this.useYN,
  });

  // JSON을 객체로 변환
  factory StockPrediction.fromJson(Map<String, dynamic> json) {
    return StockPrediction(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      date: json['date']?.toString() ?? '',
      ticker: json['ticker']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      curPrice: (json['curPrice'] is num) ? (json['curPrice'] as num).toDouble() : double.tryParse(json['curPrice']?.toString() ?? '0') ?? 0.0,
      predictPrice: (json['predictPrice'] is num) ? (json['predictPrice'] as num).toDouble() : double.tryParse(json['predictPrice']?.toString() ?? '0') ?? 0.0,
      predictGap: (json['predictGap'] is num) ? (json['predictGap'] as num).toDouble() : double.tryParse(json['predictGap']?.toString() ?? '0') ?? 0.0,
      useYN: json['useYN']?.toString() ?? 'N',
    );
  }

  // 등락률 계산 로직을 모델 안에 포함
  double get changeRate => (predictGap / curPrice) * 100;
}
