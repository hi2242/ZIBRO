import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DriversMarkerScreen extends StatefulWidget {
  const DriversMarkerScreen({super.key});

  @override
  _DriversMarkerScreenState createState() => _DriversMarkerScreenState();
}

class _DriversMarkerScreenState extends State<DriversMarkerScreen> {
  final _XController = TextEditingController();
  final _YController = TextEditingController();

  Future<void> _saveToFile() async {
    // 필수 필드 체크
    if (_XController.text.isEmpty || _YController.text.isEmpty) {
      _showDialog("오류", "모든 정보를 입력하세요.", false); // false -> 화면을 나가지 않게 설정
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/drivers_marker.txt');
      final data = '''
X: ${_XController.text}
Y: ${_YController.text}
''';
      // 파일에 데이터를 추가하는 방식으로 저장
      await file.writeAsString(data, mode: FileMode.append);

      // 회원가입 성공 다이얼로그 표시
      _showDialog(
          "저장 성공", "마커 저장이 완료되었습니다.", true); // true -> 회원가입 후 로그인 화면으로 돌아가기
    } catch (e) {
      print('Error saving data to file: $e');
      _showDialog("오류", "파일 저장 중 문제가 발생했습니다.", false); // false -> 화면을 나가지 않게 설정
    }
  }

  @override
  void dispose() {
    _XController.dispose();
    _YController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitle('마커 정보 입력'),
              _buildTextField('위도', _XController),
              _buildTextField('경도', _YController),
              const SizedBox(height: 20),
              _buildSubmitButton(context, '저장하기', _saveToFile),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialog(String title, String message, bool goToLoginScreen) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // 다이얼로그 닫기
                if (goToLoginScreen) {
                  Navigator.pop(context); // 회원가입 화면 종료하고 로그인 화면으로 돌아가기
                }
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
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
