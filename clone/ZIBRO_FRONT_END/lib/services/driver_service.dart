import 'api_client.dart';

class DriverService {
  final ApiClient apiClient;

  // 생성자: ApiClient 주입
  DriverService(this.apiClient);
  // 로그인 API 호출
  Future<Map<String, dynamic>> login(String username, String password) async {
    return await apiClient.post('/drivers/login', {
      'username': username,
      'password': password,
    });
  }

  // 회원가입 API 호출
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await apiClient.post('/drivers/register', userData);
  }
  // 기사 정보 가져오기
  Future<Map<String, dynamic>> fetchDriverInfo() async {
    return await apiClient.get('/drivers/register');
  }
    // TAXI 파티 생성 함수
  Future<Map<String, dynamic>> createDriverInfo(
      Map<String, dynamic> driverData) async {
    try {
      final response = await apiClient.post('/driver/register', driverData);
      return response;
    } catch (e) {
      throw Exception("Failed to driver Info: $e");
    }
  }
}
