import 'package:flutter/material.dart';
import 'package:texi_application/services/api_client.dart';
import 'package:texi_application/services/party_service.dart';
import 'party_out_check.dart';
import 'call_taxi_page1.dart';
import 'Passenger_home1.dart';

class MyPartyInfo extends StatefulWidget {
  const MyPartyInfo({super.key});

  @override
  _MyPartyInfoState createState() => _MyPartyInfoState();
}

class _MyPartyInfoState extends State<MyPartyInfo> {
  late Future<Map<String, dynamic>> _partyData;

  // PartyService 인스턴스 생성
  final PartyService partyService =
      PartyService(ApiClient("http://127.0.0.1:8000")); // 서버 URL 설정

  @override
  void initState() {
    super.initState();
    // 파티 정보 불러오기
    _partyData = _fetchPartyData();
  }

  // 서버에서 파티 정보 가져오기
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _partyData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  //_createParty(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PassengerHomePage1(),
                    ),
                  );
                },
              ),
              title: Text(
                "Loading...",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  //_createParty(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PassengerHomePage1(),
                    ),
                  );
                },
              ),
              title: Text(
                "Error",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            body: Center(child: Text("Failed to load party data")),
          );
        }

        final data = snapshot.data!;
        final partyDetails = data['partyDetails'];
        final myInfo = data['myInfo'];
        final partyMembers = data['partyMembers'];
        final title =
            "${partyDetails['departure']} to ${partyDetails['destination']}"; // 출발지와 목적지 설정

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                //_createParty(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PassengerHomePage1(),
                  ),
                );
              },
            ),
            title: Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Be Vietnam Pro',
                fontSize: 22,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 집결 장소와 출발 시간
                Text(
                  '집결 장소 : ${partyDetails['gatheringLocation']}\n출발 시간 : ${partyDetails['departureTime']}',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Be Vietnam Pro',
                  ),
                ),
                SizedBox(height: 20),
                // 내 정보
                _buildPartyMemberCard(myInfo, isMe: true),
                SizedBox(height: 10),
                // 파티원 목록
                SizedBox(
                  height: (partyMembers.length *
                          (MediaQuery.of(context).size.height * 0.18))
                      .toDouble(), // 각 카드 높이(예: 100) * 아이템 개수
                  child: ListView.builder(
                    itemCount: partyMembers.length,
                    physics: NeverScrollableScrollPhysics(), // 스크롤 방지
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _buildPartyMemberCard(partyMembers[index]),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                // 하단 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(
                      label: 'TAXI 호출하기',
                      color: Color(0xFF3387E5),
                      textColor: Colors.white,
                      onPressed: () {
                        print('TAXI 호출하기 클릭');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CallTaxiPage1(),
                          ),
                        );
                      },
                    ),
                    _buildActionButton(
                      label: '파티 탈퇴하기',
                      color: Color(0xFF8E8C8C),
                      textColor: Colors.white,
                      onPressed: () {
                        print('파티 탈퇴하기 클릭');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PartyExitScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 파티원 카드 생성
  Widget _buildPartyMemberCard(Map<String, dynamic> memberInfo,
      {bool isMe = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage('assets/images/duck.png'),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${memberInfo['name']}${isMe ? '(나)' : ''}, ${memberInfo['university']}, ${memberInfo['department']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Be Vietnam Pro',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '성별 : ${memberInfo['gender']}\n나이 : ${memberInfo['age']}\n음주 여부 : ${memberInfo['drunk']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF637287),
                    fontFamily: 'Be Vietnam Pro',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 하단 버튼 생성
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
        minimumSize: Size(170, 48),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Be Vietnam Pro',
        ),
      ),
    );
  }
}
