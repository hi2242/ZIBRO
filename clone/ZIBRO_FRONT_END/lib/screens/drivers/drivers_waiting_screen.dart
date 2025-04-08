import 'package:flutter/material.dart';
import 'package:texi_application/screens/drivers/drivers_map_screen.dart';
import 'package:texi_application/screens/drivers/drivers_matching_screen.dart';
import 'package:texi_application/widgets/drivers/dots_loading_indicator.dart';
import 'package:texi_application/widgets/drivers/unlock_slider.dart';

class DriversWaitingScreen extends StatelessWidget {
  final Map<String, String> driverData;

  const DriversWaitingScreen({super.key, required this.driverData});

  get doNothing => null;

  dynamic onbutton() {
    print("텍스트 버튼 클릭");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191c24),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
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
                  onPressed: onbutton,
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
                height: 360,
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: const Color(0xFF3B3E45),
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/dot_grid.png'),
                    fit: BoxFit.cover,
                  ),
                  color: const Color(0xFF000000),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "콜 대기중",
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF3387E5),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Center(
                            child: DotsLoadingIndicator(),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          Container(
                            width: 200,
                            height: 60,
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFFAF6A12),
                                  spreadRadius: 1,
                                  blurRadius: 10,
                                  offset: Offset(0.0, 0.0),
                                )
                              ],
                              color: const Color(0xFF000000),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    color: Color(0xFFE25F50),
                                    size: 24,
                                    Icons.favorite,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "서울 강남구",
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Color(0xFFAF6A12),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Icon(
                                    color: Color(0xFFAF6A12),
                                    size: 24,
                                    Icons.arrow_forward_ios,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStopButton(
                    context,
                    "콜 멈추기",
                    () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriversMatchingScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(
                        color: Color(0xFFA3A4A7),
                        size: 24,
                        Icons.list,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "콜 리스트",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(
                            0xFFA3A4A7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                const Text(
                  "l",
                  style: TextStyle(
                    color: Color(0xFFA3A4A7),
                    fontSize: 20,
                    fontFamily: 'RobotoMono',
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DriversMapScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(
                        color: Color(0xFFA3A4A7),
                        size: 24,
                        Icons.map_outlined,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "수요 지도",
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(
                            0xFFA3A4A7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: UnlockSlider(
                driverData: driverData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildStopButton(
    BuildContext context, String text, VoidCallback onPressed) {
  return GestureDetector(
    onTap: () {
      Navigator.pop(context);
    },
    child: Container(
      width: 356,
      height: 83,
      decoration: BoxDecoration(
        color: const Color(0xFFA3A4A7),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF000000),
          ),
        ),
      ),
    ),
  );
}
