import 'package:flutter/material.dart';
import 'Passenger_home1.dart';

class PartyExitScreen extends StatelessWidget {
  const PartyExitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 버튼 스타일 공통화
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      minimumSize: const Size(double.infinity, 48),
    );

    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 상단 뒤로가기 버튼
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SizedBox(height: screenHeight * 0.2),
              // 질문 텍스트
              const Text(
                '정말 파티를 나가겠습니까?',
                style: TextStyle(
                  color: Color(0xFF111416),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.07),
              // "네, 나가겠습니다" 버튼
              ElevatedButton(
                style: buttonStyle.copyWith(
                  backgroundColor:
                      WidgetStateProperty.all(const Color(0xFF8E8C8C)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PassengerHomePage1(),
                    ),
                  ); // 홈 화면으로 이동
                },
                child: const Text(
                  '네, 나가겠습니다',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // "아니요, 나가지 않겠습니다" 버튼
              ElevatedButton(
                style: buttonStyle.copyWith(
                  backgroundColor:
                      WidgetStateProperty.all(const Color(0xFF3387E5)),
                ),
                onPressed: () {
                  Navigator.pop(context); // 이전 화면으로 복귀
                },
                child: const Text(
                  '아니요, 나가지 않겠습니다',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
