import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl; // 백엔드 서버의 기본 URL

  ApiClient(this.baseUrl);

  // GET 요청: 데이터를 가져올 때 사용
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));
    return _processResponse(response);
  }

  // POST 요청: 데이터를 서버로 보낼 때 사용
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'}, // JSON 형식으로 데이터 전송
      body: jsonEncode(body), // Map 데이터를 JSON 문자열로 변환
    );
    return _processResponse(response);
  }

  // 응답 처리: 성공적인 응답과 오류 처리 분리
  dynamic _processResponse(http.Response response) {
    // UTF-8 디코딩 처리
    final decodedBody =
        utf8.decode(response.bodyBytes); // bodyBytes를 UTF-8로 디코딩
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(decodedBody); // JSON 응답을 Map 형식으로 변환
    } else {
      // 상태 코드가 200~299가 아닌 경우 예외 처리
      throw Exception('Error: ${response.statusCode}, $decodedBody');
    }
  }
}
