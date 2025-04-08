import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NearbyTaxiPartiesPage extends StatefulWidget {
  const NearbyTaxiPartiesPage({super.key});

  @override
  State<NearbyTaxiPartiesPage> createState() => _NearbyTaxiPartiesPageState();
}

class _NearbyTaxiPartiesPageState extends State<NearbyTaxiPartiesPage> {
  late Future<List<Map<String, dynamic>>> _taxiParties;

  @override
  void initState() {
    super.initState();
    _taxiParties = _fetchTaxiParties();
  }

  /// 서버에서 인근 택시 파티 정보 가져오기
  Future<List<Map<String, dynamic>>> _fetchTaxiParties() async {
    const String apiUrl = "http://127.0.0.1:8000/parties"; // API 엔드포인트
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['parties']);
      } else {
        throw Exception("Failed to load taxi parties: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching taxi parties: $e");
      throw Exception("Failed to fetch taxi parties");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "인근 TAXI 파티 목록",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _taxiParties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "데이터를 불러오지 못했습니다.\n오류: ${snapshot.error}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("주변에 참여 가능한 파티가 없습니다."),
            );
          }

          final taxiParties = snapshot.data!;
          return ListView.builder(
            itemCount: taxiParties.length,
            itemBuilder: (context, index) {
              final party = taxiParties[index];
              return _buildTaxiPartyTile(party);
            },
          );
        },
      ),
    );
  }

  /// 택시 파티 정보를 표시하는 타일 위젯
  Widget _buildTaxiPartyTile(Map<String, dynamic> party) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          leading: const Icon(
            Icons.local_taxi,
            size: 36,
            color: Colors.blue,
          ),
          title: Text(
            "${party['departure']} to ${party['destination']} ${party['male']}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("모집 상태: ${party['status']}"),
              Text("집결 장소: ${party['gatheringLocation']}"),
              Text("출발 시간: ${party['departureTime']}"),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () {
              _joinParty(party['party_id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3387E5),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "참여하기",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 파티 참여 버튼 클릭 시 호출
  void _joinParty(int partyId) {
    print("참여할 파티 ID: $partyId");
    // 참여 로직 구현
  }
}
