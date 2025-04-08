import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum AppState {
  choosingLocation,
  confirmingFare,
  waitingForPickup,
  riding,
  postRide,
}

enum RideStatus {
  picking_up,
  riding,
  completed,
}

class MapWidget extends StatefulWidget {
  final LatLng initialLocation; // 초기 카메라 위치
  final Function(LatLng)? onCameraMove; // 카메라 이동 시 호출되는 콜백 함수
  final Function(LatLng)? onDestinationConfirmed; // 목적지 선택 완료 시 호출되는 콜백 함수
  final bool showCenterPin; // center-pin 표시 여부

  const MapWidget({
    super.key,
    required this.initialLocation,
    this.onCameraMove,
    this.onDestinationConfirmed,
    this.showCenterPin = false,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  LatLng? _selectedDestination;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(37.55591036718129, 126.92295108368768),
    zoom: 16.8,
  );
  final AppState _appState = AppState.choosingLocation;

  BitmapDescriptor? _pinIcon;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadPinIcon();
  }

  /// 위치 권한 확인 및 요청
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _askForLocationPermission();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _askForLocationPermission();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return _askForLocationPermission();
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _getCurrentLocation();
  }

  /// Shows a modal to ask for location permission.
  Future<void> _askForLocationPermission() async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Location Permission'),
            content: const Text(
                'This app needs location permission to work properly.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                child: const Text('Close App'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Geolocator.openLocationSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          );
        });
  }

  /// 현재 위치 가져오기
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      print('Location Permission: $permission');

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _initialCameraPosition = CameraPosition(
          target: _currentLocation!,
          zoom: 16.8,
        );
      });
      _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition));
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error occured while getting the current location')));
      }
    }
  }

  /// 핀 아이콘 로드
  Future<void> _loadPinIcon() async {
    const imageConfiguration = ImageConfiguration(size: Size(48, 48));
    _pinIcon = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed); // 기본 마커로 설정
  }

  /// 위치 권한 요청 다이얼로그
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Location Permission'),
          content: const Text(
              'This app needs location permission to work properly.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openLocationSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _onCameraMove(CameraPosition position) {
    if (_appState == AppState.choosingLocation) {
      _selectedDestination = position.target;
    }
  }

  //센터 핀
  Widget _buildCenterPin() {
    if (widget.showCenterPin) {
      return Center(
        child: Image.asset(
          'assets/images/center-pin.png',
          width: 96,
          height: 96,
        ),
      );
    }
    return const SizedBox.shrink(); // 빈 공간 반환
  }

  /// 목적지 확정
  void confirmDestination() {
    if (_selectedDestination != null) {
      setState(() {
        _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: _selectedDestination!,
          icon: _pinIcon ?? BitmapDescriptor.defaultMarker,
        ));
      });

      if (widget.onDestinationConfirmed != null) {
        widget.onDestinationConfirmed!(_selectedDestination!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          cloudMapId: 'f5daf6a162a9dad8',
          initialCameraPosition: _initialCameraPosition,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          zoomControlsEnabled: true,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          markers: _markers,
          polylines: _polylines,
          onCameraMove: _onCameraMove,
          //polylines: _polylines,
          //markers: _markers,
        ),
        _buildCenterPin(),
        /*Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: ElevatedButton(
            onPressed: confirmDestination,
            child: const Text('Confirm Destination'),
          ),
        ),*/
      ],
    );
  }
}
