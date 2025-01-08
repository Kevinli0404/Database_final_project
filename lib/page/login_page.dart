import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:database_final_project/page/character_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:database_final_project/provider/api.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // 引入 Timer

import 'package:database_final_project/main.dart'; // 引入 GlobalKey 定義的文件

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double _opacity = 0.0;
  double _blurValue = 10.0;
  late AudioPlayer _audioPlayer;
  bool isLoading = false; // 控制全屏遮罩的狀態

  int _loadingIndex = 0; // 當前顯示字的索引
  late Timer _loadingTimer;

  final TextEditingController _emailController =
      TextEditingController(text: 't112318147@ntut.org.tw');
  final TextEditingController _passwordController =
      TextEditingController(text: '112318147');

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();
    _playAudio();

    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _opacity = 1.0;
        _blurValue = 0.0;
      });
    });

    // 啟動 Timer 更新動畫
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (isLoading) {
        setState(() {
          _loadingIndex = (_loadingIndex + 1) % 6; // 循環切換索引
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _loadingTimer.cancel(); // 停止 Timer
    super.dispose();
  }

  Future<void> _playAudio() async {
    try {
      _audioPlayer.setVolume(1.0);
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer
          .play(AssetSource('audio/genshin_background_music.mp3'));
      debugPrint('Audio is playing.');
    } catch (e) {
      debugPrint('Error playing audio: $e');
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // final serverAPI = Provider.of<ServerAPI>(context, listen: false);

        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: '輸入電子郵件信箱/使用者名稱',
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: '輸入密碼',
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  ),
                  obscureText: true,
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();

                    setState(() {
                      isLoading = true;
                    });

                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    final serverAPI =
                        Provider.of<ServerAPI>(context, listen: false);

                    try {
                      final resultLogin =
                          await serverAPI.loginIn(email, password);
                      log('resultLogin = $resultLogin');

                      if (resultLogin == 'login success') {
                        await serverAPI.getUserCharacter();
                        _audioPlayer.stop();
                        setState(() {
                          isLoading = false;
                        });

                        navigatorKey.currentState?.pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const CharacterPage(),
                          ),
                        );
                      } else {
                        setState(() {
                          isLoading = false;
                        });

                        ScaffoldMessenger.of(
                          navigatorKey.currentState!.context,
                        ).showSnackBar(
                          SnackBar(content: Text(resultLogin)),
                        );

                        _showLoginDialog();
                      }
                    } catch (e) {
                      log('Error during login: $e');

                      setState(() {
                        isLoading = false;
                      });

                      ScaffoldMessenger.of(
                        navigatorKey.currentState!.context,
                      ).showSnackBar(
                        SnackBar(content: Text('An error occurred: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '原神啟動',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _showLoginDialog();
            },
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedOpacity(
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
                                  'assets/logo/genshin_login_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: _opacity,
                          duration: const Duration(seconds: 5),
                          curve: Curves.easeInOut,
                          child: Text(
                            '點擊螢幕進入',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF006400).withOpacity(0.8),
                              letterSpacing: 3.0,
                              shadows: [
                                Shadow(
                                  offset: const Offset(1.0, 1.0),
                                  blurRadius: 2.0,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < 6; i++)
                          Stack(
                            children: [
                              // 外邊框層
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize:
                                      _loadingIndex == i ? 40 : 30, // 當前字母變大
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke // 外框
                                    ..strokeWidth = 2 // 外框粗細
                                    ..color = Colors.blue, // 外框顏色
                                  letterSpacing: 5, // 字母間距
                                ),
                                child: Text(['原', '神', '啟', '動', '!', '!'][i]),
                              ),
                              // 白色填充層
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: TextStyle(
                                  fontSize:
                                      _loadingIndex == i ? 40 : 30, // 當前字母變大
                                  color: Colors.white, // 內部填充顏色
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 5, // 字母間距
                                ),
                                child: Text(['原', '神', '啟', '動', '!', '!'][i]),
                              ),
                            ],
                          ),
                      ],
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
