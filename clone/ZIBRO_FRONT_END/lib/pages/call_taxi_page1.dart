import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'call_taxi_page2.dart';
import 'dart:developer';
import 'package:permission_handler/permission_handler.dart';

class CallTaxiPage1 extends StatefulWidget {
  // final String destination; // 도착지

  const CallTaxiPage1({
    super.key,
    // required this.destination,
  });

  @override
  State<CallTaxiPage1> createState() => _CallTaxiPage1State();
}

class _CallTaxiPage1State extends State<CallTaxiPage1> {
  String departure = "사용자 위치를 확인 중..."; // 초기 출발 위치 상태
  LatLng? currentPosition;
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

  // /// 출발 위치를 업데이트하는 메서드
  // void _updateDeparture(LatLng location) {
  //   setState(() {
  //     currentPosition = location;
  //     departure =
  //         "${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}";
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ZIBRO",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: _isInitialized
          ? Column(
              children: [
                // Google Maps 위젯
                SizedBox(
                  height: screenHeight * 0.60,
                  child: Expanded(
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
                ),
                // 출발 위치 및 호출 버튼
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '출발 위치',
                        style: TextStyle(
                          fontFamily: 'Be Vietnam Pro',
                          color: Color(0xFF111416),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF2F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          departure, // 현재 위치 표시
                          style: const TextStyle(
                            color: Color(0xFF637287),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CallTaxiPage2(),
                            ),
                          );
                          // print(
                          //     '택시 호출: 출발지($departure) -> 도착지(${widget.destination})');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3387E5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 48),
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
                      SizedBox(height: 20)
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
