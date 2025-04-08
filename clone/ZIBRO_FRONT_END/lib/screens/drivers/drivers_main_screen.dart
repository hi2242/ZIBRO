import 'package:flutter/material.dart';
import 'package:texi_application/screens/drivers/drivers_marker_screen.dart';
import 'drivers_waiting_screen.dart';

class DriversMainScreen extends StatelessWidget {
  final Map<String, String> driverData;

  const DriversMainScreen({super.key, required this.driverData});

  dynamic onbutton() {
    print("텍스트 버튼 클릭");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191c24),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 50,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFd8d8d8),
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  onPressed: onbutton,
                  child: const Text("공지"),
                ),
                const SizedBox(
                  width: 8,
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFd8d8d8),
                    textStyle: const TextStyle(fontSize: 24),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriversMarkerScreen(),
                      ),
                    );
                  },
                  child: const Text("메뉴"),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Container(
                width: 356,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF30333A),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Icon(
                        size: 32,
                        color: Color(0xFFD8D8D8),
                        Icons.person_pin,
                      ),
                      SizedBox(width: 8),
                      Text(
                        driverData['Name'] ?? '',
                        style: TextStyle(
                          color: Color(0xFFD8D8D8),
                          fontSize: 16,
                        ),
                      ),
                      Spacer(),
                      Icon(
                        size: 24,
                        color: Color(0xFFD8D8D8),
                        Icons.arrow_forward_ios,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Center(
              child: Container(
                width: 356,
                height: 425,
                decoration: BoxDecoration(
                  color: const Color(0xFF30333A),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: 15,
                        right: 8,
                        left: 8,
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Text(
                            driverData['Company'] ?? '',
                            style: TextStyle(
                              color: Color(0xFFD8D8D8),
                              fontSize: 16,
                            ),
                          ),
                          Spacer(),
                          Text(
                            driverData['Account'] ?? '',
                            style: TextStyle(
                              color: Color(0xFFD8D8D8),
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            size: 24,
                            color: Color(0xFFD8D8D8),
                            Icons.arrow_forward_ios,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Container(
                      height: 1.0,
                      width: double.infinity,
                      color: const Color(0xFF3B3E45),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            driverData['Vehicle Number'] ?? '',
                            style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF3387E5)),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "${driverData['Vehicle Type'] ?? ''} / ${driverData['Vehicle Size'] ?? ''} / 카드 가능",
                            style: TextStyle(
                                fontSize: 20, color: Color(0xFF3387E5)),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          Container(
                            width: 140,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFF595C61),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Center(
                              child: Text(
                                "차량 변경",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xFFD8D8D8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 100,
            ),
            _buildWorking(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWorking(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) => const DriversWaitingScreen()),
          // );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriversWaitingScreen(
                driverData: driverData,
              ),
            ),
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
              "출근하기",
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
