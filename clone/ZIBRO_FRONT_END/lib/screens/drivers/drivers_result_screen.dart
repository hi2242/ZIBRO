import 'package:flutter/material.dart';
import 'package:texi_application/screens/drivers/drivers_main_screen.dart';

class DriversResultScreen extends StatelessWidget {
  final Map<String, String> driverData;

  const DriversResultScreen({super.key, required this.driverData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191c24),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 100,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 356,
                  height: 112,
                  alignment: Alignment.center,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Flexible(
                      child: Text(
                        "오늘은 탄소를 다음과 같이 절약했어요!\n탄소중립에 참여해주셔서 감사합니다.",
                        style: TextStyle(
                          color: Color(0xFFD8D8D8),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoCard("탄소 배출량 감량"),
              const SizedBox(height: 15),
              _buildInfoCard("줄인 공회전 시간"),
              const SizedBox(height: 15),
              _buildInfoCard("ZIBRO를 통해 N그루의 나무를 심었어요!",
                  textAlign: TextAlign.left),
              const SizedBox(height: 100),
              _buildFinish(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text, {TextAlign textAlign = TextAlign.center}) {
    return Center(
      child: Container(
        width: 356,
        height: 112,
        decoration: BoxDecoration(
          color: const Color(0xFF30333A),
          borderRadius: BorderRadius.circular(5),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            text,
            textAlign: textAlign,
            style: const TextStyle(
              color: Color(0xFFD8D8D8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinish(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => DriversMainScreen()),
          // );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DriversMainScreen(
                driverData: driverData,
              ),
            ),
            // MaterialPageRoute(
            //     builder: (context) =>
            //         DriversMainScreen(driverData: {/* driver data */})),
          );
        },
        child: Container(
          width: 356,
          height: 83,
          decoration: BoxDecoration(
            color: const Color(0xFF3387E5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Center(
            child: Text(
              "퇴근하기",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFFD8D8D8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
