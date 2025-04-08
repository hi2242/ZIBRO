import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DriversMatchingScreen extends StatelessWidget {
  const DriversMatchingScreen({super.key});

  dynamic onbutton() {
    print("텍스트 버튼 클릭");
  }

  void _launchNaverMapNavigation() async {
    const String scheme = 'nmap://navigation';
    const double startLat = 37.464709; // 주안역 1번 출구 위도
    const double startLng = 126.680862; // 주안역 1번 출구 경도
    const double endLat = 37.450121; // 인하대학교 용현캠퍼스 위도
    const double endLng = 126.653506; // 인하대학교 용현캠퍼스 경도
    const String startName = '주안역 1번 출구';
    const String endName = '인하대학교 용현캠퍼스';
    const String appName = 'com.example.ZIBRO'; // 실제 앱의 패키지 이름으로 교체

    // const String naverMapUrl =
    //     '$scheme?slat=$startLat&slng=$startLng&sname=$startName&dlat=$endLat&dlng=$endLng&dname=$endName&appname=$appName';
    String naverMapUrl =
        '$scheme?v1lat=$startLat&v1lng=$startLng&v1name=$startName&dlat=$endLat&dlng=$endLng&dname=$endName&appname=$appName';

    if (await canLaunchUrl(Uri.parse(naverMapUrl))) {
      await launchUrl(Uri.parse(naverMapUrl));
    } else {
      // 네이버 지도 앱이 설치되어 있지 않은 경우
      const String playStoreUrl =
          'https://play.google.com/store/apps/details?id=com.nhn.android.nmap';
      await launchUrl(Uri.parse(playStoreUrl));
    }
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
                  child: const Text("콜 멈추기"),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Center(
              child: Container(
                width: 370,
                height: 585,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D2D3),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.center,
                child: const Column(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "16km · 30분",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF000000),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "인원 : 3명",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF000000),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "주안역",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                Text(
                                  "미추홀구 주안동",
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Color(0xFF434343),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            size: 40,
                            color: Color(0xFF727F80),
                            Icons.keyboard_arrow_down,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "인하대학교",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                Text(
                                  "인하로 100",
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Color(0xFF434343),
                                  ),
                                ),
                              ],
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
                children: [
                  Container(
                    width: 120,
                    height: 83,
                    decoration: BoxDecoration(
                      color: const Color(0xFF474950),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Center(
                      child: Text(
                        "거절",
                        style: TextStyle(
                          fontSize: 32,
                          color: Color(0xFFD8D8D8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: _launchNaverMapNavigation,
                    child: Container(
                      width: 240,
                      height: 83,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3387E5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Center(
                        child: Text(
                          "콜 수락",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD8D8D8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
