import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:texi_application/pages/Passenger_home1.dart';
import 'package:texi_application/services/api_client.dart';
import 'package:texi_application/services/user_service.dart';

class PassengerSignUpPage extends StatefulWidget {
  const PassengerSignUpPage({super.key});

  @override
  State<PassengerSignUpPage> createState() => _PassengerSignUpPageState();
}

class _PassengerSignUpPageState extends State<PassengerSignUpPage> {
  // final bool _isMaleSelected = true;

  // 사용자 입력 필드 컨트롤러
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController universityController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // // 서버와의 통신을 위한 UserService 인스턴스 생성
  // final UserService userService =
  //     UserService(ApiClient("http://127.0.0.1:8000"));

  String _selectedGender = "남성";
  Future<void> _saveToFile() async {
    // 필수 필드 체크
    if (nameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        usernameController.text.isEmpty ||
        birthDateController.text.isEmpty ||
        universityController.text.isEmpty ||
        majorController.text.isEmpty ||
        phoneController.text.isEmpty) {
      _showDialog("오류", "모든 정보를 입력하세요.", false); // false -> 화면을 나가지 않게 설정
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/passengers_data.txt');
      final data = '''
Username: ${usernameController.text}
Password: ${passwordController.text}
Name: ${nameController.text}
Birth Date: ${birthDateController.text}
university: ${universityController.text}
major: ${majorController.text}
phone: ${phoneController.text}
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
    usernameController.dispose();
    passwordController.dispose();
    nameController.dispose();
    birthDateController.dispose();
    universityController.dispose();
    majorController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // // 사용자 정보를 서버로 전송하는 함수
  // Future<void> _submitForm(BuildContext context) async {
  //   try {
  //     // 사용자 입력 데이터를 서버에 전달할 형식으로 구성
  //     final userData = {
  //       'name': nameController.text,
  //       'birth_date': birthDateController.text,
  //       'gender': _isMaleSelected ? 'male' : 'female',
  //       'university': universityController.text,
  //       'major': majorController.text,
  //       'phone_number': phoneController.text,
  //     };

  //     // 서버에 사용자 데이터를 POST 요청
  //     final response = await userService.register(userData);

  //     // 성공 시 홈 페이지로 이동
  //     print("Registration successful: $response");
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => PassengerHomePage1(),
  //       ),
  //     );
  //   } catch (e) {
  //     // 실패 시 에러 메시지 표시
  //     print("Registration failed: $e");
  //     showDialog(
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text("Registration Failed"),
  //         content: Text("Please check your information and try again."),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context), // 다이얼로그 닫기
  //             child: Text("OK"),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  // Widget _buildTitle(String title) {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 20, bottom: 12),
  //     child: Text(
  //       title,
  //       textAlign: TextAlign.center,
  //       style: TextStyle(
  //         color: Color(0xFF111416),
  //         fontSize: 26,
  //         fontFamily: 'Be Vietnam Pro',
  //         fontWeight: FontWeight.w700,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildTextField(String label, TextEditingController controller) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8),
  //     child: Container(
  //       height: 56,
  //       decoration: BoxDecoration(
  //         color: Color(0xFFEFF2F4),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 16),
  //         child: TextField(
  //           controller: controller, //텍스트 필드 컨트롤러 연결
  //           decoration: InputDecoration(
  //             hintText: label, // placeholder 텍스트로 label 사용
  //             border: InputBorder.none, // 기본 테두리 제거
  //           ),
  //           style: TextStyle(
  //             color: Color(0xFF637287),
  //             fontSize: 16,
  //             fontFamily: 'Be Vietnam Pro',
  //             fontWeight: FontWeight.w400,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildGenderOption(String label, bool selected, VoidCallback onTap) {
  //   return GestureDetector(
  //     onTap: onTap, // 터치 이벤트 처리
  //     child: Container(
  //       padding: const EdgeInsets.all(15),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(
  //           color: selected ? Color(0xFF111416) : Color(0xFFDBE0E5),
  //           width: 1,
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             label,
  //             style: TextStyle(
  //               color: Color(0xFF111416),
  //               fontSize: 14,
  //               fontFamily: 'Be Vietnam Pro',
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //           if (selected)
  //             Container(
  //               width: 20,
  //               height: 20,
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(10),
  //                 border: Border.all(color: Color(0xFF111416), width: 2),
  //               ),
  //               child: Icon(Icons.check, size: 14),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildSubmitButton(BuildContext context, String text) {
  //   return ElevatedButton(
  //     onPressed: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => PassengerHomePage1(),
  //         ),
  //       );
  //     },
  //     style: ElevatedButton.styleFrom(
  //       minimumSize: Size(double.infinity, 48),
  //       backgroundColor: Color(0xFF3387E5), // 버튼 배경색
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12), // 버튼 모서리 둥글게
  //       ),
  //     ),
  //     child: Text(
  //       text,
  //       textAlign: TextAlign.center,
  //       style: TextStyle(
  //         color: Colors.white,
  //         fontSize: 16,
  //         fontFamily: 'Be Vietnam Pro',
  //         fontWeight: FontWeight.w700,
  //       ),
  //     ),
  //   );
  // }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTitle('탑승자 정보 입력'),
              _buildTextField('이름', nameController),
              _buildTextField('아이디', usernameController),
              _buildTextField('비밀번호', passwordController, obscureText: true),
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
              _buildTextField('생년월일', birthDateController),
              _buildTextField('대학', universityController),
              _buildTextField('학과', majorController),
              _buildTextField('휴대폰 번호', phoneController),
              SizedBox(height: 20),
              _buildSubmitButton(context, '가입하기', _saveToFile),
            ],
          ),
        ),
      ),
    );
  }
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
