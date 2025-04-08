import 'package:flutter/material.dart';
import 'dart:async'; // 로딩 구현을 위해 import

class LoadedPage extends StatefulWidget {
  const LoadedPage({super.key});

  @override
  State<LoadedPage> createState() => _LoadedPageState();
}

class _LoadedPageState extends State<LoadedPage> {
  @override
  void initState() {
    super.initState();
    // 로딩 후 페이지 이동
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/signup');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '집에 갈 땐 다 같이',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Be_Vietnam_Pro',
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 40),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Z',
                    style: TextStyle(
                      color: Color(0xFF3387E5),
                      fontSize: 80,
                      fontFamily: 'Be Vietnam Pro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'IBRO',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 50,
                      fontFamily: 'Be Vietnam Pro',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
