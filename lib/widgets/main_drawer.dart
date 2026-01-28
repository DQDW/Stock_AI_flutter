import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../predict_list_screen.dart';
import '../login_screen.dart';
import '../providers/auth_provider.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  void _navigateTo(BuildContext context, Widget screen, {bool requireAuth = false}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (requireAuth && !authProvider.isAuthenticated) {
      Navigator.pop(context); // 드로어 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요한 기능입니다.')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    Navigator.pop(context); // 드로어 닫기
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isLoggedIn = authProvider.isAuthenticated;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF0066FF),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFF0066FF)),
            ),
            accountName: Text(
              isLoggedIn ? '사용자 님' : '로그인이 필요합니다',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              isLoggedIn ? '환영합니다!' : '여기를 눌러 로그인하세요',
              style: const TextStyle(color: Colors.white70),
            ),
            onDetailsPressed: isLoggedIn ? null : () {
              _navigateTo(context, const LoginScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('홈'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_outlined),
            title: const Text('예측 목록 조회'),
            onTap: () {
              _navigateTo(context, const PredictionListScreen(), requireAuth: true);
            },
          ),
          const Divider(),
          if (!isLoggedIn)
            ListTile(
              leading: const Icon(Icons.login_outlined),
              title: const Text('로그인'),
              onTap: () {
                _navigateTo(context, const LoginScreen());
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text('로그아웃'),
              onTap: () async {
                Navigator.pop(context);
                await authProvider.logout();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('로그아웃 되었습니다.')),
                  );
                }
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
