import 'package:flutter/material.dart';
import 'package:texi_application/screens/drivers/drivers_result_screen.dart';

class UnlockSlider extends StatefulWidget {
  final Map<String, String> driverData;

  const UnlockSlider({super.key, required this.driverData});
  // const UnlockSlider({super.key});

  @override
  _UnlockSliderState createState() => _UnlockSliderState();
}

class _UnlockSliderState extends State<UnlockSlider> {
  double _dragPosition = 0.0;
  final double _sliderWidth = 356.0; // 슬라이더 전체 너비
  final double _sliderButtonWidth = 65.0; // 버튼의 너비

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.primaryDelta!;

      if (_dragPosition < 0) {
        _dragPosition = 0;
      } else if (_dragPosition > _sliderWidth - _sliderButtonWidth) {
        _dragPosition = _sliderWidth - _sliderButtonWidth;
      }
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragPosition >= _sliderWidth - _sliderButtonWidth) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DriversResultScreen(
            driverData: widget.driverData,
          ),
        ),
        // MaterialPageRoute(builder: (context) => const DriversResultScreen()),
      ).then((_) {
        setState(() {
          // 슬라이더가 끝까지 가면 위치 초기화
          _dragPosition = 0.0;
        });
      });
    } else {
      // 임계값에 도달하지 못했을 경우 부드럽게 원위치로 돌아감
      setState(() {
        _dragPosition = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Stack(
        children: [
          Container(
            width: 356,
            height: 83,
            decoration: BoxDecoration(
              color: const Color(0xFF30333A),
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(right: 0),
                child: Text(
                  "밀어서 퇴근",
                  style: TextStyle(
                      color: Color(0xFF838589),
                      fontSize: 32,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 120), // 부드러운 이동
            curve: Curves.easeOut, // 이동 애니메이션
            left: _dragPosition,
            child: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xFF444444),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_forward,
                    size: 48,
                    color: Color(0xFF8F8F8F),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
