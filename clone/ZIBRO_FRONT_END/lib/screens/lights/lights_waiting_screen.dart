import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:texi_application/screens/lights/lights_passenger_list_screen.dart';
import 'package:texi_application/services/driver_service.dart';
import 'package:http/http.dart' as http;

class LightsWaitingScreen extends StatefulWidget {
  const LightsWaitingScreen({super.key});

  @override
  State<LightsWaitingScreen> createState() => _LightsWaitingScreen();
}

class RoutePoint {
  final String lat;
  final String lng;

  RoutePoint({
    required this.lat,
    required this.lng,
  });
}

//메인 빌드 클래스
class _LightsWaitingScreen extends State<LightsWaitingScreen> {
  late final DriverService driverService; // DriverService를 지연 초기화
  bool isLoading = true;
  // Map<String, dynamic> driverInfo = {};
  // NaverMapController 객체를 위한 Completer 생성
  final Completer<NaverMapController> _mapControllerCompleter = Completer();
  late NaverMapController _mapController;
  bool _isInitialized = false;
  Position? _currentPosition;
  List<NLatLng> _routeCoordinates = []; // 경로 데이터를 저장하는 리스트
  int _currentStep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _permission();
    _initialize(); // 위젯이 처음 생성될 때 지도 초기화
    // _getCurrentLocation(); // 앱 시작 시 위치 가져오기
    // DriverService 인스턴스 초기화

    // fetchDriverInfo();
  }

  @override
  void dispose() {
    _timer?.cancel(); // 타이머 해제
    super.dispose();
  }

  void _addCarMarkers(carLat, carLng) {
    // 시작점 마커 추가
    _mapController.addOverlay(
      NMarker(
        size: Size(40, 40),
        id: 'startMarker',
        position: NLatLng(double.parse(carLat), double.parse(carLng)),
        icon: NOverlayImage.fromAssetImage('assets/images/car2.png'),
      ),
    );
  }

  void _addPinMarkers(pinLat, pinLng) {
    // 도착점 마커 추가
    _mapController.addOverlay(
      NMarker(
        size: Size(40, 40),
        id: 'endMarker',
        position: NLatLng(double.parse(pinLat), double.parse(pinLng)),
        icon: NOverlayImage.fromAssetImage('assets/images/pin.png'),
      ),
    );
  }

  void _addPin1Markers(pinLat, pinLng) {
    // 도착점 마커 추가
    _mapController.addOverlay(
      NMarker(
        size: Size(40, 40),
        id: 'fristPointMarker',
        position: NLatLng(double.parse(pinLat), double.parse(pinLng)),
        icon: NOverlayImage.fromAssetImage('assets/images/pin.png'),
      ),
    );
  }

  void _addPin2Markers(pinLat, pinLng) {
    // 도착점 마커 추가
    _mapController.addOverlay(
      NMarker(
        size: Size(40, 40),
        id: 'secondPointMarker',
        position: NLatLng(double.parse(pinLat), double.parse(pinLng)),
        icon: NOverlayImage.fromAssetImage('assets/images/pin.png'),
      ),
    );
  }

  List<RoutePoint> routes = [
    RoutePoint(lat: "37.556415", lng: "126.931052"), // 택시 출발 위치
    RoutePoint(lat: "37.556311", lng: "126.931223"), // 택시 -> 첫번 째 승객 이동 1
    RoutePoint(lat: "37.556208", lng: "126.931138"), // 이동 2
    RoutePoint(lat: "37.556068", lng: "126.931038"), // 이동 3
    RoutePoint(lat: "37.555885", lng: "126.930902"), // 이동 4
    RoutePoint(lat: "37.555406", lng: "126.930555"), // 이동 5
    RoutePoint(lat: "37.555196", lng: "126.930398"), // 이동 6
  ];
  List<RoutePoint> waypoints = [
    RoutePoint(lat: "37.548701", lng: "126.913718"), // 마지막 승객 탑승지
    RoutePoint(lat: "37.556020", lng: "126.922964"), // 첫 번째 합승객 탑승지
    RoutePoint(lat: "37.550725", lng: "126.915876"), // 두 번째 합승객 탑승지
  ];
  Future<void> _fetchRoute(
    String startLat,
    String startLng,
    String endLat,
    String endLng,
    String wayPoint1Lat,
    String wayPoint1Lng,
    String wayPoint2Lat,
    String wayPoint2Lng,
  ) async {
    const String clientId = '7hhkfopok5'; // 네이버 클라이언트 ID
    const String clientSecret =
        'c7NcbYD1aeroA06v1lkxy79bNEy3wE9noJz7v07M'; // 네이버 클라이언트 Secret
    const String baseUrl =
        'https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving';
    Uri url;
    if (wayPoint2Lat != '') {
      url = Uri.parse(
        '$baseUrl?start=$startLng,$startLat&goal=$endLng,$endLat&waypoints=$wayPoint1Lng,$wayPoint1Lat|$wayPoint2Lng,$wayPoint2Lat',
      );
    } else if (wayPoint1Lat != '') {
      url = Uri.parse(
        '$baseUrl?start=$startLng,$startLat&goal=$endLng,$endLat&waypoints=$wayPoint1Lng,$wayPoint1Lat',
      );
    } else {
      url = Uri.parse(
        '$baseUrl?start=$startLng,$startLat&goal=$endLng,$endLat',
      );
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'X-NCP-APIGW-API-KEY-ID': clientId,
          'X-NCP-APIGW-API-KEY': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final route = data['route']['traoptimal'][0]['path'] as List<dynamic>;

        setState(() {
          _routeCoordinates =
              route.map((point) => NLatLng(point[1], point[0])).toList();
        });

        log("Route fetched successfully", name: "RouteAPI");
      } else {
        log("Failed to fetch route: ${response.body}", name: "RouteAPI");
      }
    } catch (e) {
      log("Error fetching route: $e", name: "RouteAPI");
    }
  }

  void _startRouteAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      // log("Current Step: $_currentStep, Updating Route: start(${routes[_currentStep].lat}, ${routes[_currentStep].lng}), waypoint1(${waypoints[0].lat}, ${waypoints[0].lng})");

      if (_currentStep >= routes.length) {
        _timer?.cancel(); // 모든 경로를 완료하면 타이머 중지
        return;
      }

      try {
        if (_currentStep < 2) {
          _updateRoute(
            routes[_currentStep].lat,
            routes[_currentStep].lng,
            waypoints[0].lat,
            waypoints[0].lng,
            "",
            "",
            "",
            "",
          );
        } else if (_currentStep < 4) {
          _updateRoute(
            routes[_currentStep].lat,
            routes[_currentStep].lng,
            waypoints[0].lat,
            waypoints[0].lng,
            waypoints[1].lat,
            waypoints[1].lng,
            "",
            "",
          );
        } else {
          _updateRoute(
            routes[_currentStep].lat,
            routes[_currentStep].lng,
            waypoints[0].lat,
            waypoints[0].lng,
            waypoints[1].lat,
            waypoints[1].lng,
            waypoints[2].lat,
            waypoints[2].lng,
          );
        }
      } catch (e) {
        log("Error in route animation: $e");
        _timer?.cancel();
      }

      _currentStep++; // 다음 단계로 이동
    });
  }

  void _updateRoute(
    String startLat,
    String startLng,
    String endLat,
    String endLng,
    String firstLat,
    String firstLng,
    String secondLat,
    String secondLng,
  ) async {
    await _fetchRoute(
      startLat,
      startLng,
      endLat,
      endLng,
      firstLat,
      firstLng,
      secondLat,
      secondLng,
    );
    // setState를 사용하여 마커와 경로 업데이트
    setState(() {
      // 차량 마커 추가
      _addCarMarkers(startLat, startLng);

      // 경유지 마커 추가
      if (firstLat != '') {
        log("firstLat");
        _addPin1Markers(firstLat, firstLng);
      }
      if (secondLat != '') {
        log("secondLat");
        _addPin2Markers(secondLat, secondLng);
      }

      // 목적지 마커 추가
      _addPinMarkers(endLat, endLng);

      // 경로 그리기
      _drawRoute();
    });
  }

  void _drawRoute() {
    _mapController.addOverlay(
      NPolylineOverlay(
        id: 'route',
        coords: _routeCoordinates,
        color: Colors.green,
        width: 10,
      ),
    );
  }

  // Future<void> fetchDriverInfo() async {
  //   try {
  //     final info =
  //         await driverService.fetchDriverInfo(); // DriverService를 통해 기사 정보 가져오기
  //     setState(() {
  //       driverInfo = info;
  //       isLoading = false;
  //     });
  //   } catch (error) {
  //     print('Error fetching driver info: $error');
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

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

  // void _permission() async {
  //   var requestStatus = await Permission.location.request();
  //   var status = await Permission.location.status;
  //   if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
  //     openAppSettings();
  //   }
  // }
  void _permission() async {
    var requestStatus = await Permission.location.request();
    if (requestStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

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
        title: Row(
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
      ),
      body: isLoading
          ? Column(
              children: [
                // 지도 (현재는 배경색으로 처리)
                SizedBox(
                  height: screenHeight * 0.53,
                  child: Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(55),
                        topRight: Radius.circular(55),
                      ),
                      child: NaverMap(
                        options: const NaverMapViewOptions(
                          minZoom: 13,
                          maxZoom: 13,
                          indoorEnable: true, // 실내 맵 사용 가능 여부 설정
                          locationButtonEnable: true, // 위치 버튼 표시 여부 설정
                          consumeSymbolTapEvents: false, // 심볼 탭 이벤트 소비 여부 설정
                        ),
                        onMapReady: (controller) async {
                          // 지도 준비 완료 시 호출되는 콜백 함수
                          _mapControllerCompleter.complete(
                              controller); // Completer에 지도 컨트롤러 완료 신호 전송
                          _mapController = controller;
                          // 지도 준비가 완료되면 위치 추적 모드를 활성화
                          _mapController.setLocationTrackingMode(
                              NLocationTrackingMode.follow);
                          // 경로 업데이트 및 표시
                          _startRouteAnimation(); // 경로 애니메이션 시작
                        },
                      ),
                    ),
                  ),
                ),
                // 기사 정보
                SizedBox(height: screenHeight * 0.03),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // 네비게이터를 사용하여 새로운 페이지로 이동
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LightsPassengerListScreen()),
                          );
                        },
                        child: const CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage('assets/images/duck.png'),
                        ),
                      ),
                      /*CircleAvatar(
                            radius: 28,
                            backgroundImage:
                                AssetImage('assets/images/duck.png'),
                          ),*/
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '김인덕',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '현대 더 뉴 아반떼, 흰색',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 차량 번호와 매너 온도
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '차량 번호 : 서울 14가 2780',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Be Vietnam Pro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(CupertinoIcons.car_detailed), // Cupertino 아이콘 사용
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '매너 온도 : 42.2',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Be Vietnam Pro',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.thumb_up), // Material 아이콘 사용
                    ],
                  ),
                ),
                // 호출 취소 버튼
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Color(0xFF39E533),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '호출 취소하기',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Be Vietnam Pro',
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
