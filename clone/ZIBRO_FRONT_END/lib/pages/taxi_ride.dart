import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:texi_application/services/party_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:texi_application/services/api_client.dart';

class TaxiRidePage extends StatefulWidget {
  const TaxiRidePage({super.key});

  @override
  State<TaxiRidePage> createState() => _TaxiRidePage();
}

class RoutePoint {
  final String lat;
  final String lng;

  RoutePoint({
    required this.lat,
    required this.lng,
  });
}

class PassengerInfo {
  final String destination;
  final String destinationTime;
  final String minutes;

  PassengerInfo({
    required this.destination,
    required this.destinationTime,
    required this.minutes,
  });
}

//메인 빌드 클래스
class _TaxiRidePage extends State<TaxiRidePage> {
  // NaverMapController 객체를 위한 Completer 생성
  final Completer<NaverMapController> _mapControllerCompleter = Completer();
  bool _isInitialized = false;
  Position? _currentPosition;
  late NaverMapController _mapController;
  List<NLatLng> _routeCoordinates = []; // 경로 데이터를 저장하는 리스트
  late Future<Map<String, dynamic>> _partyData;
  late Future<List<Map<String, dynamic>>> _destinationDatas;
  String departure = "사용자 위치를 확인 중..."; // 초기 출발 위치 상태
  // NaverMapController 객체를 위한 Completer 생성

  // PartyService 인스턴스 생성
  final PartyService partyService =
      PartyService(ApiClient("http://127.0.0.1:8000")); // 서버 URL 설정

  @override
  void initState() {
    super.initState();
    // _permission();
    _initialize(); // 위젯이 처음 생성될 때 지도 초기화
    // _getCurrentLocation(); // 앱 시작 시 위치 가져오기
    // DriverService 인스턴스 초기화
    _partyData = _fetchPartyData();
    _destinationDatas = _fetchDestinationsData();
  }

  /// 서버에서 파티 정보 가져오기
  Future<Map<String, dynamic>> _fetchPartyData() async {
    try {
      // 서버에서 데이터 가져오기
      final partyDetails = await partyService.getPartyDetails(1); // 파티 ID 사용
      return partyDetails;
    } catch (e) {
      print("Failed to fetch party data: $e");
      throw Exception("Failed to fetch party data");
    }
  }

  /// 서버에서 목적지 리스트 가져오기
  Future<List<Map<String, dynamic>>> _fetchDestinationsData() async {
    try {
      // 서버에서 데이터 가져오기
      final destinations =
          await ApiClient("http://127.0.0.1:8000").get('/destinations');
      return destinations;
    } catch (e) {
      print("Failed to fetch destinations data: $e");
      throw Exception("Failed to fetch destinations data");
    }
  }

  List<RoutePoint> routes = [
    RoutePoint(lat: "37.556020", lng: "126.922964"), // 첫 번째 합승객 탑승지
    RoutePoint(lat: "37.464033", lng: "126.680140"), // 이동 1
    RoutePoint(lat: "37.464090", lng: "126.678624"), // 이동 2
    RoutePoint(lat: "37.464176", lng: "126.677253"), // 이동 3
    RoutePoint(lat: "37.464230", lng: "126.674040"), // 이동 4
    RoutePoint(lat: "37.463484", lng: "126.672841"), // 이동 5
    RoutePoint(lat: "37.461275", lng: "126.671574"), // 이동 6
  ];
  List<RoutePoint> waypoints = [
    RoutePoint(lat: "37.380947", lng: "126.659122"), // 마지막 승객 도착지
    RoutePoint(lat: "37.450192", lng: "126.653370"), // 첫 번째 합승객 도착지
    RoutePoint(lat: "37.392398", lng: "126.639753"), // 두 번째 합승객 도착지
  ];
  List<PassengerInfo> passengers = [
    PassengerInfo(
        destination: '미추홀구 주안로 114-1',
        destinationTime: '3:35 PM 도착 예정',
        minutes: '27'), // 1번
    PassengerInfo(
        destination: '미추홀구 도화동 555',
        destinationTime: '3:28 PM 도착 예정',
        minutes: '19'), // 2번
    PassengerInfo(
        destination: 'LG전자베스트샵 도화점입구',
        destinationTime: '3:23 PM 도착 예정',
        minutes: '14'), // 3번
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
    Uri url = Uri.parse(
      '$baseUrl?start=$startLng,$startLat&goal=$endLng,$endLat&waypoints=$wayPoint1Lng,$wayPoint1Lat|$wayPoint2Lng,$wayPoint2Lat',
    );
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

      // 목적지 마커 추가
      _addPinMarkers(endLat, endLng);
      // 경유지 마커 추가

      _addPin1Markers(firstLat, firstLng);

      _addPin2Markers(secondLat, secondLng);
      // 경로 그리기
      _drawRoute();
    });
  }

  void _drawRoute() {
    _mapController.addOverlay(
      NPolylineOverlay(
        id: 'route',
        coords: _routeCoordinates,
        color: Colors.blue,
        width: 10,
      ),
    );
  }

  void _permission() async {
    var requestStatus = await Permission.location.request();
    var status = await Permission.location.status;
    if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  /// 개인별 위치 정보 타일
  Widget _buildLocationTile({
    required String name,
    required String destination,
    required String arrivalTime,
    required int eta,
    required bool isMe,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 정렬
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24, // 프로필 이미지 크기
                backgroundColor: isMe ? Colors.blue : Colors.blue, // 색상
                child: Text(
                  name[0], // 이름 첫 글자
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(width: 12), // 간격
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination, // 목적지 표시
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "도착 예정: $arrivalTime", // 예상 도착 시간 표시
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          Text(
            eta > 0 ? "$eta분" : "도착", // ETA 또는 탑승 중 표시
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: eta > 0 ? Colors.blue : Colors.grey, // 색상
            ),
          ),
        ],
      ),
    );
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
          onPressed: () => Navigator.pop(context), // 뒤로가기 버튼
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _partyData, // 서버에서 가져온 데이터
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 데이터 로딩 중
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // 데이터 가져오기 실패
            return Center(
              child: Text('Failed to load data: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // 데이터가 비어있음
            return const Center(child: Text('No data available'));
          } else {
            final data = snapshot.data!;
            final myInfo = data['myInfo'];
            final partyMembers = data['partyMembers'] as List<dynamic>;
            double screenHeight = MediaQuery.of(context).size.height;
            return Column(
              children: [
                // 상단 개인 목록을 감싸는 컨테이너
                SizedBox(
                  height: screenHeight * 0.3, // 목록 영역 높이 설정
                  child: ListView(
                    children: [
                      _buildLocationTile(
                        name: myInfo['name'], // 사용자 이름
                        destination: myInfo['indiv_destination'], // 개인 목적지
                        arrivalTime: "3:23 AM", // 예상 도착 시간 (임시 값)
                        eta: 40, // ETA는 Google Maps API로 대체 예정
                        isMe: true, // 본인 여부
                      ),
                      ...partyMembers.map((member) {
                        return _buildLocationTile(
                          name: member['name'], // 멤버 이름
                          destination: member['indiv_destination'], // 멤버 목적지
                          arrivalTime: member['arrivalTime'], // 예상 도착 시간 (임시 값)
                          eta: member['eta'], // ETA도 Google Maps API로 대체 예정
                          isMe: false, // 본인 여부 아님
                        );
                      }),
                    ],
                  ),
                ),
                //const Divider(thickness: 1), // 구분선
                // 하단 지도 영역
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(55),
                        topRight: Radius.circular(55),
                      ),
                    ),
                    clipBehavior: Clip.hardEdge, // 클리핑을 강제하여 둥근 모서리 적용
                    child: NaverMap(
                      options: const NaverMapViewOptions(
                        maxZoom: 8,
                        minZoom: 8,
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
                        _updateRoute(
                          routes[0].lat,
                          routes[0].lng,
                          waypoints[0].lat,
                          waypoints[0].lng,
                          waypoints[1].lat,
                          waypoints[1].lng,
                          waypoints[2].lat,
                          waypoints[2].lng,
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
            // return _buildContent(data); // 데이터로 UI 생성
          }
        },
      ),

      // passengers.isEmpty
      //     ? Center(child: Text('Failed to load passengers info'))
      //     : Column(
      //         children: [
      //           // 현재 동승자 목록
      //           Padding(
      //             padding:
      //                 const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      //             child: Column(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 _eachPassenger(passengers[0]),
      //                 SizedBox(
      //                   height: 20,
      //                 ),
      //                 _eachPassenger(passengers[1]),
      //                 SizedBox(
      //                   height: 20,
      //                 ),
      //                 _eachPassenger(passengers[2]),
      //               ],
      //             ),
      //           ),
      //           SizedBox(height: screenHeight * 0.03),
      //           SizedBox(
      //             height: screenHeight * 0.5,
      //             child: Expanded(
      //               child: ClipRRect(
      //                 borderRadius: const BorderRadius.only(
      //                   topLeft: Radius.circular(55),
      //                   topRight: Radius.circular(55),
      //                 ),
      //                 child: NaverMap(
      //                   options: const NaverMapViewOptions(
      //                     indoorEnable: true, // 실내 맵 사용 가능 여부 설정
      //                     locationButtonEnable: true, // 위치 버튼 표시 여부 설정
      //                     consumeSymbolTapEvents: false, // 심볼 탭 이벤트 소비 여부 설정
      //                   ),
      //                   onMapReady: (controller) async {
      //                     // 지도 준비 완료 시 호출되는 콜백 함수
      //                     _mapControllerCompleter.complete(
      //                         controller); // Completer에 지도 컨트롤러 완료 신호 전송
      //                     _mapController = controller;
      //                     // 지도 준비가 완료되면 위치 추적 모드를 활성화
      //                     _mapController.setLocationTrackingMode(
      //                         NLocationTrackingMode.follow);
      //                     _updateRoute(
      //                       routes[0].lat,
      //                       routes[0].lng,
      //                       waypoints[0].lat,
      //                       waypoints[0].lng,
      //                       waypoints[1].lat,
      //                       waypoints[1].lng,
      //                       waypoints[2].lat,
      //                       waypoints[2].lng,
      //                     );
      //                   },
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
    );
  }
}

//   Row _eachPassenger(PassengerInfo passengerInfo) {
//     return Row(
//       children: [
//         Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Text(
//               passengerInfo.destination,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontFamily: 'Be Vietnam Pro',
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             Text(
//               passengerInfo.destinationTime,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontFamily: 'Be Vietnam Pro',
//                 color: Color(0xFF637387),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(
//           width: 60,
//         ),
//         Text(
//           passengerInfo.minutes,
//           style: TextStyle(
//             fontSize: 24,
//             fontFamily: 'Be Vietnam Pro',
//             color: Color(0xFF39E533),
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         Text(
//           '분',
//           style: TextStyle(
//             fontSize: 18,
//             fontFamily: 'Be Vietnam Pro',
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }

// /// 전체 UI 구성
// Widget _buildContent(Map<String, dynamic> data) {
//   final myInfo = data['myInfo'];
//   final partyMembers = data['partyMembers'] as List<dynamic>;
//   double screenHeight = MediaQuery.of(context).size.height;

//   return Column(
//     children: [
//       // 상단 개인 목록을 감싸는 컨테이너
//       SizedBox(
//         height: screenHeight * 0.3, // 목록 영역 높이 설정
//         child: ListView(
//           children: [
//             _buildLocationTile(
//               name: myInfo['name'], // 사용자 이름
//               destination: myInfo['indiv_destination'], // 개인 목적지
//               arrivalTime: "3:23 AM", // 예상 도착 시간 (임시 값)
//               eta: 40, // ETA는 Google Maps API로 대체 예정
//               isMe: true, // 본인 여부
//             ),
//             ...partyMembers.map((member) {
//               return _buildLocationTile(
//                 name: member['name'], // 멤버 이름
//                 destination: member['indiv_destination'], // 멤버 목적지
//                 arrivalTime: "3:28 AM", // 예상 도착 시간 (임시 값)
//                 eta: 45, // ETA도 Google Maps API로 대체 예정
//                 isMe: false, // 본인 여부 아님
//               );
//             }),
//           ],
//         ),
//       ),
//       //const Divider(thickness: 1), // 구분선
//       // 하단 지도 영역
//       Expanded(
//         child: Container(
//           decoration: const BoxDecoration(
//             color: Colors.grey,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(55),
//               topRight: Radius.circular(55),
//             ),
//           ),
//           clipBehavior: Clip.hardEdge, // 클리핑을 강제하여 둥근 모서리 적용
//           child: NaverMap(
//             options: const NaverMapViewOptions(
//               indoorEnable: true, // 실내 맵 사용 가능 여부 설정
//               locationButtonEnable: true, // 위치 버튼 표시 여부 설정
//               consumeSymbolTapEvents: false, // 심볼 탭 이벤트 소비 여부 설정
//             ),
//             onMapReady: (controller) async {
//               // 지도 준비 완료 시 호출되는 콜백 함수
//               _mapControllerCompleter
//                   .complete(controller); // Completer에 지도 컨트롤러 완료 신호 전송
//               _mapController = controller;
//               // 지도 준비가 완료되면 위치 추적 모드를 활성화
//               _mapController
//                   .setLocationTrackingMode(NLocationTrackingMode.follow);
//               _updateRoute(
//                 routes[0].lat,
//                 routes[0].lng,
//                 waypoints[0].lat,
//                 waypoints[0].lng,
//                 waypoints[1].lat,
//                 waypoints[1].lng,
//                 waypoints[2].lat,
//                 waypoints[2].lng,
//               );
//             },
//           ),
//         ),
//       ),
//     ],
//   );
// }

// /// 개인별 위치 정보 타일
// Widget _buildLocationTile({
//   required String name,
//   required String destination,
//   required String arrivalTime,
//   required int eta,
//   required bool isMe,
// }) {
//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우 정렬
//       children: [
//         Row(
//           children: [
//             CircleAvatar(
//               radius: 24, // 프로필 이미지 크기
//               backgroundColor: isMe ? Colors.blue : Colors.grey[300], // 색상
//               child: Text(
//                 name[0], // 이름 첫 글자
//                 style: const TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ),
//             const SizedBox(width: 12), // 간격
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   destination, // 목적지 표시
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 Text(
//                   "도착 예정: $arrivalTime", // 예상 도착 시간 표시
//                   style: const TextStyle(color: Colors.grey, fontSize: 14),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         Text(
//           eta > 0 ? "$eta분" : "도착", // ETA 또는 탑승 중 표시
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//             color: eta > 0 ? Colors.blue : Colors.grey, // 색상
//           ),
//         ),
//       ],
//     ),
//   );
// }

// /// 서버에서 파티 정보 가져오기
// Future<Map<String, dynamic>> _fetchPartyData() async {
//   try {
//     // 서버에서 데이터 가져오기
//     final partyDetails = await partyService.getPartyDetails(1); // 파티 ID 사용
//     return partyDetails;
//   } catch (e) {
//     print("Failed to fetch party data: $e");
//     throw Exception("Failed to fetch party data");
//   }
// }

// /// 서버에서 목적지 리스트 가져오기
// Future<List<Map<String, dynamic>>> _fetchDestinationsData() async {
//   try {
//     // 서버에서 데이터 가져오기
//     final destinations =
//         await ApiClient("http://127.0.0.1:8000").get('/destinations');
//     return destinations;
//   } catch (e) {
//     print("Failed to fetch destinations data: $e");
//     throw Exception("Failed to fetch destinations data");
//   }
// }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.white,
//     appBar: AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       leading: IconButton(
//         icon: const Icon(Icons.arrow_back, color: Colors.black),
//         onPressed: () => Navigator.pop(context), // 뒤로가기 버튼
//       ),
//       title: const Text(
//         "ZIBRO",
//         style: TextStyle(
//           color: Colors.black,
//           fontWeight: FontWeight.bold,
//           fontSize: 22,
//         ),
//       ),
//     ),
//     body: FutureBuilder<Map<String, dynamic>>(
//       future: _partyData, // 서버에서 가져온 데이터
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // 데이터 로딩 중
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           // 데이터 가져오기 실패
//           return Center(
//             child: Text('Failed to load data: ${snapshot.error}'),
//           );
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           // 데이터가 비어있음
//           return const Center(child: Text('No data available'));
//         } else {
//           final data = snapshot.data!;
//           return _buildContent(data); // 데이터로 UI 생성
//         }
//       },
//     ),
//   );
// }

//   Widget _buildMap() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.grey,
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(55),
//           topRight: Radius.circular(55),
//         ),
//       ),
//       clipBehavior: Clip.hardEdge, // 클리핑을 강제하여 둥근 모서리 적용
//       child: MapWidget(
//         showCenterPin: false, // 중앙 핀 숨김
//         initialLocation: const LatLng(
//             37.55591036718129, 126.92295108368768), // 초기 위치 (홍대 근처)
//         onCameraMove: (location) {
//           _updateDeparture(location); // 카메라 이동 시 출발 위치 업데이트
//         },
//         onDestinationConfirmed: (location) {
//           print("목적지 확정: $location"); // 목적지 확정 로깅
//         },
//       ),
//     );
//   }
// }
