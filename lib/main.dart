import 'package:flutter/material.dart';
import './predict_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 오른쪽 위 'Debug' 띠 제거
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색 흰색
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 세로 기준 중앙 정렬
          children: [
            // 1. 메인 타이틀
            const Text(
              'AiStock Prediction',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w300, // 얇은 글씨체 느낌
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10), // 타이틀과 서브타이틀 사이 간격
            // 2. 서브 타이틀
            const Text(
              'AI 기반 주가 예측 시스템',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 60), // 글자와 버튼 사이 큰 간격
            // 3. 버튼 영역 (가로 배치)
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 가로 기준 중앙 정렬
              children: [
                // 파란색 버튼 (예측 데이터 등록)
                ElevatedButton(
                  onPressed: () {
                    print('데이터 등록 버튼 클릭됨');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF), // 이미지와 비슷한 파란색
                    foregroundColor: Colors.white, // 글자색 흰색
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), // 모서리 둥글게
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                    minimumSize: const Size(160, 55), // 버튼 크기 고정
                  ),
                  child: const Text('예측 데이터 등록'),
                ),

                const SizedBox(width: 20), // 버튼 사이 간격
                // 흰색 버튼 (예측 목록 조회)
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PredictionListScreen(),
                      ),
                    );
                    print('목록 조회 버튼 클릭됨');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700], // 글자색 회색
                    side: const BorderSide(color: Colors.grey), // 테두리 색상
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                    minimumSize: const Size(160, 55), // 버튼 크기 고정
                  ),
                  child: const Text('예측 목록 조회'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
