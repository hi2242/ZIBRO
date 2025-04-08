import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:texi_application/pages/Passenger_home1.dart';
import 'package:texi_application/pages/passenger_sign_up_page.dart';

class PassengerLoginPage extends StatefulWidget {
  const PassengerLoginPage({super.key});

  @override
  _PassengerLoginPage createState() => _PassengerLoginPage();
}

class _PassengerLoginPage extends State<PassengerLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // 로그인 로직
  Future<void> _login() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/passengers_data.txt');

      if (await file.exists()) {
        final data = await file.readAsString();
        final lines = data.split('\n');
        String? savedUsername;
        String? savedPassword;
        Map<String, String> parsedData = {};

        for (var line in lines) {
          if (line.contains(':')) {
            final parts = line.split(':');
            if (parts.length == 2) {
              parsedData[parts[0].trim()] = parts[1].trim();
            }
          }
        }
        savedUsername = parsedData['Username'];
        savedPassword = parsedData['Password'];
        if (savedUsername == _usernameController.text &&
            savedPassword == _passwordController.text) {
          // 로그인 성공
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PassengerHomePage1(),
            ),
          );
        } else {
          // 로그인 실패
          _showErrorDialog('로그인 실패', '아이디 또는 비밀번호가 잘못되었습니다.');
        }
      } else {
        _showErrorDialog('파일 없음', '등록된 사용자가 없습니다.');
      }
    } catch (e) {
      _showErrorDialog('오류', '로그인 중 문제가 발생했습니다: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          '탑승자 로그인',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitle('로그인'),
              _buildTextField('아이디', _usernameController),
              _buildTextField('비밀번호', _passwordController, obscureText: true),
              const SizedBox(height: 20),
              _buildSubmitButton(context, '로그인', _login),
              const SizedBox(height: 20),
              _buildSubmitButton(context, '회원가입', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PassengerSignUpPage()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF2F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: label,
              border: InputBorder.none,
            ),
            style: const TextStyle(
              color: Color(0xFF637287),
              fontSize: 16,
              fontFamily: 'Be Vietnam Pro',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: const Color(0xFF3387E5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Be Vietnam Pro',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF111416),
          fontSize: 26,
          fontFamily: 'Be Vietnam Pro',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
