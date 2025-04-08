import 'package:flutter/material.dart';
import 'package:texi_application/pages/passenger_login_page.dart';
import 'package:texi_application/screens/drivers/drivers_login_screen.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.2), // 화면 높이에 비례한 여백
            Text(
              '집에 갈 땐 다 같이',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF111416),
                fontSize: 28,
                fontFamily: 'Be Vietnam Pro',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: screenHeight * 0.003),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Z',
                    style: TextStyle(
                      color: Color(0xFF3387E5),
                      fontSize: 50,
                      fontFamily: 'Be Vietnam Pro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'IBRO',
                    style: TextStyle(
                      color: Color(0xFF111416),
                      fontSize: 35,
                      fontFamily: 'Be Vietnam Pro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.05),
            Text(
              '안녕하세요! \n가입 유형을 선택해주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF111416),
                fontSize: 18,
                fontFamily: 'Be Vietnam Pro',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: screenHeight * 0.1), // 공간을 균등하게 분배
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF3387E5),
                minimumSize:
                    Size(double.infinity, screenHeight * 0.06), // 높이를 유동적으로 설정
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PassengerLoginPage()),
                );
              },
              child: Text(
                '택시 이용자 입니다',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Be Vietnam Pro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8E8C8C),
                minimumSize: Size(double.infinity, screenHeight * 0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DriversLoginScreen()),
                );
              },
              child: Text(
                '택시 운전자 입니다',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Be Vietnam Pro',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Spacer(), // 하단에 여백 추가
          ],
        ),
      ),
    );
  }
}
