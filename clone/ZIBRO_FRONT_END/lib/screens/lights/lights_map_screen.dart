import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:texi_application/pages/Passenger_home1.dart';
import 'package:texi_application/screens/lights/lights_waiting_screen.dart';

class LightsMapScreen extends StatefulWidget {
  const LightsMapScreen({super.key});

  @override
  State<LightsMapScreen> createState() => _LightsMapScreen();
}

//메인 빌드 클래스
class _LightsMapScreen extends State<LightsMapScreen> {
  bool isToggled = false;
  // NaverMapController 객체를 위한 Completer 생성
  final Completer<NaverMapController> _mapControllerCompleter = Completer();
  bool _isInitialized = false;
  late NaverMapController _mapController;

  @override
  void initState() {
    super.initState();
    _permission();
    _initialize(); // 위젯이 처음 생성될 때 지도 초기화
    // _getCurrentLocation(); // 앱 시작 시 위치 가져오기
  }

  // 지도 초기화하기
  Future<void> _initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await NaverMapSdk.instance.initialize(
        clientId: '7hhkfopok5', // 클라이언트 ID 설정
        onAuthFailed: (e) => log("네이버맵 인증오류 : $e", name: "onAuthFailed"),
      );
      setState(() {
        _isInitialized = true; // 초기화 완료 후 상태 변경
      });
      log("NaverMap SDK Initialized", name: "onInitialize");
    } catch (e) {
      log("네이버맵 초기화 오류 : $e", name: "onInitialize");
    }
  }

  void _permission() async {
    var requestStatus = await Permission.location.request();
    var status = await Permission.location.status;
    if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ZIBRO',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Be Vietnam Pro',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(
              width: 3,
            ),
            Text(
              'LIGHT',
              style: TextStyle(
                color: Color(0xFF39E533),
                fontFamily: 'Be Vietnam Pro',
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        leading: Transform.translate(
          offset: Offset(22.0, 0.0), //leading padding 맞추기
          child: Switch(
            value: isToggled,
            onChanged: (value) {
              setState(() {
                isToggled = value;
              });

              if (!value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PassengerHomePage1(),
                  ),
                );
              }
            },
            activeColor: Color(0xFF3387E5),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Color(0xFF8CE533),
          ),
        ),
      ),
      body: _isInitialized
          ? GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus(); // 키보드 닫기
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      // 지도 영역
                      SizedBox(
                        height: constraints.maxHeight * 0.63,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(55),
                            topRight: Radius.circular(55),
                          ),
                          child: NaverMap(
                            options: const NaverMapViewOptions(
                              indoorEnable: true,
                              locationButtonEnable: true,
                              consumeSymbolTapEvents: false,
                            ),
                            onMapReady: (controller) async {
                              _mapControllerCompleter.complete(controller);
                              _mapController = controller;
                              _mapController.setLocationTrackingMode(
                                  NLocationTrackingMode.follow);
                            },
                          ),
                        ),
                      ),
                      // 출발 위치 및 호출 버튼
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                          child: SingleChildScrollView(
                            reverse: true, // 키보드가 올라올 때 내용을 위로 올림
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF2F4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      hintText: '출발지를 입력해주세요.',
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
                                const SizedBox(height: 24),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF2F4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextField(
                                    obscureText: false,
                                    decoration: InputDecoration(
                                      hintText: '목적지를 입력해주세요.',
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
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LightsWaitingScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8CE533),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minimumSize:
                                        const Size(double.infinity, 60),
                                  ),
                                  child: const Text(
                                    'TAXI 호출하기',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            )
          : const Center(child: CircularProgressIndicator()),

      // body: _isInitialized
      //     ? SingleChildScrollView(
      //         child: Padding(
      //           padding: EdgeInsets.only(
      //               bottom: MediaQuery.of(context).viewInsets.bottom),
      //           child: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               GestureDetector(
      //                 onTap: () {
      //                   FocusScope.of(context).unfocus();
      //                 },
      //                 child: SizedBox(
      //                   height: screenHeight * 0.63,
      //                   child: ClipRRect(
      //                     borderRadius: const BorderRadius.only(
      //                       topLeft: Radius.circular(55),
      //                       topRight: Radius.circular(55),
      //                     ),
      //                     child: NaverMap(
      //                       options: const NaverMapViewOptions(
      //                         indoorEnable: true, // 실내 맵 사용 가능 여부 설정
      //                         locationButtonEnable: true, // 위치 버튼 표시 여부 설정
      //                         consumeSymbolTapEvents:
      //                             false, // 심볼 탭 이벤트 소비 여부 설정
      //                       ),
      //                       onMapReady: (controller) async {
      //                         // 지도 준비 완료 시 호출되는 콜백 함수
      //                         _mapControllerCompleter.complete(
      //                             controller); // Completer에 지도 컨트롤러 완료 신호 전송
      //                         _mapController = controller;
      //                         // 지도 준비가 완료되면 위치 추적 모드를 활성화
      //                         _mapController.setLocationTrackingMode(
      //                             NLocationTrackingMode.follow);
      //                       },
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //               // 출발 위치 및 호출 버튼
      //               SizedBox(
      //                 height: 5,
      //               ),
      //               Container(
      //                 padding: const EdgeInsets.symmetric(
      //                     horizontal: 16, vertical: 12),
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     Container(
      //                       width: double.infinity,
      //                       padding: const EdgeInsets.symmetric(
      //                         vertical: 4,
      //                         horizontal: 12,
      //                       ),
      //                       decoration: BoxDecoration(
      //                         color: const Color(0xFFEFF2F4),
      //                         borderRadius: BorderRadius.circular(12),
      //                       ),
      //                       child: TextField(
      //                         obscureText: false,
      //                         decoration: InputDecoration(
      //                           hintText: '출발지를 입력해주세요.',
      //                           border: InputBorder.none,
      //                         ),
      //                         style: const TextStyle(
      //                           color: Color(0xFF637287),
      //                           fontSize: 16,
      //                           fontFamily: 'Be Vietnam Pro',
      //                           fontWeight: FontWeight.w400,
      //                         ),
      //                       ),
      //                     ),
      //                     const SizedBox(height: 20),
      //                     Container(
      //                       width: double.infinity,
      //                       padding: const EdgeInsets.symmetric(
      //                         vertical: 4,
      //                         horizontal: 12,
      //                       ),
      //                       decoration: BoxDecoration(
      //                         color: const Color(0xFFEFF2F4),
      //                         borderRadius: BorderRadius.circular(12),
      //                       ),
      //                       child: TextField(
      //                         obscureText: false,
      //                         decoration: InputDecoration(
      //                           hintText: '목적지를 입력해주세요.',
      //                           border: InputBorder.none,
      //                         ),
      //                         style: const TextStyle(
      //                           color: Color(0xFF637287),
      //                           fontSize: 16,
      //                           fontFamily: 'Be Vietnam Pro',
      //                           fontWeight: FontWeight.w400,
      //                         ),
      //                       ),
      //                     ),
      //                     SizedBox(
      //                       height: 20,
      //                     ),
      //                     ElevatedButton(
      //                       onPressed: () {
      //                         Navigator.push(
      //                           context,
      //                           MaterialPageRoute(
      //                             builder: (context) => LightsWaitingScreen(),
      //                           ),
      //                         );
      //                       },
      //                       style: ElevatedButton.styleFrom(
      //                         backgroundColor: const Color(0xFF8CE533),
      //                         shape: RoundedRectangleBorder(
      //                           borderRadius: BorderRadius.circular(12),
      //                         ),
      //                         minimumSize: const Size(double.infinity, 48),
      //                       ),
      //                       child: const Text(
      //                         'TAXI 호출하기',
      //                         style: TextStyle(
      //                           color: Colors.white,
      //                           fontSize: 16,
      //                           fontWeight: FontWeight.bold,
      //                         ),
      //                       ),
      //                     ),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       )
      //     : Center(child: CircularProgressIndicator()),
    );
  }
}
