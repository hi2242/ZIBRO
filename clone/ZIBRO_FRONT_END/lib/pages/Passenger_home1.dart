import 'package:flutter/material.dart';
import 'package:texi_application/screens/lights/lights_map_screen.dart';
import 'Passenger_make_party_info.dart';
import 'my_party_info.dart';
import 'check_party_list.dart';

class PassengerHomePage1 extends StatefulWidget {
  const PassengerHomePage1({super.key});

  @override
  State<PassengerHomePage1> createState() => _PassengerHomePage1State();
}

//메인 빌드 클래스
class _PassengerHomePage1State extends State<PassengerHomePage1> {
  bool isToggled = true;
  int _currentIndex = 0; // 현재 선택된 탭의 인덱스

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'ZIBRO',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Be Vietnam Pro',
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: Transform.translate(
          offset: Offset(22.0, 0.0), //leading padding 맞추기
          child: Switch(
            value: isToggled,
            onChanged: (value) {
              setState(() {
                isToggled = value;
              });
              // 스위치 켜졌을 때 LightsMapScreen으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LightsMapScreen(),
                ),
              );
            },
            activeColor: Color(0xFF3387E5),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Color(0xFF8CE533),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 22.0,
          right: 22.0,
          top: 10.0,
          bottom: 10.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            Text(
              '다 함께 집으로 ZIBRO',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Be Vietnam Pro'),
            ),
            SizedBox(height: screenHeight * 0.02),
            // 첫 번째 커스텀 버튼
            CustomButton(
              label: 'TAXI 파티 만들기',
              onPressed: () {
                print('TAXI 파티 만들기 버튼 클릭');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PassengerMakePartyInfo(),
                  ),
                );
              },
              backgroundColor: Color(0xFF3387E5),
              fontColor: Colors.white,
            ),
            SizedBox(height: screenHeight * 0.01),
            // 두 번째 커스텀 버튼
            CustomButton(
              label: '인근 TAXI 파티 목록 확인하기',
              onPressed: () {
                print('인근 TAXI 파티 목록 버튼 클릭');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NearbyTaxiPartiesPage(),
                  ),
                );
              },
              backgroundColor: Color(0xFFEFF2F4),
              fontColor: Colors.black,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              '합리적인 실천',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Be Vietnam Pro'),
            ),
            InfoDisplayWidget(
              calculator: InfoCalculator(distanceInKm: 36.0, cost: 313600.0),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_car), label: '나의 파티'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이 페이지'),
        ],
        selectedItemColor: Color(0xFF3387E5),
        unselectedItemColor: Colors.black,
        onTap: (int index) {
          _handleNavigation(index);
        },
      ),
    );
  }

  /// 탭 클릭 시 실행되는 작업
  void _handleNavigation(int index) {
    setState(() {
      _currentIndex = index; // 선택된 인덱스 업데이트
    });

    // 각 인덱스에 따른 작업 실행
    if (index == 0) {
      print("홈 버튼 클릭");
      // 다른 동작 추가 가능
    } else if (index == 1) {
      print("나의 파티 버튼 클릭");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyPartyInfo()), // 네비게이션 실행
      );
    } else if (index == 2) {
      print("마이 페이지 버튼 클릭");
      // 추가 로직 실행
    }
  }
}

//택시 만들기, 택시 목록 확인하기 버튼
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color fontColor;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.fontColor,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0, //그림자 제거
        backgroundColor: backgroundColor,
        minimumSize: Size(double.infinity, screenHeight * 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fontColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}

//배출량, 절약금액, 나무 시각화 기능 클래스
class InfoCalculator {
  final double distanceInKm;
  final double cost;

  InfoCalculator({required this.distanceInKm, required this.cost});

  /// 탄소 배출량 계산 함수
  String calculateCarbonEmission() {
    double emission = distanceInKm * 0.21; // kg 단위
    return emission.toStringAsFixed(2);
  }

  /// 절약된 금액 계산 함수
  String calculateSavings() {
    double savings = cost * 0.1; // 절약된 금액
    return savings.toStringAsFixed(0);
  }

  /// 나무로 변환하는 함수
  String calculateTreesPlanted() {
    double trees = (distanceInKm * 0.21) / 21;
    return trees.toStringAsFixed(1);
  }
}

class InfoDisplayWidget extends StatelessWidget {
  final InfoCalculator calculator;

  const InfoDisplayWidget({super.key, required this.calculator});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildInfoRow(
                title: '탄소 배출량 감량',
                value: calculator.calculateCarbonEmission(),
                unit: 'kg CO2',
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildInfoRow(
                title: '똑똑한 경제생활',
                value: calculator.calculateSavings(),
                unit: '원',
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.01),
        _buildInfoRow(
          title: 'ZIBRO를 통해 심은 나무의 수',
          value: calculator.calculateTreesPlanted(),
          unit: '🌲',
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String value,
    required String unit,
    bool fullWidth = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      height: 112,
      width: fullWidth ? double.infinity : null, // 너비를 최대화할 조건
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFDBE0E5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value, // 값 부분
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: ' $unit', // 단위 부분
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
