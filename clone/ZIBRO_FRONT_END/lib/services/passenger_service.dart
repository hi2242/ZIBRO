import 'api_client.dart';

class PassengerService {
  final ApiClient apiClient;

  // 생성자: ApiClient 주입
  PassengerService(this.apiClient);

  // 기사 정보 가져오기
  Future<Map<String, dynamic>> fetchPassengerInfo() async {
    return await apiClient.get('/passenger');
  }
}
