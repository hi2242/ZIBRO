import 'package:flutter/material.dart';
import 'package:texi_application/pages/loading.dart';
import 'pages/sign_up_page.dart'; // 로그인 페이지 import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadedPage(),
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => LoadedPage(),
        '/signup': (context) => SignUpPage(),
      }, // LoadedPage를 초기 화면으로 설정합니다.
    );
  }
}
