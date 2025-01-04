import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
// import 'package:database_final_project/page/home_page.dart';
import 'package:database_final_project/page/character_page.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:database_final_project/provider/api.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  double _opacity = 0.0;
  double _blurValue = 10.0;
  late AudioPlayer _audioPlayer;
  // 定義 TextEditingController
  final TextEditingController _emailController =
      TextEditingController(text: 't112318147@ntut.org.tw');
  final TextEditingController _passwordController =
      TextEditingController(text: '112318147');
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _registerCheckPasswordController =
      TextEditingController();

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

  @override
  void dispose() {
    // Dispose the audio player
    _audioPlayer.dispose();

    // Dispose all the TextEditingControllers
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerCheckPasswordController.dispose();

    super.dispose();
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        bool isRegistering = false;
        final serverAPI = Provider.of<ServerAPI>(context, listen: false);

        return StatefulBuilder(
          builder: (context, setState) {
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
                    if (!isRegistering) ...[
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: '輸入電子郵件信箱/使用者名稱',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
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
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                        ),
                        obscureText: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                isRegistering = true;
                              });
                            },
                            child: const Text(
                              '立即註冊',
                              style: TextStyle(color: Color(0xFFFFCA28)),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              debugPrint('Forgot password pressed');
                            },
                            child: const Text(
                              '忘記密碼',
                              style: TextStyle(color: Color(0xFFFFCA28)),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();
                          final resultLogin =
                              await serverAPI.loginIn(email, password);

                          if (resultLogin == 'login success') {
                            // log('Token: ${serverAPI.accessToken}');
                            // log('User ID: ${serverAPI.userId}');
                            _audioPlayer.stop();
                            // Navigator.of(context).pushReplacement(
                            //   MaterialPageRoute(
                            //     builder: (context) => HomePage(),
                            //   ),
                            // );

                            try {
                              await serverAPI.getUserCharacter();
                              if (!context.mounted) return;
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const CharacterPage(),
                                ),
                              );
                            } catch (e) {
                              log('Error fetching characters: $e');
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Failed to load characters: $e')),
                              );
                            }
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(resultLogin)),
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
                          '進入遊戲',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: '輸入你的名字',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: '輸入你的姓氏',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _registerEmailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: '輸入你的 Email',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _registerPasswordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: '輸入你的密碼',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: _registerCheckPasswordController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: '確認你的密碼',
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final firstName =
                                  _firstNameController.text.trim();
                              final lastName = _lastNameController.text.trim();
                              final email =
                                  _registerEmailController.text.trim();
                              final password =
                                  _registerPasswordController.text.trim();
                              final checkPassword =
                                  _registerCheckPasswordController.text.trim();

                              final result = await serverAPI.signUp(
                                firstName,
                                lastName,
                                email,
                                password,
                                checkPassword,
                              );

                              // log('result = $result');

                              if (!context.mounted) return;

                              if (result == 'register success') {
                                setState(() {
                                  isRegistering = false;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result)),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: const Size(100, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '註冊',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isRegistering = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              minimumSize: const Size(100, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '取消',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
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
                  // const SizedBox(height: 5), // 添加間距
                  AnimatedOpacity(
                    opacity: _opacity,
                    duration: const Duration(seconds: 5),
                    curve: Curves.easeInOut,
                    child: Text(
                      '點擊螢幕進入',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF006400)
                            .withOpacity(0.8), // 墨綠色，稍微透明
                        letterSpacing: 3.0, // 調整字體間距
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
          ],
        ),
      ),
    );
  }
}
