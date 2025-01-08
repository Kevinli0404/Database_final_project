import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final int loadingIndex;
  const LoadingOverlay({
    super.key,
    required this.loadingIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 16; i++)
              Stack(
                children: [
                  // 外邊框層
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: loadingIndex == i ? 40 : 30,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Colors.blue,
                      letterSpacing: 5,
                    ),
                    child: Text([
                      '我',
                      '最',
                      '喜',
                      '歡',
                      '玩',
                      '原',
                      '神',
                      '了',
                      '!',
                      '我',
                      '是',
                      '可',
                      '莉',
                      '玩',
                      '家',
                      '!'
                    ][i]),
                  ),
                  // 白色填充層
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: loadingIndex == i ? 40 : 30,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                    ),
                    child: Text([
                      '我',
                      '最',
                      '喜',
                      '歡',
                      '玩',
                      '原',
                      '神',
                      '了',
                      '!',
                      '我',
                      '是',
                      '可',
                      '莉',
                      '玩',
                      '家',
                      '!'
                    ][i]),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
