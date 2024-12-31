import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:database_final_project/home_page.dart';
import 'package:audioplayers/audioplayers.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double _opacity = 0.0; // 控制透明度
  double _blurValue = 10.0; // 控制模糊值
  late AudioPlayer _audioPlayer; // 音频播放器实例

  @override
  void initState() {
    super.initState();

    // 初始化音频播放器并播放背景音乐
    _audioPlayer = AudioPlayer();
    _playAudio();

    // 开始动画
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
        _blurValue = 0.0;
      });
    });
  }

  Future<void> _playAudio() async {
    try {
      _audioPlayer.setVolume(1.0);
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer
          .play(AssetSource('audio/Genshin_background_music.mp3'));
      debugPrint('Audio is playing.');
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // 销毁音频播放器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // 确保整个屏幕区域都可以响应点击事件
        onTap: () {
          _audioPlayer.stop(); // 停止音频播放
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        },
        child: Stack(
          children: [
            Container(
              color: Colors.white,
            ),
            Center(
              child: AnimatedOpacity(
                //透明度
                opacity: _opacity,
                duration: const Duration(seconds: 3),
                curve: Curves.easeInOut,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _blurValue,
                      sigmaY: _blurValue,
                    ),
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: Image.asset(
                        'assets/logo/Genshin_1.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
