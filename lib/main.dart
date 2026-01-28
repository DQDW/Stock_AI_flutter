import 'package:flutter/material.dart';
import 'dart:io'; // HttpOverrides 사용을 위해 추가
import 'package:provider/provider.dart';
import './providers/auth_provider.dart';
import './predict_list_screen.dart';
import './login_screen.dart';
import './widgets/main_drawer.dart';

void main() {
  // 개발용: 자가 서명 인증서(Self-Signed Certificate) 허용
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// SSL 인증서 에러 무시 클래스 (배포 시 제거하거나 수정 필요)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 앱 시작 시 로그인 상태 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).checkLoginStatus();
    });
  }

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

  void _navigateTo(BuildContext context, Widget screen, {bool requireAuth = false}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (requireAuth && !authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요한 기능입니다.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AuthProvider의 상태를 구독
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isAuthenticated;

    return Scaffold(
      backgroundColor: Colors.white, // 배경색 흰색
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(isLoggedIn ? '환영합니다!' : ''),
      ),
      endDrawer: const MainDrawer(),
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
                    // 데이터 등록 기능도 로그인이 필요하다고 가정
                    _navigateTo(context, const HomeScreen(), requireAuth: true); 
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
                    _navigateTo(context, const PredictionListScreen(), requireAuth: true);
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
            const SizedBox(height: 20),
            // 로그인 상태에 따른 버튼 표시
            if (!isLoggedIn)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  '로그인 화면으로 이동 (Test)',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              TextButton(
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그아웃 되었습니다.')),
                    );
                  }
                },
                child: const Text(
                  '로그아웃',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
