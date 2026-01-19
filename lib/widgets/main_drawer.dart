import 'package:flutter/material.dart';
import '../main.dart';
import '../predict_list_screen.dart';
import '../login_screen.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // 드로어 닫기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF0066FF),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person, size: 40, color: Color(0xFF0066FF)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '로그인이 필요합니다',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '여기를 눌러 로그인하세요',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('홈'),
            onTap: () {
              // 현재 화면이 HomeScreen인지 확인 후 이동
              if (ModalRoute.of(context)?.settings.name == '/') {
                Navigator.pop(context);
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text('예측 목록 조회'),
            onTap: () {
              Navigator.pop(context); // 드로어 닫기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PredictionListScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.login_outlined),
            title: const Text('로그인'),
            onTap: () {
              Navigator.pop(context); // 드로어 닫기
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('설정'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
