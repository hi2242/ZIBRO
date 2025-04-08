import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DriversMapScreen extends StatefulWidget {
  const DriversMapScreen({super.key});

  @override
  State<DriversMapScreen> createState() => _DriversMapScreenState();
}

class _DriversMapScreenState extends State<DriversMapScreen> {
  // NaverMapController 객체를 위한 Completer 생성
  final Completer<NaverMapController> _mapControllerCompleter = Completer();
  bool _isInitialized = false;
  late NaverMapController _mapController;
  Set<NMarker> markers = {};
  NOverlayImage? _customMarkerIcon;
  NOverlayImage? clusterIcon;

  @override
  void initState() {
    super.initState();
    _permission();
    _initialize(); // 위젯이 처음 생성될 때 지도 초기화
    _loadMarkersFromFile(); // 파일에서 마커 정보 로드
    _createCustomMarkerIcon();
    // _getCurrentLocation(); // 앱 시작 시 위치 가져오기
  }

  Future<void> _createCustomMarkerIcon() async {
    try {
      final overlayImage = NOverlayImage.fromAssetImage(
        'assets/blueCircle.png', // 이미지 경로
      );

      // final overlayImage = await NOverlayImage.fromWidget(
      //   widget: Container(
      //     width: 40,
      //     height: 40,
      //     decoration: BoxDecoration(
      //       color: Colors.blueAccent,
      //       shape: BoxShape.circle,
      //     ),
      //   ),
      //   size: const Size(40, 40),
      //   context: context,
      // );

      setState(() {
        _customMarkerIcon = overlayImage;
      });
    } catch (e) {
      log('Error creating custom marker icon: $e');
    }
  }

  Future<void> _loadMarkersFromFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/drivers_marker.txt');

      if (await file.exists()) {
        final data = await file.readAsString();
        final lines = data.split('\n');

        Set<NMarker> loadedMarkers = {};

        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty || !line.contains(':')) {
            continue; // 빈 줄이나 ':' 없는 줄은 건너뜀
          }

          final parts = line.split(':');
          if (parts.length != 2) {
            log('잘못된 형식: $line');
            continue; // 잘못된 형식의 줄 건너뜀
          }

          final key = parts[0].trim();
          final value = parts[1].trim();

          if (key == 'X' && value.isNotEmpty) {
            final x = double.tryParse(value);
            if (x != null && i + 1 < lines.length) {
              final nextLine = lines[i + 1].trim();
              if (nextLine.contains(':')) {
                final yParts = nextLine.split(':');
                if (yParts.length == 2) {
                  final yValue = yParts[1].trim();
                  final y = double.tryParse(yValue);
                  if (y != null) {
                    log('latitude, longitude: $x, $y');
                    loadedMarkers.add(NMarker(
                      id: 'marker_${x}_$y',
                      position: NLatLng(x, y),
                      icon: _customMarkerIcon,
                      // NOverlayImage.fromAssetImage('assets/blueCircle.png'),
                    ));
                  }
                }
              }
            }
          }
        }

        setState(() {
          markers = loadedMarkers;
        });
      }
    } catch (e, stackTrace) {
      log('파일 읽기 오류: $e\n$stackTrace');
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

  void _permission() async {
    var requestStatus = await Permission.location.request();
    var status = await Permission.location.status;
    if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
  // // 현재 위치 가져오기
  // Future<void> _getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;

  //   // 위치 서비스가 활성화 되어 있는지 확인
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     log("위치 서비스가 활성화되어 있지 않습니다.");
  //     return;
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission != LocationPermission.whileInUse &&
  //         permission != LocationPermission.always) {
  //       log("위치 권한이 거부되었습니다.");
  //       return;
  //     }
  //   }

  //   // 현재 위치 가져오기
  //   Position position = await Geolocator.getCurrentPosition(
  //     // ignore: deprecated_member_use
  //     desiredAccuracy: LocationAccuracy.high,
  //   );

  //   setState(() {
  //     _currentPosition = position;
  //   });

  //   // 지도 카메라를 현재 위치로 이동
  //   if (_currentPosition != null) {
  //     final cameraUpdate = CameraUpdate.scrollTo(
  //       LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
  //     );

  //     // 카메라를 이동
  //     _mapController.moveCamera(cameraUpdate);
  //   }
  //   // // 위치가 업데이트되었을 때 지도에 마커 추가
  //   // if (_currentPosition != null) {
  //   //   _addMarker(_currentPosition!);
  //   // }
  // }

  // // 마커 추가
  // void _addMarker(Position position) {
  //   _mapController.addOverlay(
  //     Marker(
  //       position: LatLng(position.latitude, position.longitude), // 현재 위치
  //       Icon(
  //         color: Color(0xFFA3A4A7),
  //         size: 16,
  //         Icons.garage,
  //       ), // 아이콘 추가 (경로에 맞게 변경)
  //     ),
  //   );
  // }

  // Set<Marker> markers = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isInitialized
          ? Stack(
              children: [
                // NaverMap 위젯을 SizedBox로 감싸서 크기를 제한
                SizedBox(
                  width: double.infinity, // 가로 크기 전체 사용
                  // height: MediaQuery.of(context).size.height *
                  //     0.9, // 화면의 90%를 박스 크기로 설정
                  height: double.infinity, // 세로 크기 전체 사용
                  child: NaverMap(
                    options: const NaverMapViewOptions(
                      indoorEnable: true, // 실내 맵 사용 가능 여부 설정
                      locationButtonEnable: false, // 위치 버튼 표시 여부 설정
                      consumeSymbolTapEvents: false, // 심볼 탭 이벤트 소비 여부 설정
                    ),

                    // clusterOptions: NaverMapClusteringOptions(
                    //     clusterMarkerBuilder: (info, clusterMarker) {
                    //   print("[flutter] clusterMarkerBuilder: $info");
                    //   if (clusterIcon != null)
                    //     clusterMarker.setIcon(clusterIcon!);
                    //   clusterMarker.setIsFlat(true);
                    //   clusterMarker.setCaption(NOverlayCaption(
                    //       text: info.size.toString(),
                    //       color: Colors.white,
                    //       haloColor: Colors.blueAccent));
                    // }),
                    onMapReady: (controller) async {
                      _mapControllerCompleter
                          .complete(controller); // Completer에 지도 컨트롤러 완료 신호 전송
                      _mapController = controller;

                      // 지도 준비가 완료되면 위치 추적 모드를 활성화
                      _mapController.setLocationTrackingMode(
                          NLocationTrackingMode.follow);

                      // 마커들을 지도에 추가
                      controller.addOverlayAll(markers);
                    },
                  ),
                ),
                Positioned(
                  bottom: 0, // 맨 아래에 배치
                  left: MediaQuery.of(context).size.width * 0.02, // 좌측 여백
                  right: MediaQuery.of(context).size.width * 0.02, // 우측 여백
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Color(0xFF191C24),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25), // 위쪽 왼쪽만 둥글게
                        topRight: Radius.circular(25), // 위쪽 오른쪽만 둥글게
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 15,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '콜 적음',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontFamily: 'Be Vietnam Pro',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(
                                width: 200,
                              ),
                              Text(
                                '콜 많음',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontFamily: 'Be Vietnam Pro',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 360,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFFFFFFFF),
                                  Color(0xFF3387E5),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 60,
                          ),
                          Text(
                            '기사님 주변에서 발생하는 콜과 콜이 많이 발생하는 지역을 표시합니다.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF8F8F8F),
                              fontSize: 18,
                              fontFamily: 'Be Vietnam Pro',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
