import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:texi_application/services/api_client.dart';
import 'package:texi_application/services/party_service.dart';
import 'my_party_info.dart';
import 'Passenger_home1.dart';

class PassengerMakePartyInfo extends StatefulWidget {
  const PassengerMakePartyInfo({super.key});

  @override
  State<PassengerMakePartyInfo> createState() => _PassengerMakePartyInfoState();
}

class _PassengerMakePartyInfoState extends State<PassengerMakePartyInfo> {
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  String? departureAddress;
  TimeOfDay? selectedTime;
  String? selectedDrunkOption;
  final PartyService partyService =
      PartyService(ApiClient("http://10.0.2.2:8000"));

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _getAddressFromLatLng(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    // 여기에 Geocoding API를 사용하여 좌표를 주소로 변환하는 코드를 추가하세요.
    // 예제에서는 주소를 하드코딩합니다.
    setState(() {
      departureAddress = "홍대역 9번 출구"; // 여기를 실제 변환된 주소로 변경하세요.
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          color: Colors.white,
          child: Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height / 4,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: DateTime.now(),
                  use24hFormat: false,
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      selectedTime = TimeOfDay(
                        hour: newDateTime.hour,
                        minute: newDateTime.minute,
                      );
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createParty(BuildContext context) async {
    if (departureAddress == null ||
        destinationController.text.isEmpty ||
        selectedTime == null ||
        selectedDrunkOption == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("잠시만요"),
          content: Text("모든 입력 사항을 입력해주세요"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final partyData = {
        'departure': departureAddress,
        'destination': destinationController.text,
        'time': selectedTime!.format(context), // 시간 형식 변경
        'note': noteController.text,
        'drunk': selectedDrunkOption
      };

      final response = await partyService.createParty(partyData);

      print("Party created successfully: $response");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyPartyInfo(),
        ),
      );
    } catch (e) {
      print("Failed to create party: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text("Failed to create party. Please try again."),
          actions: [
            TextButton(
              onPressed: () {
                //_createParty(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PassengerHomePage1(),
                  ),
                );
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'TAXI 파티 만들기',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Be Vietnam Pro',
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentLocationField(),
            SizedBox(height: 12),
            _buildInputField(
              controller: destinationController,
              hintText: '도착지',
              icon: Icons.location_on,
            ),
            SizedBox(height: 12),
            _buildTimePickerField(context),
            SizedBox(height: 12),
            _buildDrunkOptionField(),
            SizedBox(height: 12),
            _buildTextarea(
              controller: noteController,
              hintText: '원활한 동행을 위해 만나는 장소를 명시해주세요!\n(예시: 합정역 2번출구)',
            ),
            SizedBox(height: 16),
            _buildActionButton(
              label: 'TAXI 파티 만들기',
              color: Color(0xFF3387E5),
              textColor: Colors.white,
              onPressed: () {
                //_createParty(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPartyInfo(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationField() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Color(0xFFEFF2F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                departureAddress ?? '현재 위치를 가져오는 중...',
                style: TextStyle(
                  color: departureAddress != null
                      ? Colors.black
                      : Color(0xFF637287),
                  fontSize: 16,
                  fontFamily: 'Be Vietnam Pro',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.location_on, color: Color(0xFF637287)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerField(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectTime(context),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Color(0xFFEFF2F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  selectedTime != null
                      ? selectedTime!.format(context)
                      : '출발 시각 선택',
                  style: TextStyle(
                    color:
                        selectedTime != null ? Colors.black : Color(0xFF637287),
                    fontSize: 16,
                    fontFamily: 'Be Vietnam Pro',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(Icons.calendar_today, color: Color(0xFF637287)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrunkOptionField() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Color(0xFFEFF2F4),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: DropdownButton<String>(
        value: selectedDrunkOption,
        hint: Text(
          '음주 여부 선택',
          style: TextStyle(
            color: Color(0xFF637287),
            fontSize: 16,
            fontFamily: 'Be Vietnam Pro',
            fontWeight: FontWeight.w400,
          ),
        ),
        dropdownColor: Color(0xFF3387E5),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
        isExpanded: true,
        underline: SizedBox(),
        items: ['O', 'X'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Be Vietnam Pro',
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedDrunkOption = newValue;
          });
        },
      ),
    );
  }

  Widget _buildInputField({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Color(0xFFEFF2F4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Color(0xFF637287),
                    fontSize: 16,
                    fontFamily: 'Be Vietnam Pro',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Be Vietnam Pro',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(icon, color: Color(0xFF637287)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextarea({
    required String hintText,
    required TextEditingController controller,
  }) {
    return Container(
      height: 144,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFFEFF2F4),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: controller,
        maxLines: null,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: Color(0xFF637287),
            fontSize: 16,
            fontFamily: 'Be Vietnam Pro',
            fontWeight: FontWeight.w400,
          ),
        ),
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontFamily: 'Be Vietnam Pro',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: Size(double.infinity, 48),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontFamily: 'Be Vietnam Pro',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
