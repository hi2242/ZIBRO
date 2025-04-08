import 'api_client.dart';

class PartyService {
  final ApiClient apiClient;

  // PartyService 생성자
  PartyService(this.apiClient);

  // TAXI 파티 생성 함수
  Future<Map<String, dynamic>> createParty(
      Map<String, dynamic> partyData) async {
    try {
      final response = await apiClient.post('/party/create', partyData);
      return response;
    } catch (e) {
      throw Exception("Failed to create party: $e");
    }
  }

  // TAXI 파티 목록 가져오기 함수
  Future<List<dynamic>> getParties() async {
    try {
      final response = await apiClient.get('/party/list');
      return response as List<dynamic>;
    } catch (e) {
      throw Exception("Failed to fetch parties: $e");
    }
  }

  // TAXI 파티 세부 정보 가져오기 함수
  Future<Map<String, dynamic>> getPartyDetails(int partyId) async {
    try {
      final response = await apiClient.get('/party/details/$partyId');
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Failed to fetch party details: $e");
    }
  }
}
