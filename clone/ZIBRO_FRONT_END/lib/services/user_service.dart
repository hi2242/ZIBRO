import 'api_client.dart';

class UserService {
  final ApiClient apiClient;

  UserService(this.apiClient);

  // 로그인 API 호출
  Future<Map<String, dynamic>> login(String username, String password) async {
    return await apiClient.post('/auth/login', {
      'username': username,
      'password': password,
    });
  }

  // 회원가입 API 호출
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    return await apiClient.post('/auth/register', userData);
  }
}
