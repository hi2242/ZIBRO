import 'package:flutter/material.dart';
import 'dart:async'; // 로딩 구현을 위해 import

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/signup');
    });
    return Scaffold(
      // Scaffold 추가
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.only(
          top: 323,
          left: 98,
          right: 98,
          bottom: 400,
        ),
        decoration: const BoxDecoration(color: Colors.white),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '집에 갈 땐 다 같이',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontFamily: 'Be_Vietnam_Pro',
                fontWeight: FontWeight.w700,
                height: 1.2, // height 값 조정
              ),
            ),
            SizedBox(height: 59),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Z',
                      style: TextStyle(
                        color: Color(0xFF3387E5),
                        fontSize: 80,
                        fontFamily: 'Be Vietnam Pro',
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                    TextSpan(
                      text: 'IBRO',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 50,
                        fontFamily: 'Be Vietnam Pro',
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
