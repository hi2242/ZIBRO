import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DriversSignUpScreen extends StatefulWidget {
  const DriversSignUpScreen({super.key});

  @override
  _DriversSignUpScreenState createState() => _DriversSignUpScreenState();
}

class _DriversSignUpScreenState extends State<DriversSignUpScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _vehicleSizeController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _companyController = TextEditingController();
  final _accountNumberController = TextEditingController();

  String _selectedGender = "남성";

  Future<void> _saveToFile() async {
    // 필수 필드 체크
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _birthDateController.text.isEmpty ||
        _vehicleTypeController.text.isEmpty ||
        _vehicleNumberController.text.isEmpty ||
        _vehicleSizeController.text.isEmpty ||
        _licenseNumberController.text.isEmpty ||
        _companyController.text.isEmpty ||
        _accountNumberController.text.isEmpty) {
      _showDialog("오류", "모든 정보를 입력하세요.", false); // false -> 화면을 나가지 않게 설정
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/drivers_data.txt');
      final data = '''
Username: ${_usernameController.text}
Password: ${_passwordController.text}
Name: ${_nameController.text}
Gender: $_selectedGender
Birth Date: ${_birthDateController.text}
Vehicle Type: ${_vehicleTypeController.text}
Vehicle Number: ${_vehicleNumberController.text}
Vehicle Size: ${_vehicleSizeController.text}
License Number: ${_licenseNumberController.text}
Company: ${_companyController.text}
Account: ${_accountNumberController.text}
''';
      await file.writeAsString(data);

      // 회원가입 성공 다이얼로그 표시
      _showDialog(
          "회원가입 성공", "회원가입이 완료되었습니다.", true); // true -> 회원가입 후 로그인 화면으로 돌아가기
    } catch (e) {
      print('Error saving data to file: $e');
      _showDialog("오류", "파일 저장 중 문제가 발생했습니다.", false); // false -> 화면을 나가지 않게 설정
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _birthDateController.dispose();
    _vehicleTypeController.dispose();
    _vehicleNumberController.dispose();
    _vehicleSizeController.dispose();
    _licenseNumberController.dispose();
    _companyController.dispose();
    _accountNumberController.dispose();
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
              _buildTitle('운전자 정보 입력'),
              _buildTextField('아이디', _usernameController),
              _buildTextField('비밀번호', _passwordController, obscureText: true),
              _buildTextField('이름', _nameController),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGender = "남성";
                        });
                      },
                      child: _buildGenderOption('남성', _selectedGender == "남성"),
                    ),
                  ),
                  const SizedBox(width: 8), // 선택지 간 간격
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGender = "여성";
                        });
                      },
                      child: _buildGenderOption('여성', _selectedGender == "여성"),
                    ),
                  ),
                ],
              ),
              _buildTextField('생년월일', _birthDateController),
              _buildTextField('차량종류', _vehicleTypeController),
              _buildTextField('차량크기', _vehicleSizeController),
              _buildTextField('차량번호', _vehicleNumberController),
              _buildTextField('소속회사', _companyController),
              _buildTextField('기사면허증 첨부', _licenseNumberController),
              _buildTextField('계좌번호', _accountNumberController),
              const SizedBox(height: 20),
              _buildSubmitButton(context, '가입하기', _saveToFile),
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
                // goToLoginScreen이 true일 때만 로그인 화면으로 돌아가기
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

Widget _buildGenderOption(String label, bool selected) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: selected ? const Color(0xFF111416) : const Color(0xFFDBE0E5),
        width: 2,
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF111416),
            fontSize: 14,
            fontFamily: 'Be Vietnam Pro',
            fontWeight: FontWeight.w500,
          ),
        ),
        if (selected)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF111416), width: 2),
            ),
            child: const Icon(
              Icons.circle,
              size: 14,
              color: Color(0xFF3387E5),
            ),
          ),
      ],
    ),
  );
}