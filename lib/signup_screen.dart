import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import './providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  
  String _selectedGender = '남성';

  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register(
        id: _idController.text,
        password: _pwController.text,
        name: _nameController.text,
        gender: _selectedGender,
        birthDate: _birthDateController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 성공! 로그인해주세요.')),
        );
        Navigator.pop(context); // 로그인 화면으로 복귀
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원가입 실패: 다시 시도해주세요.')),
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
          '회원가입',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0066FF),
                ),
              ),
              const SizedBox(height: 32),
              
              // 아이디 입력
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: '아이디',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '아이디를 입력해주세요.';
                  }
                  if (value.length < 4) {
                    return '아이디는 4자 이상이어야 합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 이름 입력
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: '이름',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 성별 및 생년월일
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      isExpanded: true, // 내부 텍스트가 넘치지 않도록 설정
                      decoration: InputDecoration(
                        labelText: '성별',
                        prefixIcon: const Icon(Icons.wc_outlined),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 패딩 최적화
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: ['남성', '여성'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: const TextStyle(fontSize: 14)), // 폰트 크기 조정
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedGender = newValue!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8), // 간격을 16에서 8로 줄임
                  Expanded(
                    flex: 3, // 비율을 1:2에서 2:3으로 조정하여 좀 더 균형 있게 배치
                    child: TextFormField(
                      controller: _birthDateController,
                      readOnly: true,
                      style: const TextStyle(fontSize: 14), // 폰트 크기 조정
                      decoration: InputDecoration(
                        labelText: '생년월일',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        hintText: 'YYYY-MM-DD',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime(2000),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                          setState(() {
                            _birthDateController.text = formattedDate;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '생년월일을 선택해주세요.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 비밀번호 입력
              TextFormField(
                controller: _pwController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해주세요.';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 6자 이상이어야 합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 비밀번호 확인
              TextFormField(
                controller: _pwConfirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 다시 입력해주세요.';
                  }
                  if (value != _pwController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // 회원가입 버튼
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        '가입하기',
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
